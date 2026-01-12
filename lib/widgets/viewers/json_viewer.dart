import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/validators.dart';

class JsonViewer extends StatefulWidget {
  final String content;
  final String searchQuery;
  final double fontSize;
  final bool prettyPrint;

  const JsonViewer({
    super.key,
    required this.content,
    this.searchQuery = '',
    this.fontSize = 14,
    this.prettyPrint = true,
  });

  @override
  State<JsonViewer> createState() => _JsonViewerState();
}

class _JsonViewerState extends State<JsonViewer> {
  late dynamic _parsedJson;
  bool _isValid = true;
  String _errorMessage = '';
  final Set<String> _expandedPaths = {'root'};

  @override
  void initState() {
    super.initState();
    _parseJson();
  }

  @override
  void didUpdateWidget(JsonViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _parseJson();
    }
  }

  void _parseJson() {
    final validation = Validators.validateJson(widget.content);
    if (validation.isValid) {
      _parsedJson = jsonDecode(widget.content);
      _isValid = true;
      _errorMessage = '';
    } else {
      _isValid = false;
      _errorMessage = validation.error ?? 'Invalid JSON';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isValid) {
      return _buildErrorView();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildJsonTree(_parsedJson, 'root', 0),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'JSON 파싱 오류',
              style: TextStyle(fontSize: widget.fontSize + 2, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_errorMessage, style: TextStyle(fontSize: widget.fontSize)),
            const SizedBox(height: 16),
            const Text('원본 내용:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                widget.content,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: widget.fontSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJsonTree(dynamic value, String path, int depth) {
    if (value == null) {
      return _buildLeaf('null', Colors.grey, path);
    } else if (value is bool) {
      return _buildLeaf(value.toString(), Colors.blue, path);
    } else if (value is num) {
      return _buildLeaf(value.toString(), Colors.green, path);
    } else if (value is String) {
      return _buildLeaf('"$value"', Colors.orange, path);
    } else if (value is List) {
      return _buildArray(value, path, depth);
    } else if (value is Map) {
      return _buildObject(value as Map<String, dynamic>, path, depth);
    }
    return Text(value.toString());
  }

  String _pathToJsonPath(String path) {
    // root.users[0].name -> $.users[0].name
    return path.replaceFirst('root', '\$');
  }

  void _copyPath(String path) {
    final jsonPath = _pathToJsonPath(path);
    Clipboard.setData(ClipboardData(text: jsonPath));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('경로 복사됨: $jsonPath'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildLeaf(String text, Color color, String path) {
    final isHighlighted = widget.searchQuery.isNotEmpty &&
        text.toLowerCase().contains(widget.searchQuery.toLowerCase());

    return GestureDetector(
      onLongPress: () => _copyPath(path),
      child: Container(
        color: isHighlighted ? Colors.yellow.withOpacity(0.5) : null,
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontFamily: 'monospace',
            fontSize: widget.fontSize,
          ),
        ),
      ),
    );
  }

  Widget _buildArray(List value, String path, int depth) {
    final isExpanded = _expandedPaths.contains(path);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() {
            if (isExpanded) {
              _expandedPaths.remove(path);
            } else {
              _expandedPaths.add(path);
            }
          }),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isExpanded ? Icons.expand_more : Icons.chevron_right,
                size: widget.fontSize + 4,
              ),
              Text(
                'Array[${value.length}]',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: widget.fontSize,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ),
        if (isExpanded)
          Padding(
            padding: EdgeInsets.only(left: widget.fontSize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < value.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '[$i]: ',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: widget.fontSize,
                            color: Colors.grey,
                          ),
                        ),
                        Expanded(
                          child: _buildJsonTree(value[i], '$path[$i]', depth + 1),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildObject(Map<String, dynamic> value, String path, int depth) {
    final isExpanded = _expandedPaths.contains(path);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() {
            if (isExpanded) {
              _expandedPaths.remove(path);
            } else {
              _expandedPaths.add(path);
            }
          }),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isExpanded ? Icons.expand_more : Icons.chevron_right,
                size: widget.fontSize + 4,
              ),
              Text(
                'Object{${value.length}}',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: widget.fontSize,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
        ),
        if (isExpanded)
          Padding(
            padding: EdgeInsets.only(left: widget.fontSize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in value.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildKeyText(entry.key, '$path.${entry.key}'),
                        const Text(': '),
                        Expanded(
                          child: _buildJsonTree(
                            entry.value,
                            '$path.${entry.key}',
                            depth + 1,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildKeyText(String key, String path) {
    final isHighlighted = widget.searchQuery.isNotEmpty &&
        key.toLowerCase().contains(widget.searchQuery.toLowerCase());

    return GestureDetector(
      onLongPress: () => _copyPath(path),
      child: Container(
        color: isHighlighted ? Colors.yellow.withOpacity(0.5) : null,
        child: Text(
          '"$key"',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: widget.fontSize,
            color: Colors.red.shade700,
          ),
        ),
      ),
    );
  }
}
