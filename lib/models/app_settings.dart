import 'package:flutter/material.dart';

/// 지원하는 파일 인코딩 목록
enum FileEncoding {
  utf8('UTF-8'),
  utf16('UTF-16'),
  latin1('ISO-8859-1'),
  ascii('ASCII');

  final String displayName;
  const FileEncoding(this.displayName);
}

/// 앱 설정 모델
class AppSettings {
  final ThemeMode themeMode;
  final double fontSize;
  final String csvDelimiter;
  final bool jsonPrettyPrint;
  final bool xmlPrettyPrint;
  final FileEncoding defaultEncoding;
  final bool syntaxHighlighting;
  final bool autoSave;
  final int maxRecentFiles;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.fontSize = 14.0,
    this.csvDelimiter = ',',
    this.jsonPrettyPrint = true,
    this.xmlPrettyPrint = true,
    this.defaultEncoding = FileEncoding.utf8,
    this.syntaxHighlighting = true,
    this.autoSave = false,
    this.maxRecentFiles = 10,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    double? fontSize,
    String? csvDelimiter,
    bool? jsonPrettyPrint,
    bool? xmlPrettyPrint,
    FileEncoding? defaultEncoding,
    bool? syntaxHighlighting,
    bool? autoSave,
    int? maxRecentFiles,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      csvDelimiter: csvDelimiter ?? this.csvDelimiter,
      jsonPrettyPrint: jsonPrettyPrint ?? this.jsonPrettyPrint,
      xmlPrettyPrint: xmlPrettyPrint ?? this.xmlPrettyPrint,
      defaultEncoding: defaultEncoding ?? this.defaultEncoding,
      syntaxHighlighting: syntaxHighlighting ?? this.syntaxHighlighting,
      autoSave: autoSave ?? this.autoSave,
      maxRecentFiles: maxRecentFiles ?? this.maxRecentFiles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'fontSize': fontSize,
      'csvDelimiter': csvDelimiter,
      'jsonPrettyPrint': jsonPrettyPrint,
      'xmlPrettyPrint': xmlPrettyPrint,
      'defaultEncoding': defaultEncoding.index,
      'syntaxHighlighting': syntaxHighlighting,
      'autoSave': autoSave,
      'maxRecentFiles': maxRecentFiles,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: ThemeMode.values[json['themeMode'] as int? ?? 0],
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14.0,
      csvDelimiter: json['csvDelimiter'] as String? ?? ',',
      jsonPrettyPrint: json['jsonPrettyPrint'] as bool? ?? true,
      xmlPrettyPrint: json['xmlPrettyPrint'] as bool? ?? true,
      defaultEncoding: FileEncoding.values[json['defaultEncoding'] as int? ?? 0],
      syntaxHighlighting: json['syntaxHighlighting'] as bool? ?? true,
      autoSave: json['autoSave'] as bool? ?? false,
      maxRecentFiles: json['maxRecentFiles'] as int? ?? 10,
    );
  }
}
