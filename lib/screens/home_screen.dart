import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/file_data.dart';
import '../providers/file_provider.dart';
import '../widgets/common/format_icon.dart';
import 'viewer_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('json-xml-csv-markdown-viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<FileProvider>(
        builder: (context, fileProvider, _) {
          if (fileProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildActionButtons(context, fileProvider),
                const SizedBox(height: 24),
                _buildNewFileSection(context, fileProvider),
                const SizedBox(height: 24),
                _buildRecentFilesSection(context, fileProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, FileProvider fileProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '파일 열기',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await fileProvider.pickAndOpenFile();
                      if (context.mounted && fileProvider.currentFile != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ViewerScreen(),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.folder_open),
                    label: const Text('파일 선택'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showClipboardDialog(context, fileProvider),
                    icon: const Icon(Icons.paste),
                    label: const Text('클립보드'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewFileSection(BuildContext context, FileProvider fileProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '새 파일 만들기',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFormatChip(context, fileProvider, FileFormat.json, 'JSON'),
                _buildFormatChip(context, fileProvider, FileFormat.xml, 'XML'),
                _buildFormatChip(context, fileProvider, FileFormat.csv, 'CSV'),
                _buildFormatChip(context, fileProvider, FileFormat.markdown, 'Markdown'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatChip(
    BuildContext context,
    FileProvider fileProvider,
    FileFormat format,
    String label,
  ) {
    return ActionChip(
      avatar: FormatIcon(format: format, size: 18),
      label: Text(label),
      onPressed: () {
        fileProvider.createNewFile(format);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ViewerScreen()),
        );
      },
    );
  }

  Widget _buildRecentFilesSection(BuildContext context, FileProvider fileProvider) {
    if (fileProvider.recentFiles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '최근 파일',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: fileProvider.recentFiles.length,
              itemBuilder: (context, index) {
                final file = fileProvider.recentFiles[index];
                return ListTile(
                  leading: FormatIcon(format: file.format),
                  title: Text(file.name),
                  subtitle: Text(
                    file.path,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => fileProvider.removeFromRecent(file.path),
                  ),
                  onTap: () async {
                    await fileProvider.openFile(file.path);
                    if (context.mounted && fileProvider.currentFile != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ViewerScreen(),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClipboardDialog(BuildContext context, FileProvider fileProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('클립보드에서 가져오기'),
        content: const Text('어떤 형식으로 열까요?'),
        actions: [
          TextButton(
            onPressed: () => _pasteAsFormat(context, fileProvider, FileFormat.json),
            child: const Text('JSON'),
          ),
          TextButton(
            onPressed: () => _pasteAsFormat(context, fileProvider, FileFormat.xml),
            child: const Text('XML'),
          ),
          TextButton(
            onPressed: () => _pasteAsFormat(context, fileProvider, FileFormat.csv),
            child: const Text('CSV'),
          ),
          TextButton(
            onPressed: () => _pasteAsFormat(context, fileProvider, FileFormat.markdown),
            child: const Text('Markdown'),
          ),
        ],
      ),
    );
  }

  Future<void> _pasteAsFormat(
    BuildContext context,
    FileProvider fileProvider,
    FileFormat format,
  ) async {
    Navigator.pop(context);
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && context.mounted) {
      fileProvider.openFromClipboard(data!.text!, format);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ViewerScreen()),
      );
    }
  }
}
