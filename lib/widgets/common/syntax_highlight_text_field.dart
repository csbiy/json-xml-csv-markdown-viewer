import 'package:flutter/material.dart';

enum SyntaxLanguage { json, xml, markdown, plain }

class SyntaxHighlightTextField extends StatefulWidget {
  final TextEditingController controller;
  final SyntaxLanguage language;
  final double fontSize;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const SyntaxHighlightTextField({
    super.key,
    required this.controller,
    this.language = SyntaxLanguage.plain,
    this.fontSize = 14,
    this.enabled = true,
    this.onChanged,
  });

  @override
  State<SyntaxHighlightTextField> createState() =>
      _SyntaxHighlightTextFieldState();
}

class _SyntaxHighlightTextFieldState extends State<SyntaxHighlightTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      enabled: widget.enabled,
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: widget.fontSize,
      ),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(16),
      ),
      onChanged: widget.onChanged,
      buildCounter: (context,
              {required currentLength, required isFocused, maxLength}) =>
          null,
    );
  }
}

/// 구문 하이라이팅이 적용된 텍스트 스팬 생성
class SyntaxHighlighter {
  static List<TextSpan> highlight(String text, SyntaxLanguage language) {
    switch (language) {
      case SyntaxLanguage.json:
        return _highlightJson(text);
      case SyntaxLanguage.xml:
        return _highlightXml(text);
      case SyntaxLanguage.markdown:
        return _highlightMarkdown(text);
      case SyntaxLanguage.plain:
        return [TextSpan(text: text)];
    }
  }

  static List<TextSpan> _highlightJson(String text) {
    final spans = <TextSpan>[];
    final pattern = RegExp(
      r'("(?:[^"\\]|\\.)*")\s*:' // 키
      r'|("(?:[^"\\]|\\.)*")' // 문자열 값
      r'|(\b(?:true|false|null)\b)' // 불리언, null
      r'|(-?\d+\.?\d*(?:[eE][+-]?\d+)?)' // 숫자
      r'|([{}\[\]:,])', // 구분자
      multiLine: true,
    );

    int lastEnd = 0;
    for (final match in pattern.allMatches(text)) {
      // 매치 이전 텍스트
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }

      if (match.group(1) != null) {
        // 키
        spans.add(TextSpan(
          text: match.group(1),
          style: const TextStyle(color: Color(0xFFD32F2F)), // 빨간색
        ));
        spans.add(TextSpan(
          text: text.substring(match.start + match.group(1)!.length, match.end),
        ));
      } else if (match.group(2) != null) {
        // 문자열 값
        spans.add(TextSpan(
          text: match.group(2),
          style: const TextStyle(color: Color(0xFF388E3C)), // 녹색
        ));
      } else if (match.group(3) != null) {
        // 불리언, null
        spans.add(TextSpan(
          text: match.group(3),
          style: const TextStyle(color: Color(0xFF1976D2)), // 파란색
        ));
      } else if (match.group(4) != null) {
        // 숫자
        spans.add(TextSpan(
          text: match.group(4),
          style: const TextStyle(color: Color(0xFF7B1FA2)), // 보라색
        ));
      } else if (match.group(5) != null) {
        // 구분자
        spans.add(TextSpan(
          text: match.group(5),
          style: const TextStyle(color: Color(0xFF616161)), // 회색
        ));
      }

      lastEnd = match.end;
    }

