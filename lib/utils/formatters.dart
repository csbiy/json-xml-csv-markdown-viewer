import 'dart:convert';
import 'package:xml/xml.dart';

class Formatters {
  static String prettyPrintJson(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (e) {
      return jsonString;
    }
  }

  static String minifyJson(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      return jsonEncode(decoded);
    } catch (e) {
      return jsonString;
    }
  }

  static String prettyPrintXml(String xmlString) {
    try {
      final document = XmlDocument.parse(xmlString);
      return document.toXmlString(pretty: true, indent: '  ');
    } catch (e) {
      return xmlString;
    }
  }

  static String minifyXml(String xmlString) {
    try {
      final document = XmlDocument.parse(xmlString);
      return document.toXmlString(pretty: false);
    } catch (e) {
      return xmlString;
    }
  }
}
