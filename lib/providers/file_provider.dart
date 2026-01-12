import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/file_data.dart';
import '../models/app_settings.dart';

/// Undo/Redo 히스토리 항목
class EditHistoryEntry {
  final String content;
  final int cursorPosition;
  final DateTime timestamp;

  EditHistoryEntry({
    required this.content,
    this.cursorPosition = 0,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class FileProvider extends ChangeNotifier {
  FileData? _currentFile;
  List<FileData> _recentFiles = [];
  bool _isLoading = false;
  String? _error;
  bool _isEditing = false;
  String _editedContent = '';

  // Undo/Redo 히스토리
  final List<EditHistoryEntry> _undoStack = [];
  final List<EditHistoryEntry> _redoStack = [];
  static const int _maxHistorySize = 100;

  // 설정 참조
  int _maxRecentFiles = 10;
  FileEncoding _defaultEncoding = FileEncoding.utf8;

  FileData? get currentFile => _currentFile;
  List<FileData> get recentFiles => _recentFiles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEditing => _isEditing;
  String get editedContent => _editedContent;

  // Undo/Redo 상태
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  int get undoStackSize => _undoStack.length;
  int get redoStackSize => _redoStack.length;

  FileProvider() {
    _loadRecentFiles();
  }

  void updateSettings({int? maxRecentFiles, FileEncoding? defaultEncoding}) {
    if (maxRecentFiles != null) _maxRecentFiles = maxRecentFiles;
    if (defaultEncoding != null) _defaultEncoding = defaultEncoding;
  }

  Future<void> _loadRecentFiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentJson = prefs.getStringList('recentFiles') ?? [];
      _recentFiles = recentJson
          .map((json) => FileData.fromJson(jsonDecode(json)))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading recent files: $e');
    }
  }

  Future<void> _saveRecentFiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentJson = _recentFiles
          .take(_maxRecentFiles)
          .map((file) => jsonEncode(file.toJson()))
          .toList();
      await prefs.setStringList('recentFiles', recentJson);
    } catch (e) {
      debugPrint('Error saving recent files: $e');
    }
  }

  void _addToRecentFiles(FileData file) {
    _recentFiles.removeWhere((f) => f.path == file.path);
    _recentFiles.insert(0, file);
    if (_recentFiles.length > _maxRecentFiles) {
      _recentFiles = _recentFiles.take(_maxRecentFiles).toList();
    }
    _saveRecentFiles();
  }

  // Undo/Redo 메서드
  void _pushToUndoStack(String content, {int cursorPosition = 0}) {
    _undoStack.add(EditHistoryEntry(
      content: content,
      cursorPosition: cursorPosition,
    ));
    if (_undoStack.length > _maxHistorySize) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
  }

  void undo() {
    if (!canUndo) return;

    final current = EditHistoryEntry(content: _editedContent);
    _redoStack.add(current);

    final previous = _undoStack.removeLast();
    _editedContent = previous.content;
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;

    _undoStack.add(EditHistoryEntry(content: _editedContent));

    final next = _redoStack.removeLast();
    _editedContent = next.content;
    notifyListeners();
  }

  void clearHistory() {
    _undoStack.clear();
    _redoStack.clear();
  }

  Future<void> pickAndOpenFile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'xml', 'csv', 'tsv', 'md', 'markdown'],
      );

      if (result != null && result.files.single.path != null) {
        await openFile(result.files.single.path!);
      }
    } catch (e) {
      _error = '파일을 열 수 없습니다: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> openFile(String path, {FileEncoding? encoding}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final file = File(path);
      final useEncoding = encoding ?? _defaultEncoding;
      final content = await file.readAsString(encoding: _getEncodingCodec(useEncoding));
      final name = path.split('/').last;
      final format = FileData.getFormatFromExtension(name);

      _currentFile = FileData(
        name: name,
        path: path,
        content: content,
        format: format,
        encoding: useEncoding,
      );
      _editedContent = content;
      _isEditing = false;
      clearHistory();

      _addToRecentFiles(_currentFile!);
    } catch (e) {
      _error = '파일을 열 수 없습니다: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Encoding _getEncodingCodec(FileEncoding encoding) {
    switch (encoding) {
      case FileEncoding.utf8:
        return utf8;
      case FileEncoding.utf16:
        return utf8; // Dart doesn't have built-in UTF-16, using UTF-8
      case FileEncoding.latin1:
        return latin1;
      case FileEncoding.ascii:
        return ascii;
    }
  }

  void openFromClipboard(String content, FileFormat format) {
    final ext = FileData.getExtensionFromFormat(format);
    _currentFile = FileData(
      name: 'clipboard.$ext',
      path: '',
      content: content,
      format: format,
    );
    _editedContent = content;
    _isEditing = false;
    clearHistory();
    notifyListeners();
  }

  void createNewFile(FileFormat format) {
    final ext = FileData.getExtensionFromFormat(format);
    String defaultContent;
    switch (format) {
      case FileFormat.json:
        defaultContent = '{\n  \n}';
        break;
      case FileFormat.xml:
        defaultContent = '<?xml version="1.0" encoding="UTF-8"?>\n<root>\n  \n</root>';
        break;
      case FileFormat.csv:
        defaultContent = '';
        break;
      case FileFormat.markdown:
        defaultContent = '# 제목\n\n';
        break;
      default:
        defaultContent = '';
    }

    _currentFile = FileData(
      name: 'new.$ext',
      path: '',
      content: defaultContent,
      format: format,
    );
    _editedContent = defaultContent;
    _isEditing = true;
    clearHistory();
    notifyListeners();
  }

  void setEditMode(bool editing) {
    _isEditing = editing;
    if (editing && _currentFile != null) {
      _editedContent = _currentFile!.content;
    }
    notifyListeners();
  }

  void updateContent(String content, {bool saveToHistory = true}) {
    if (saveToHistory && _editedContent != content) {
      _pushToUndoStack(_editedContent);
    }
    _editedContent = content;
    notifyListeners();
  }

  Future<void> saveFile() async {
    if (_currentFile == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      if (_currentFile!.path.isNotEmpty) {
        // 기존 파일 덮어쓰기
        final file = File(_currentFile!.path);
        await file.writeAsString(_editedContent);
        _currentFile = _currentFile!.copyWith(content: _editedContent);
      } else {
        // 새 파일: 앱 문서 디렉토리에 저장
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/${_currentFile!.name}';
        final file = File(filePath);
        await file.writeAsString(_editedContent);

        _currentFile = _currentFile!.copyWith(
          path: filePath,
          content: _editedContent,
        );
        _addToRecentFiles(_currentFile!);
      }

      _isEditing = false;
    } catch (e) {
      _error = '파일을 저장할 수 없습니다: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> exportFile() async {
    if (_currentFile == null) return;

    try {
      // 임시 파일 생성 후 공유
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/${_currentFile!.name}';
      final file = File(filePath);
      await file.writeAsString(_editedContent);

      await Share.shareXFiles(
        [XFile(filePath)],
        subject: _currentFile!.name,
      );
    } catch (e) {
      _error = '파일을 내보낼 수 없습니다: $e';
      notifyListeners();
    }
  }

  void closeFile() {
    _currentFile = null;
    _editedContent = '';
    _isEditing = false;
    _error = null;
    clearHistory();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void removeFromRecent(String path) {
    _recentFiles.removeWhere((f) => f.path == path);
    _saveRecentFiles();
    notifyListeners();
  }
}