    // 나머지 텍스트
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return spans;
  }

  static List<TextSpan> _highlightXml(String text) {
    final spans = <TextSpan>[];
    final pattern = RegExp(
      r'(<\?[^?]*\?>)' // XML 선언
      r'|(<!--[\s\S]*?-->)' // 주석
      r'|(</?\w+)' // 태그 시작
      r'|(\s+\w+)(?==)' // 속성명
      r'|("[^"]*"|' "'" r"[^']*'" r')' // 속성값
      r'|(>|/>)', // 태그 끝
      multiLine: true,
    );

    int lastEnd = 0;
    for (final match in pattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }

      if (match.group(1) != null) {
        // XML 선언
        spans.add(TextSpan(
          text: match.group(1),
          style: const TextStyle(color: Color(0xFF7B1FA2)), // 보라색
        ));
      } else if (match.group(2) != null) {
        // 주석
        spans.add(TextSpan(
          text: match.group(2),
          style: const TextStyle(
            color: Color(0xFF9E9E9E),
            fontStyle: FontStyle.italic,
          ), // 회색 이탤릭
        ));
      } else if (match.group(3) != null) {
        // 태그명
        spans.add(TextSpan(
          text: match.group(3),
          style: const TextStyle(color: Color(0xFF1976D2)), // 파란색
        ));
      } else if (match.group(4) != null) {
        // 속성명
        spans.add(TextSpan(
          text: match.group(4),
          style: const TextStyle(color: Color(0xFFE65100)), // 주황색
        ));
      } else if (match.group(5) != null) {
        // 속성값
        spans.add(TextSpan(
          text: match.group(5),
          style: const TextStyle(color: Color(0xFF388E3C)), // 녹색
        ));
      } else if (match.group(6) != null) {
        // 태그 끝
        spans.add(TextSpan(
          text: match.group(6),
          style: const TextStyle(color: Color(0xFF1976D2)), // 파란색
        ));
      }

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return spans;
  }

  static List<TextSpan> _highlightMarkdown(String text) {
    final spans = <TextSpan>[];
    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (i > 0) spans.add(const TextSpan(text: '\n'));

      // 헤더
      if (RegExp(r'^#{1,6}\s').hasMatch(line)) {
        final level = line.indexOf(' ');
        spans.add(TextSpan(
          text: line,
          style: TextStyle(
            color: const Color(0xFF1976D2),
            fontWeight: FontWeight.bold,
            fontSize: 18.0 - level,
          ),
        ));
      }
      // 코드 블록
      else if (line.startsWith('```')) {
        spans.add(TextSpan(
          text: line,
          style: const TextStyle(
            color: Color(0xFF7B1FA2),
            fontFamily: 'monospace',
          ),
        ));
      }
      // 인라인 코드
      else if (line.contains('`')) {
        _highlightInlineCode(line, spans);
      }
      // 볼드/이탤릭
      else if (line.contains('**') || line.contains('*')) {
        _highlightBoldItalic(line, spans);
      }
      // 링크
      else if (line.contains('[') && line.contains('](')) {
        _highlightLinks(line, spans);
      }
      // 리스트
      else if (RegExp(r'^\s*[-*+]\s').hasMatch(line) ||
          RegExp(r'^\s*\d+\.\s').hasMatch(line)) {
        spans.add(TextSpan(
          text: line,
          style: const TextStyle(color: Color(0xFF616161)),
        ));
      }
      // 인용문
      else if (line.startsWith('>')) {
        spans.add(TextSpan(
          text: line,
          style: const TextStyle(
            color: Color(0xFF757575),
            fontStyle: FontStyle.italic,
          ),
        ));
      }
      // 일반 텍스트
      else {
        spans.add(TextSpan(text: line));
      }
    }

    return spans;
  }

  static void _highlightInlineCode(String line, List<TextSpan> spans) {
    final pattern = RegExp(r'`([^`]+)`');
    int lastEnd = 0;

    for (final match in pattern.allMatches(line)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: line.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: const TextStyle(
          color: Color(0xFF7B1FA2),
          backgroundColor: Color(0xFFE0E0E0),
          fontFamily: 'monospace',
        ),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < line.length) {
      spans.add(TextSpan(text: line.substring(lastEnd)));
    }
  }

  static void _highlightBoldItalic(String line, List<TextSpan> spans) {
    final boldPattern = RegExp(r'\*\*([^*]+)\*\*');
    final italicPattern = RegExp(r'\*([^*]+)\*');
    int lastEnd = 0;

    // 볼드 먼저
    for (final match in boldPattern.allMatches(line)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: line.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < line.length) {
      final remaining = line.substring(lastEnd);
      // 이탤릭 처리
      int italicLastEnd = 0;
      for (final match in italicPattern.allMatches(remaining)) {
        if (match.start > italicLastEnd) {
          spans.add(TextSpan(text: remaining.substring(italicLastEnd, match.start)));
        }
        spans.add(TextSpan(
          text: match.group(0),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
        italicLastEnd = match.end;
      }
      if (italicLastEnd < remaining.length) {
        spans.add(TextSpan(text: remaining.substring(italicLastEnd)));
      }
    }
  }

  static void _highlightLinks(String line, List<TextSpan> spans) {
    final pattern = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');
    int lastEnd = 0;

    for (final match in pattern.allMatches(line)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: line.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: const TextStyle(
          color: Color(0xFF1976D2),
          decoration: TextDecoration.underline,
        ),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < line.length) {
      spans.add(TextSpan(text: line.substring(lastEnd)));
    }
  }
}

/// 구문 하이라이팅이 적용된 읽기 전용 텍스트 위젯
class SyntaxHighlightedText extends StatelessWidget {
  final String text;
  final SyntaxLanguage language;
  final double fontSize;

  const SyntaxHighlightedText({
    super.key,
    required this.text,
    this.language = SyntaxLanguage.plain,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final spans = SyntaxHighlighter.highlight(text, language);

    return SelectableText.rich(
      TextSpan(
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: fontSize,
        ),
        children: spans,
      ),
    );
  }
}
