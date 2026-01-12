import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownViewer extends StatelessWidget {
  final String content;
  final double fontSize;

  const MarkdownViewer({
    super.key,
    required this.content,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Markdown(
      data: content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(fontSize: fontSize),
        h1: TextStyle(fontSize: fontSize * 2, fontWeight: FontWeight.bold),
        h2: TextStyle(fontSize: fontSize * 1.75, fontWeight: FontWeight.bold),
        h3: TextStyle(fontSize: fontSize * 1.5, fontWeight: FontWeight.bold),
        h4: TextStyle(fontSize: fontSize * 1.25, fontWeight: FontWeight.bold),
        h5: TextStyle(fontSize: fontSize * 1.1, fontWeight: FontWeight.bold),
        h6: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        code: TextStyle(
          fontFamily: 'monospace',
          fontSize: fontSize * 0.9,
          backgroundColor: Colors.grey.shade200,
        ),
        codeblockDecoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Colors.grey.shade400,
              width: 4,
            ),
          ),
        ),
        listBullet: TextStyle(fontSize: fontSize),
        tableHead: const TextStyle(fontWeight: FontWeight.bold),
        tableBody: TextStyle(fontSize: fontSize),
        tableBorder: TableBorder.all(color: Colors.grey.shade300),
        tableCellsPadding: const EdgeInsets.all(8),
      ),
    );
  }
}
