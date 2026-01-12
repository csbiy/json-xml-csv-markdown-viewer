import 'package:flutter/material.dart';
import '../../utils/validators.dart';
import '../common/syntax_highlight_text_field.dart';

class JsonEditor extends StatefulWidget {
  final String content;
  final ValueChanged<String> onChanged;
  final double fontSize;
  final bool syntaxHighlighting;

  const JsonEditor({
    super.key,
    required this.content,
    required this.onChanged,
    this.fontSize = 14,
    this.syntaxHighlighting = true,
  });

  @override
  State<JsonEditor> createState() => _JsonEditorState();
}

class _JsonEditorState extends State<JsonEditor> {
  late TextEditingController _controller;
  ValidationResult? _validation;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.content);
    _validate();
  }

  @override
  void didUpdateWidget(JsonEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content &&
        widget.content != _controller.text) {
      _controller.text = widget.content;
      _validate();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validate() {
    setState(() {
      _validation = Validators.validateJson(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_validation != null && !_validation!.isValid)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.red.shade100,
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _validation!.error ?? 'Invalid JSON',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                if (_validation!.line != null)
                  Text(
                    'Line ${_validation!.line}',
                    style: const TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
        if (_validation != null && _validation!.isValid)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.green.shade100,
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 18),
                SizedBox(width: 8),
                Text('Valid JSON', style: TextStyle(color: Colors.green)),
              ],
            ),
          ),
        Expanded(
          child: widget.syntaxHighlighting
              ? _buildHighlightedEditor()
              : _buildPlainEditor(),
        ),
      ],
    );
  }

  Widget _buildPlainEditor() {
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
      ),
      onChanged: (value) {
        widget.onChanged(value);
        _validate();
      },
    );
  }

  Widget _buildHighlightedEditor() {
    return Stack(
      children: [
        // 하이라이팅된 텍스트 배경
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SyntaxHighlightedText(
            text: _controller.text,
            language: SyntaxLanguage.json,
            fontSize: widget.fontSize,
          ),
        ),
        // 투명 입력 필드
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
          ),
          onChanged: (value) {
            widget.onChanged(value);
            _validate();
            setState(() {}); // 하이라이팅 갱신
          },
        ),
      ],
    );
  }
}
