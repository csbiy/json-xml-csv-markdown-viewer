import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/file_data.dart';
import '../providers/file_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/common/format_icon.dart';
import '../widgets/viewers/json_viewer.dart';
import '../widgets/viewers/xml_viewer.dart';
import '../widgets/viewers/csv_viewer.dart';
import '../widgets/viewers/markdown_viewer.dart';
import '../widgets/editors/json_editor.dart';
import '../widgets/editors/xml_editor.dart';
import '../widgets/editors/csv_editor.dart';
import '../widgets/editors/markdown_editor.dart';
import '../utils/formatters.dart';

class ViewerScreen extends StatefulWidget {
  const ViewerScreen({super.key});

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FileProvider, SettingsProvider>(
      builder: (context, fileProvider, settingsProvider, _) {
        final file = fileProvider.currentFile;
        if (file == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('뷰어')),
            body: const Center(child: Text('파일이 없습니다')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                FormatIcon(format: file.format, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    file.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: _buildActions(context, fileProvider, settingsProvider, file),
          ),
          body: Column(
            children: [
              if (_showSearch) _buildSearchBar(),
              if (fileProvider.error != null)
                Container(
                  color: Colors.red.shade100,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(child: Text(fileProvider.error!)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: fileProvider.clearError,
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: fileProvider.isEditing
                    ? _buildEditor(file.format, fileProvider, settingsProvider)
                    : _buildViewer(file.format, fileProvider, settingsProvider),
              ),
            ],
          ),
          floatingActionButton: _buildFab(fileProvider),
        );
      },
    );
  }

  List<Widget> _buildActions(
    BuildContext context,
    FileProvider fileProvider,
    SettingsProvider settingsProvider,
    FileData file,
  ) {
    return [
      // Undo/Redo 버튼 (편집 모드일 때만 표시)
      if (fileProvider.isEditing) ...[
        IconButton(
          icon: const Icon(Icons.undo),
          onPressed: fileProvider.canUndo ? fileProvider.undo : null,
          tooltip: '실행 취소 (${fileProvider.undoStackSize})',
        ),
        IconButton(
          icon: const Icon(Icons.redo),
          onPressed: fileProvider.canRedo ? fileProvider.redo : null,
          tooltip: '다시 실행 (${fileProvider.redoStackSize})',
        ),
      ],
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () => setState(() => _showSearch = !_showSearch),
      ),
      if (file.format == FileFormat.json || file.format == FileFormat.xml)
        PopupMenuButton<String>(
          icon: const Icon(Icons.auto_fix_high),
          onSelected: (value) => _handleFormat(value, fileProvider, settingsProvider),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'pretty', child: Text('Pretty Print')),
            const PopupMenuItem(value: 'minify', child: Text('Minify')),
          ],
        ),
      IconButton(
        icon: const Icon(Icons.ios_share),
        onPressed: () => fileProvider.exportFile(),
        tooltip: '내보내기',
      ),
      PopupMenuButton<String>(
        onSelected: (value) => _handleMenuAction(value, fileProvider),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: Text(fileProvider.isEditing ? '보기 모드' : '편집 모드'),
          ),
          const PopupMenuItem(value: 'share', child: Text('텍스트 공유')),
          const PopupMenuItem(value: 'close', child: Text('파일 닫기')),
        ],
      ),
    ];
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '검색...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _showSearch = false;
              });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          isDense: true,
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildViewer(
    FileFormat format,
    FileProvider fileProvider,
    SettingsProvider settingsProvider,
  ) {
    final content = fileProvider.currentFile!.content;

    switch (format) {
      case FileFormat.json:
        return JsonViewer(
          content: content,
          searchQuery: _searchQuery,
          fontSize: settingsProvider.fontSize,
          prettyPrint: settingsProvider.jsonPrettyPrint,
        );
      case FileFormat.xml:
        return XmlViewer(
          content: content,
          searchQuery: _searchQuery,
          fontSize: settingsProvider.fontSize,
          prettyPrint: settingsProvider.xmlPrettyPrint,
        );
      case FileFormat.csv:
        return CsvViewer(
          content: content,
          searchQuery: _searchQuery,
          delimiter: settingsProvider.csvDelimiter,
        );
      case FileFormat.markdown:
        return MarkdownViewer(
          content: content,
          fontSize: settingsProvider.fontSize,
        );
      default:
        return Center(child: Text('지원하지 않는 형식입니다: ${format.name}'));
    }
  }

  Widget _buildEditor(
    FileFormat format,
    FileProvider fileProvider,
    SettingsProvider settingsProvider,
  ) {
    switch (format) {
      case FileFormat.json:
        return JsonEditor(
          content: fileProvider.editedContent,
          onChanged: fileProvider.updateContent,
          fontSize: settingsProvider.fontSize,
          syntaxHighlighting: settingsProvider.syntaxHighlighting,
        );
      case FileFormat.xml:
        return XmlEditor(
          content: fileProvider.editedContent,
          onChanged: fileProvider.updateContent,
          fontSize: settingsProvider.fontSize,
          syntaxHighlighting: settingsProvider.syntaxHighlighting,
        );
      case FileFormat.csv:
        return CsvEditor(
          content: fileProvider.editedContent,
          onChanged: fileProvider.updateContent,
          delimiter: settingsProvider.csvDelimiter,
        );
      case FileFormat.markdown:
        return MarkdownEditor(
          content: fileProvider.editedContent,
          onChanged: fileProvider.updateContent,
          fontSize: settingsProvider.fontSize,
          syntaxHighlighting: settingsProvider.syntaxHighlighting,
        );
      default:
        return Center(child: Text('지원하지 않는 형식입니다: ${format.name}'));
    }
  }

  Widget? _buildFab(FileProvider fileProvider) {
    if (!fileProvider.isEditing) return null;

    return FloatingActionButton(
      onPressed: fileProvider.saveFile,
      child: const Icon(Icons.save),
    );
  }

  void _handleFormat(
    String action,
    FileProvider fileProvider,
    SettingsProvider settingsProvider,
  ) {
    final file = fileProvider.currentFile;
    if (file == null) return;

    String formatted;
    if (file.format == FileFormat.json) {
      formatted = action == 'pretty'
          ? Formatters.prettyPrintJson(fileProvider.isEditing ? fileProvider.editedContent : file.content)
          : Formatters.minifyJson(fileProvider.isEditing ? fileProvider.editedContent : file.content);
    } else {
      formatted = action == 'pretty'
          ? Formatters.prettyPrintXml(fileProvider.isEditing ? fileProvider.editedContent : file.content)
          : Formatters.minifyXml(fileProvider.isEditing ? fileProvider.editedContent : file.content);
    }

    if (fileProvider.isEditing) {
      fileProvider.updateContent(formatted);
    } else {
      fileProvider.openFromClipboard(formatted, file.format);
    }
  }

  void _shareFile(FileProvider fileProvider) {
    final content = fileProvider.isEditing
        ? fileProvider.editedContent
        : fileProvider.currentFile?.content ?? '';
    Share.share(content);
  }

  void _handleMenuAction(String action, FileProvider fileProvider) {
    switch (action) {
      case 'edit':
        fileProvider.setEditMode(!fileProvider.isEditing);
        break;
      case 'share':
        _shareFile(fileProvider);
        break;
      case 'close':
        fileProvider.closeFile();
        Navigator.pop(context);
        break;
    }
  }
}
