import 'app_settings.dart';

enum FileFormat { json, xml, csv, markdown, unknown }

class FileData {
  final String name;
  final String path;
  final String content;
  final FileFormat format;
  final DateTime openedAt;
  final FileEncoding encoding;

  FileData({
    required this.name,
    required this.path,
    required this.content,
    required this.format,
    DateTime? openedAt,
    this.encoding = FileEncoding.utf8,
  }) : openedAt = openedAt ?? DateTime.now();

  static FileFormat getFormatFromExtension(String fileName) {
    final ext = fileName.toLowerCase().split('.').last;
    switch (ext) {
      case 'json':
        return FileFormat.json;
      case 'xml':
        return FileFormat.xml;
      case 'csv':
      case 'tsv':
        return FileFormat.csv;
      case 'md':
      case 'markdown':
        return FileFormat.markdown;
      default:
        return FileFormat.unknown;
    }
  }

  static String getExtensionFromFormat(FileFormat format) {
    switch (format) {
      case FileFormat.json:
        return 'json';
      case FileFormat.xml:
        return 'xml';
      case FileFormat.csv:
        return 'csv';
      case FileFormat.markdown:
        return 'md';
      case FileFormat.unknown:
        return 'txt';
    }
  }

  FileData copyWith({
    String? name,
    String? path,
    String? content,
    FileFormat? format,
    DateTime? openedAt,
    FileEncoding? encoding,
  }) {
    return FileData(
      name: name ?? this.name,
      path: path ?? this.path,
      content: content ?? this.content,
      format: format ?? this.format,
      openedAt: openedAt ?? this.openedAt,
      encoding: encoding ?? this.encoding,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'format': format.name,
      'openedAt': openedAt.toIso8601String(),
      'encoding': encoding.index,
    };
  }

  factory FileData.fromJson(Map<String, dynamic> json) {
    return FileData(
      name: json['name'] as String,
      path: json['path'] as String,
      content: '',
      format: FileFormat.values.firstWhere(
        (e) => e.name == json['format'],
        orElse: () => FileFormat.unknown,
      ),
      openedAt: DateTime.parse(json['openedAt'] as String),
      encoding: FileEncoding.values[json['encoding'] as int? ?? 0],
    );
  }
}
