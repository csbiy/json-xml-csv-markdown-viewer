import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class SettingsProvider extends ChangeNotifier {
  AppSettings _settings = const AppSettings();

  AppSettings get settings => _settings;
  ThemeMode get themeMode => _settings.themeMode;
  double get fontSize => _settings.fontSize;
  String get csvDelimiter => _settings.csvDelimiter;
  bool get jsonPrettyPrint => _settings.jsonPrettyPrint;
  bool get xmlPrettyPrint => _settings.xmlPrettyPrint;
  FileEncoding get defaultEncoding => _settings.defaultEncoding;
  bool get syntaxHighlighting => _settings.syntaxHighlighting;
  bool get autoSave => _settings.autoSave;
  int get maxRecentFiles => _settings.maxRecentFiles;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('settings');
      if (settingsJson != null) {
        _settings = AppSettings.fromJson(jsonDecode(settingsJson));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('settings', jsonEncode(_settings.toJson()));
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  void setThemeMode(ThemeMode mode) {
    _settings = _settings.copyWith(themeMode: mode);
    _saveSettings();
    notifyListeners();
  }

  void setFontSize(double size) {
    _settings = _settings.copyWith(fontSize: size);
    _saveSettings();
    notifyListeners();
  }

  void setCsvDelimiter(String delimiter) {
    _settings = _settings.copyWith(csvDelimiter: delimiter);
    _saveSettings();
    notifyListeners();
  }

  void setJsonPrettyPrint(bool value) {
    _settings = _settings.copyWith(jsonPrettyPrint: value);
    _saveSettings();
    notifyListeners();
  }

  void setXmlPrettyPrint(bool value) {
    _settings = _settings.copyWith(xmlPrettyPrint: value);
    _saveSettings();
    notifyListeners();
  }

  void setDefaultEncoding(FileEncoding encoding) {
    _settings = _settings.copyWith(defaultEncoding: encoding);
    _saveSettings();
    notifyListeners();
  }

  void setSyntaxHighlighting(bool value) {
    _settings = _settings.copyWith(syntaxHighlighting: value);
    _saveSettings();
    notifyListeners();
  }

  void setAutoSave(bool value) {
    _settings = _settings.copyWith(autoSave: value);
    _saveSettings();
    notifyListeners();
  }

  void setMaxRecentFiles(int value) {
    _settings = _settings.copyWith(maxRecentFiles: value);
    _saveSettings();
    notifyListeners();
  }
}
