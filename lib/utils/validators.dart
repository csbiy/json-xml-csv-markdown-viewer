import 'dart:convert';
import 'package:xml/xml.dart';

class ValidationResult {
  final bool isValid;
  final String? error;
  final int? line;
  final int? column;

  const ValidationResult({
    required this.isValid,
    this.error,
    this.line,
    this.column,
  });

  static const valid = ValidationResult(isValid: true);
}

class Validators {
  static ValidationResult validateJson(String content) {
    if (content.trim().isEmpty) {
      return const ValidationResult(
        isValid: false,
        error: '내용이 비어있습니다',
      );
    }

    try {
      jsonDecode(content);
      return ValidationResult.valid;
    } on FormatException catch (e) {
      return ValidationResult(
        isValid: false,
        error: e.message,
      );
    }
  }

  static ValidationResult validateXml(String content) {
    if (content.trim().isEmpty) {
      return const ValidationResult(
        isValid: false,
        error: '내용이 비어있습니다',
      );
    }

    try {
      XmlDocument.parse(content);
      return ValidationResult.valid;
    } on XmlParserException catch (e) {
      return ValidationResult(
        isValid: false,
        error: e.message,
        line: e.line,
        column: e.column,
      );
    } on XmlException catch (e) {
      return ValidationResult(
        isValid: false,
        error: e.message,
      );
    }
  }

  static ValidationResult validateCsv(String content) {
    if (content.trim().isEmpty) {
      return const ValidationResult(
        isValid: false,
        error: '내용이 비어있습니다',
      );
    }
    return ValidationResult.valid;
  }

  static ValidationResult validateMarkdown(String content) {
    return ValidationResult.valid;
  }
}
