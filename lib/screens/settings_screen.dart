import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            children: [
              _buildSectionTitle('테마'),
              _buildThemeTile(context, settings),
              const Divider(),
              _buildSectionTitle('표시'),
              _buildFontSizeTile(context, settings),
              const Divider(),
              _buildSectionTitle('포맷 설정'),
              _buildCsvDelimiterTile(context, settings),
              SwitchListTile(
                title: const Text('JSON Pretty Print'),
                subtitle: const Text('JSON을 보기 좋게 포맷팅'),
                value: settings.jsonPrettyPrint,
                onChanged: settings.setJsonPrettyPrint,
              ),
              SwitchListTile(
                title: const Text('XML Pretty Print'),
                subtitle: const Text('XML을 보기 좋게 포맷팅'),
                value: settings.xmlPrettyPrint,
                onChanged: settings.setXmlPrettyPrint,
              ),
              const Divider(),
              _buildSectionTitle('파일'),
              _buildEncodingTile(context, settings),
              _buildMaxRecentFilesTile(context, settings),
              const Divider(),
              _buildSectionTitle('에디터'),
              SwitchListTile(
                title: const Text('구문 하이라이팅'),
                subtitle: const Text('코드에 색상 강조 적용'),
                value: settings.syntaxHighlighting,
                onChanged: settings.setSyntaxHighlighting,
              ),
              SwitchListTile(
                title: const Text('자동 저장'),
                subtitle: const Text('편집 중 자동으로 저장'),
                value: settings.autoSave,
                onChanged: settings.setAutoSave,
              ),
              const Divider(),
              _buildSectionTitle('정보'),
              const ListTile(
                title: Text('버전'),
                subtitle: Text('1.0.0'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context, SettingsProvider settings) {
    return ListTile(
      title: const Text('테마 모드'),
      subtitle: Text(_getThemeModeText(settings.themeMode)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeDialog(context, settings),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return '시스템 설정';
      case ThemeMode.light:
        return '라이트 모드';
      case ThemeMode.dark:
        return '다크 모드';
    }
  }

  void _showThemeDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('테마 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('시스템 설정'),
              value: ThemeMode.system,
              groupValue: settings.themeMode,
              onChanged: (value) {
                settings.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('라이트 모드'),
              value: ThemeMode.light,
              groupValue: settings.themeMode,
              onChanged: (value) {
                settings.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('다크 모드'),
              value: ThemeMode.dark,
              groupValue: settings.themeMode,
              onChanged: (value) {
                settings.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeTile(BuildContext context, SettingsProvider settings) {
    return ListTile(
      title: const Text('폰트 크기'),
      subtitle: Slider(
        value: settings.fontSize,
        min: 10,
        max: 24,
        divisions: 14,
        label: settings.fontSize.round().toString(),
        onChanged: settings.setFontSize,
      ),
      trailing: Text('${settings.fontSize.round()}'),
    );
  }

  Widget _buildCsvDelimiterTile(BuildContext context, SettingsProvider settings) {
    return ListTile(
      title: const Text('CSV 구분자'),
      subtitle: Text(_getDelimiterText(settings.csvDelimiter)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showDelimiterDialog(context, settings),
    );
  }

  String _getDelimiterText(String delimiter) {
    switch (delimiter) {
      case ',':
        return '콤마 (,)';
      case '\t':
        return '탭';
      case ';':
        return '세미콜론 (;)';
      case '|':
        return '파이프 (|)';
      default:
        return delimiter;
    }
  }

  void _showDelimiterDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CSV 구분자 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('콤마 (,)'),
              value: ',',
              groupValue: settings.csvDelimiter,
              onChanged: (value) {
                settings.setCsvDelimiter(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('탭'),
              value: '\t',
              groupValue: settings.csvDelimiter,
              onChanged: (value) {
                settings.setCsvDelimiter(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('세미콜론 (;)'),
              value: ';',
              groupValue: settings.csvDelimiter,
              onChanged: (value) {
                settings.setCsvDelimiter(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('파이프 (|)'),
              value: '|',
              groupValue: settings.csvDelimiter,
              onChanged: (value) {
                settings.setCsvDelimiter(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEncodingTile(BuildContext context, SettingsProvider settings) {
    return ListTile(
      title: const Text('기본 인코딩'),
      subtitle: Text(settings.defaultEncoding.displayName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showEncodingDialog(context, settings),
    );
  }

  void _showEncodingDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('인코딩 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: FileEncoding.values.map((encoding) {
            return RadioListTile<FileEncoding>(
              title: Text(encoding.displayName),
              value: encoding,
              groupValue: settings.defaultEncoding,
              onChanged: (value) {
                settings.setDefaultEncoding(value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMaxRecentFilesTile(BuildContext context, SettingsProvider settings) {
    return ListTile(
      title: const Text('최근 파일 개수'),
      subtitle: Slider(
        value: settings.maxRecentFiles.toDouble(),
        min: 5,
        max: 30,
        divisions: 25,
        label: settings.maxRecentFiles.toString(),
        onChanged: (value) => settings.setMaxRecentFiles(value.round()),
      ),
      trailing: Text('${settings.maxRecentFiles}'),
    );
  }
}
