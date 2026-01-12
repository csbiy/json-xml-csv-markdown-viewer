import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../common/syntax_highlight_text_field.dart';

class MarkdownEditor extends StatefulWidget {
  final String content;
  final ValueChanged<String> onChanged;
  final double fontSize;
  final bool syntaxHighlighting;

  const MarkdownEditor({
    super.key,
    required this.content,
    required this.onChanged,
    this.fontSize = 14,
    this.syntaxHighlighting = true,
  });

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  late TextEditingController _controller;
  bool _showPreview = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.content);
  }

  @override
  void didUpdateWidget(MarkdownEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content &&
        widget.content != _controller.text) {
      _controller.text = widget.content;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _insertMarkdown(String before, [String after = '']) {
    final selection = _controller.selection;
    final text = _controller.text;
    final selectedText = selection.textInside(text);

    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '$before$selectedText$after',
    );

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + before.length + selectedText.length + after.length,
      ),
    );

    widget.onChanged(newText);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToolbar(),
        Expanded(
          child: _showPreview ? _buildSplitView() : _buildEditorOnly(),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          _buildToolbarButton(Icons.format_bold, () => _insertMarkdown('**', '**')),
          _buildToolbarButton(Icons.format_italic, () => _insertMarkdown('*', '*')),
          _buildToolbarButton(Icons.format_strikethrough, () => _insertMarkdown('~~', '~~')),
          const VerticalDivider(width: 16),
          _buildToolbarButton(Icons.title, () => _insertMarkdown('# ')),
          _buildToolbarButton(Icons.format_list_bulleted, () => _insertMarkdown('- ')),
          _buildToolbarButton(Icons.format_list_numbered, () => _insertMarkdown('1. ')),
          const VerticalDivider(width: 16),
          _buildToolbarButton(Icons.code, () => _insertMarkdown('`', '`')),
          _buildToolbarButton(Icons.link, () => _insertMarkdown('[', '](url)')),
          _buildToolbarButton(Icons.image, () => _insertMarkdown('![alt](', ')')),
          const Spacer(),
          IconButton(
            icon: Icon(_showPreview ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _showPreview = !_showPreview),
            tooltip: _showPreview ? '프리뷰 숨기기' : '프리뷰 보기',
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: onPressed,
      splashRadius: 20,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
    );
  }

  Widget _buildSplitView() {
    return Row(
      children: [
        Expanded(child: _buildEditorOnly()),
        Container(
          width: 1,
          color: Colors.grey.shade300,
        ),
        Expanded(child: _buildPreview()),
      ],
    );
  }

  Widget _buildEditorOnly() {
    if (!widget.syntaxHighlighting) {
      return TextField(
        controller: _controller,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: widget.fontSize,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
          hintText: 'Markdown을 입력하세요...',
        ),
        onChanged: widget.onChanged,
      );
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SyntaxHighlightedText(
            text: _controller.text,
            language: SyntaxLanguage.markdown,
            fontSize: widget.fontSize,
          ),
        ),
        TextField(
          controller: _controller,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: widget.fontSize,
            color: Colors.transparent,
          ),
          cursorColor: Theme.of(context).colorScheme.primary,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(16),
            hintText: 'Markdown을 입력하세요...',
          ),
          onChanged: (value) {
            widget.onChanged(value);
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Markdown(
        data: _controller.text,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(fontSize: widget.fontSize),
          h1: TextStyle(fontSize: widget.fontSize * 2, fontWeight: FontWeight.bold),
          h2: TextStyle(fontSize: widget.fontSize * 1.75, fontWeight: FontWeight.bold),
          h3: TextStyle(fontSize: widget.fontSize * 1.5, fontWeight: FontWeight.bold),
          code: TextStyle(
            fontFamily: 'monospace',
            fontSize: widget.fontSize * 0.9,
            backgroundColor: Colors.grey.shade200,
          ),
          codeblockDecoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
