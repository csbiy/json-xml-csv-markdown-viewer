import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import '../../utils/validators.dart';

class XmlViewer extends StatefulWidget {
  final String content;
  final String searchQuery;
  final double fontSize;
  final bool prettyPrint;

  const XmlViewer({
    super.key,
    required this.content,
    this.searchQuery = '',
    this.fontSize = 14,
    this.prettyPrint = true,
  });

  @override
  State<XmlViewer> createState() => _XmlViewerState();
}

class _XmlViewerState extends State<XmlViewer> {
  XmlDocument? _document;
  bool _isValid = true;
  String _errorMessage = '';
  final Set<String> _expandedPaths = {'root'};

  // XPath 검색
  final TextEditingController _xpathController = TextEditingController();
  Set<String> _xpathMatchedPaths = {};
  String? _xpathError;
  int _xpathMatchCount = 0;

  @override
  void initState() {
    super.initState();
    _parseXml();
  }

  @override
  void dispose() {
    _xpathController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(XmlViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _parseXml();
      _clearXPathSearch();
    }
  }

  void _parseXml() {
    final validation = Validators.validateXml(widget.content);
    if (validation.isValid) {
      _document = XmlDocument.parse(widget.content);
      _isValid = true;
      _errorMessage = '';
    } else {
      _isValid = false;
      _errorMessage = validation.error ?? 'Invalid XML';
    }
  }

  void _clearXPathSearch() {
    _xpathController.clear();
    _xpathMatchedPaths = {};
    _xpathError = null;
    _xpathMatchCount = 0;
  }

  void _executeXPathSearch(String xpath) {
    if (xpath.isEmpty || _document == null) {
      setState(() {
        _xpathMatchedPaths = {};
        _xpathError = null;
        _xpathMatchCount = 0;
      });
      return;
    }

    try {
      final matchedPaths = <String>{};
      _searchXPath(_document!.rootElement, 'root', xpath, matchedPaths);

      setState(() {
        _xpathMatchedPaths = matchedPaths;
        _xpathMatchCount = matchedPaths.length;
        _xpathError = null;

        // 매칭된 경로의 상위 경로들도 확장
        for (final path in matchedPaths) {
          _expandParentPaths(path);
        }
      });
    } catch (e) {
      setState(() {
        _xpathError = 'XPath 오류: $e';
        _xpathMatchedPaths = {};
        _xpathMatchCount = 0;
      });
    }
  }

  void _expandParentPaths(String path) {
    final parts = path.split('/');
    var currentPath = '';
    for (final part in parts) {
      if (currentPath.isEmpty) {
        currentPath = part;
      } else {
        currentPath = '$currentPath/$part';
      }
      _expandedPaths.add(currentPath);
    }
  }

  void _searchXPath(XmlElement element, String currentPath, String xpath, Set<String> matchedPaths) {
    // 간단한 XPath 지원: /tag, //tag, /tag/subtag, //tag[@attr='value']
    final normalizedXpath = xpath.trim();

    if (normalizedXpath.startsWith('//')) {
      // 자손 검색
      final pattern = normalizedXpath.substring(2);
      _searchDescendant(element, currentPath, pattern, matchedPaths);
    } else if (normalizedXpath.startsWith('/')) {
      // 절대 경로
      final pattern = normalizedXpath.substring(1);
      _searchAbsolute(element, currentPath, pattern, matchedPaths);
    } else {
      // 상대 경로로 처리
      _searchAbsolute(element, currentPath, normalizedXpath, matchedPaths);
    }
  }

  void _searchDescendant(XmlElement element, String currentPath, String pattern, Set<String> matchedPaths) {
    final patternInfo = _parsePattern(pattern);

    if (_matchesPattern(element, patternInfo)) {
      matchedPaths.add(currentPath);
    }

    for (final child in element.childElements) {
      final childPath = '$currentPath/${child.name.local}';
      _searchDescendant(child, childPath, pattern, matchedPaths);
    }
  }

  void _searchAbsolute(XmlElement element, String currentPath, String pattern, Set<String> matchedPaths) {
    if (pattern.isEmpty) return;

    final parts = pattern.split('/');
    if (parts.isEmpty) return;

    final firstPart = parts[0];
    final patternInfo = _parsePattern(firstPart);
    final remainingPath = parts.length > 1 ? parts.sublist(1).join('/') : '';

    for (final child in element.childElements) {
      if (_matchesPattern(child, patternInfo)) {
        final childPath = '$currentPath/${child.name.local}';
        if (remainingPath.isEmpty) {
          matchedPaths.add(childPath);
        } else {
          _searchAbsolute(child, childPath, remainingPath, matchedPaths);
        }
      }
    }

    // 현재 요소도 검사
    if (_matchesPattern(element, patternInfo)) {
      if (remainingPath.isEmpty) {
        matchedPaths.add(currentPath);
      }
    }
  }

  Map<String, String?> _parsePattern(String pattern) {
    // tag[@attr='value'] 형태 파싱
    final attrMatch = RegExp('^(\\w+)\\[@(\\w+)=[\'"]([^\'"]+)[\'"]\\]\$').firstMatch(pattern);
    if (attrMatch != null) {
      return {
        'tag': attrMatch.group(1),
        'attr': attrMatch.group(2),
        'value': attrMatch.group(3),
      };
    }

    // tag[@attr] 형태 파싱
    final attrExistsMatch = RegExp(r'^(\w+)\[@(\w+)\]$').firstMatch(pattern);
    if (attrExistsMatch != null) {
      return {
        'tag': attrExistsMatch.group(1),
        'attr': attrExistsMatch.group(2),
        'value': null,
      };
    }

    // 단순 태그
    return {'tag': pattern, 'attr': null, 'value': null};
  }

