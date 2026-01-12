import 'package:flutter/material.dart';
import 'package:csv/csv.dart';

class CsvEditor extends StatefulWidget {
  final String content;
  final ValueChanged<String> onChanged;
  final String delimiter;

  const CsvEditor({
    super.key,
    required this.content,
    required this.onChanged,
    this.delimiter = ',',
  });

  @override
  State<CsvEditor> createState() => _CsvEditorState();
}

class _CsvEditorState extends State<CsvEditor> {
  List<List<String>> _data = [];
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _parseCsv();
  }

  @override
  void didUpdateWidget(CsvEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content ||
        oldWidget.delimiter != widget.delimiter) {
      _parseCsv();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _parseCsv() {
    try {
      final converter = CsvToListConverter(
        fieldDelimiter: widget.delimiter,
        eol: '\n',
      );
      final parsed = converter.convert(widget.content);
      _data = parsed.map((row) => row.map((e) => e.toString()).toList()).toList();
    } catch (e) {
      _data = [];
    }
    _updateControllers();
  }

  void _updateControllers() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();

    for (final row in _data) {
      for (final cell in row) {
        _controllers.add(TextEditingController(text: cell));
      }
    }
  }

  void _updateContent() {
    final converter = ListToCsvConverter(
      fieldDelimiter: widget.delimiter,
      eol: '\n',
    );
    final csv = converter.convert(_data);
    widget.onChanged(csv);
  }

  void _addRow() {
    setState(() {
      final columnCount = _data.isNotEmpty ? _data[0].length : 1;
      _data.add(List.filled(columnCount, ''));
      for (int i = 0; i < columnCount; i++) {
        _controllers.add(TextEditingController());
      }
    });
    _updateContent();
  }

  void _addColumn() {
    setState(() {
      for (int i = 0; i < _data.length; i++) {
        _data[i].add('');
        final insertIndex = (i + 1) * (_data[i].length) - 1;
        _controllers.insert(insertIndex, TextEditingController());
      }
    });
    _updateContent();
  }

  void _deleteRow(int rowIndex) {
    if (_data.length <= 1) return;
    setState(() {
      final columnCount = _data[rowIndex].length;
      final startIndex = rowIndex * columnCount;
      for (int i = 0; i < columnCount; i++) {
        _controllers[startIndex].dispose();
        _controllers.removeAt(startIndex);
      }
      _data.removeAt(rowIndex);
    });
    _updateContent();
  }

  void _deleteColumn(int columnIndex) {
    if (_data.isEmpty || _data[0].length <= 1) return;
    setState(() {
      for (int i = _data.length - 1; i >= 0; i--) {
        if (columnIndex < _data[i].length) {
          final controllerIndex = i * _data[i].length + columnIndex;
          if (controllerIndex < _controllers.length) {
            _controllers[controllerIndex].dispose();
            _controllers.removeAt(controllerIndex);
          }
          _data[i].removeAt(columnIndex);
        }
      }
    });
    _updateContent();
  }

  @override
  Widget build(BuildContext context) {
    if (_data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('데이터가 없습니다'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _data = [['']];
                  _controllers.add(TextEditingController());
                });
                _updateContent();
              },
              icon: const Icon(Icons.add),
              label: const Text('행 추가'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: _addRow,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('행 추가'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _addColumn,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('열 추가'),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columns: _buildColumns(),
                rows: _buildRows(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<DataColumn> _buildColumns() {
    if (_data.isEmpty) return [];

    final columnCount = _data[0].length;
    return [
      ...List.generate(columnCount, (index) {
        return DataColumn(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Column ${index + 1}'),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => _deleteColumn(index),
                child: const Icon(Icons.close, size: 16, color: Colors.red),
              ),
            ],
          ),
        );
      }),
      const DataColumn(label: Text('')),
    ];
  }

  List<DataRow> _buildRows() {
    return List.generate(_data.length, (rowIndex) {
      final columnCount = _data[0].length;
      return DataRow(
        cells: [
          ...List.generate(columnCount, (colIndex) {
            final controllerIndex = rowIndex * columnCount + colIndex;
            if (controllerIndex >= _controllers.length) {
              return const DataCell(Text(''));
            }

            return DataCell(
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _controllers[controllerIndex],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: (value) {
                    if (colIndex < _data[rowIndex].length) {
                      _data[rowIndex][colIndex] = value;
                      _updateContent();
                    }
                  },
                ),
              ),
            );
          }),
          DataCell(
            InkWell(
              onTap: () => _deleteRow(rowIndex),
              child: const Icon(Icons.delete, size: 18, color: Colors.red),
            ),
          ),
        ],
      );
    });
  }
}
