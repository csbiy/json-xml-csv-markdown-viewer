import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_xml_csv_markdown_viewer/main.dart';
import 'package:json_xml_csv_markdown_viewer/models/file_data.dart';
import 'package:json_xml_csv_markdown_viewer/utils/formatters.dart';
import 'package:json_xml_csv_markdown_viewer/utils/validators.dart';

void main() {
  group('FileData Model Tests', () {
    test('should detect JSON format from extension', () {
      expect(FileData.getFormatFromExtension('test.json'), FileFormat.json);
    });

    test('should detect XML format from extension', () {
      expect(FileData.getFormatFromExtension('test.xml'), FileFormat.xml);
    });

    test('should detect CSV format from extension', () {
      expect(FileData.getFormatFromExtension('test.csv'), FileFormat.csv);
    });

    test('should detect Markdown format from extension', () {
      expect(FileData.getFormatFromExtension('test.md'), FileFormat.markdown);
      expect(FileData.getFormatFromExtension('test.markdown'), FileFormat.markdown);
    });

    test('should return unknown for unsupported extensions', () {
      expect(FileData.getFormatFromExtension('test.txt'), FileFormat.unknown);
      expect(FileData.getFormatFromExtension('test.pdf'), FileFormat.unknown);
    });

    test('should get correct extension from format', () {
      expect(FileData.getExtensionFromFormat(FileFormat.json), 'json');
      expect(FileData.getExtensionFromFormat(FileFormat.xml), 'xml');
      expect(FileData.getExtensionFromFormat(FileFormat.csv), 'csv');
      expect(FileData.getExtensionFromFormat(FileFormat.markdown), 'md');
    });
  });

  group('JSON Formatter Tests', () {
    test('should pretty print JSON', () {
      const input = '{"name":"test","value":123}';
      final result = Formatters.prettyPrintJson(input);
      expect(result.contains('\n'), true);
      expect(result.contains('  '), true);
    });

    test('should minify JSON', () {
      const input = '''
{
  "name": "test",
  "value": 123
}
''';
      final result = Formatters.minifyJson(input);
      expect(result.contains('\n'), false);
      expect(result, '{"name":"test","value":123}');
    });

    test('should handle invalid JSON gracefully', () {
      const input = 'invalid json';
      final result = Formatters.prettyPrintJson(input);
      expect(result, input);
    });
  });

  group('XML Formatter Tests', () {
    test('should pretty print XML', () {
      const input = '<root><child>value</child></root>';
      final result = Formatters.prettyPrintXml(input);
      expect(result.contains('\n'), true);
    });

    test('should minify XML', () {
      const input = '<root>  <child>value</child>  </root>';
      final result = Formatters.minifyXml(input);
      // minified XML should be valid and return a result
      expect(result.isNotEmpty, true);
      expect(result.contains('<root>'), true);
    });

    test('should handle invalid XML gracefully', () {
      const input = 'invalid xml';
      final result = Formatters.prettyPrintXml(input);
      expect(result, input);
    });
  });

  group('JSON Validator Tests', () {
    test('should validate correct JSON', () {
      const validJson = '{"name": "test", "value": 123}';
      final result = Validators.validateJson(validJson);
      expect(result.isValid, true);
    });

    test('should invalidate incorrect JSON', () {
      const invalidJson = '{name: "test"}';
      final result = Validators.validateJson(invalidJson);
      expect(result.isValid, false);
      expect(result.error, isNotNull);
    });

    test('should invalidate empty content', () {
      final result = Validators.validateJson('');
      expect(result.isValid, false);
    });

    test('should validate JSON array', () {
      const jsonArray = '[1, 2, 3]';
      final result = Validators.validateJson(jsonArray);
      expect(result.isValid, true);
    });
  });

  group('XML Validator Tests', () {
    test('should validate correct XML', () {
      const validXml = '<?xml version="1.0"?><root><child>value</child></root>';
      final result = Validators.validateXml(validXml);
      expect(result.isValid, true);
    });

    test('should invalidate incorrect XML', () {
      const invalidXml = '<root><child>value</root>';
      final result = Validators.validateXml(invalidXml);
      expect(result.isValid, false);
    });

    test('should invalidate empty content', () {
      final result = Validators.validateXml('');
      expect(result.isValid, false);
    });
  });

  group('CSV Validator Tests', () {
    test('should validate non-empty CSV', () {
      const csv = 'name,value\ntest,123';
      final result = Validators.validateCsv(csv);
      expect(result.isValid, true);
    });

    test('should invalidate empty CSV', () {
      final result = Validators.validateCsv('');
      expect(result.isValid, false);
    });
  });

  group('Widget Tests', () {
    testWidgets('App should render home screen', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('json-xml-csv-markdown-viewer'), findsOneWidget);
      expect(find.text('파일 열기'), findsOneWidget);
      expect(find.text('새 파일 만들기'), findsOneWidget);
    });

    testWidgets('Should show format chips for new file creation', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('JSON'), findsOneWidget);
      expect(find.text('XML'), findsOneWidget);
      expect(find.text('CSV'), findsOneWidget);
      expect(find.text('Markdown'), findsOneWidget);
    });

    testWidgets('Should navigate to settings', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('설정'), findsOneWidget);
      expect(find.text('테마 모드'), findsOneWidget);
      expect(find.text('폰트 크기'), findsOneWidget);
    });

    testWidgets('Should create new JSON file', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('JSON'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('Should create new Markdown file', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Markdown'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.save), findsOneWidget);
    });
  });
}