  bool _matchesPattern(XmlElement element, Map<String, String?> patternInfo) {
    final tag = patternInfo['tag'];
    final attr = patternInfo['attr'];
    final value = patternInfo['value'];

    // * 는 모든 요소와 일치
    if (tag != '*' && element.name.local != tag) {
      return false;
    }

    if (attr != null) {
      final attrValue = element.getAttribute(attr);
      if (attrValue == null) return false;
      if (value != null && attrValue != value) return false;
    }

    return true;
  }

  void _copyXPath(String path) {
    // root/users/user -> /users/user 형태로 변환
    final xpath = path.replaceFirst('root', '');
    Clipboard.setData(ClipboardData(text: xpath.isEmpty ? '/' : xpath));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('XPath 복사됨: ${xpath.isEmpty ? '/' : xpath}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isValid) {
      return _buildErrorView();
    }

    return Column(
      children: [
        _buildXPathSearchBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final node in _document!.children)
                  _buildNode(node, 'root', 0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildXPathSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _xpathController,
                  decoration: InputDecoration(
                    hintText: 'XPath 검색 (예: //user, /root/items)',
                    prefixIcon: const Icon(Icons.code),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_xpathMatchCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Chip(
                              label: Text('$_xpathMatchCount 개'),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _xpathController.clear();
                            _executeXPathSearch('');
                          },
                        ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                  onChanged: _executeXPathSearch,
                ),
              ),
            ],
          ),
          if (_xpathError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _xpathError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
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
              'XML 파싱 오류',
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

  Widget _buildNode(XmlNode node, String path, int depth) {
    if (node is XmlElement) {
      return _buildElement(node, path, depth);
    } else if (node is XmlText) {
      final text = node.value.trim();
      if (text.isEmpty) return const SizedBox.shrink();
      return _buildText(text);
    } else if (node is XmlComment) {
      return _buildComment(node.value);
    } else if (node is XmlDeclaration) {
      return _buildDeclaration(node);
    }
    return const SizedBox.shrink();
  }

  Widget _buildElement(XmlElement element, String path, int depth) {
    final elementPath = '$path/${element.name.local}';
    final isExpanded = _expandedPaths.contains(elementPath);
    final hasChildren = element.children.any((n) =>
        n is XmlElement || (n is XmlText && n.value.trim().isNotEmpty));

    final isHighlighted = widget.searchQuery.isNotEmpty &&
        element.name.local.toLowerCase().contains(widget.searchQuery.toLowerCase());

    final isXPathMatched = _xpathMatchedPaths.contains(elementPath);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: hasChildren
              ? () => setState(() {
                    if (isExpanded) {
                      _expandedPaths.remove(elementPath);
                    } else {
                      _expandedPaths.add(elementPath);
                    }
                  })
              : null,
          onLongPress: () => _copyXPath(elementPath),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            decoration: BoxDecoration(
              color: isXPathMatched
                  ? Colors.green.withOpacity(0.3)
                  : (isHighlighted ? Colors.yellow.withOpacity(0.5) : null),
              borderRadius: BorderRadius.circular(4),
              border: isXPathMatched
                  ? Border.all(color: Colors.green, width: 2)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasChildren)
                  Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    size: widget.fontSize + 4,
                  )
                else
                  SizedBox(width: widget.fontSize + 4),
                Text(
                  '<',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: widget.fontSize,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  element.name.local,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: widget.fontSize,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ..._buildAttributes(element.attributes),
                Text(
                  hasChildren ? '>' : '/>',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: widget.fontSize,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded && hasChildren)
          Padding(
            padding: EdgeInsets.only(left: widget.fontSize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final child in element.children)
                  _buildNode(child, elementPath, depth + 1),
              ],
            ),
          ),
        if (isExpanded && hasChildren)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: widget.fontSize + 4),
              Text(
                '</',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: widget.fontSize,
                  color: Colors.grey,
                ),
              ),
              Text(
                element.name.local,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: widget.fontSize,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '>',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: widget.fontSize,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
      ],
    );
  }

  List<Widget> _buildAttributes(List<XmlAttribute> attributes) {
    if (attributes.isEmpty) return [];

    return [
      for (final attr in attributes) ...[
        const Text(' '),
        Text(
          attr.name.local,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: widget.fontSize,
            color: Colors.orange.shade700,
          ),
        ),
        Text(
          '=',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: widget.fontSize,
            color: Colors.grey,
          ),
        ),
        Text(
          '"${attr.value}"',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: widget.fontSize,
            color: Colors.green.shade700,
          ),
        ),
      ],
    ];
  }

  Widget _buildText(String text) {
    final isHighlighted = widget.searchQuery.isNotEmpty &&
        text.toLowerCase().contains(widget.searchQuery.toLowerCase());

    return Container(
      color: isHighlighted ? Colors.yellow.withOpacity(0.5) : null,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: widget.fontSize,
        ),
      ),
    );
  }

  Widget _buildComment(String comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '<!-- $comment -->',
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: widget.fontSize,
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildDeclaration(XmlDeclaration declaration) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '<?xml${declaration.attributes.map((a) => ' ${a.name.local}="${a.value}"').join()}?>',
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: widget.fontSize,
          color: Colors.purple,
        ),
      ),
    );
  }
}
