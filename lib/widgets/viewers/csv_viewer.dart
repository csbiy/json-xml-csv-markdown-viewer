import 'package:flutter/material.dart';
import 'package:csv/csv.dart';

class CsvViewer extends StatefulWidget {
  final String content;
  final String searchQuery;
  final String delimiter;

  const CsvViewer({
    super.key,
    required this.content,
    this.searchQuery = '',
    this.delimiter = ',',
  });

  @override
  State<CsvViewer> createState() => _CsvViewerState();
}

class _CsvViewerState extends State<CsvViewer> {
  List<List<dynamic>> _data = [];
  int? _sortColumnIndex;
  bool _sortAscending = true;
  int? _filterColumnIndex;
  String _filterValue = '';

  @override
  void initState() {
    super.initState();
    _parseCsv();
  }

  @override
  void didUpdateWidget(CsvViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content ||
        oldWidget.delimiter != widget.delimiter) {
      _parseCsv();
    }
  }

  void _parseCsv() {
    try {
      final converter = CsvToListConverter(
        fieldDelimiter: widget.delimiter,
        eol: '\n',
      );
      _data = converter.convert(widget.content);
    } catch (e) {
      _data = [];
    }
  }

  void _sort(int columnIndex) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAscending = true;
      }

      if (_data.length > 1) {
        final header = _data[0];
        final rows = _data.sublist(1);
        rows.sort((a, b) {
          final aValue = columnIndex < a.length ? a[columnIndex] : '';
          final bValue = columnIndex < b.length ? b[columnIndex] : '';
          final comparison = aValue.toString().compareTo(bValue.toString());
          return _sortAscending ? comparison : -comparison;
        });
        _data = [header, ...rows];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_data.isEmpty) {
      return const Center(child: Text('데이터가 없습니다'));
    }

    final filteredData = _filterData();

    return Column(
      children: [
        if (_filterColumnIndex != null) _buildFilterBar(),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                columns: _buildColumns(),
                rows: _buildRows(filteredData),
              ),
            ),
          ),
        ),
        _buildStatusBar(filteredData),
      ],
    );
  }

  Widget _buildFilterBar() {
    final columnName = _data[0][_filterColumnIndex!].toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        children: [
          Text('$columnName 필터: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: '필터 값 입력...',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) => setState(() => _filterValue = value),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() {
              _filterColumnIndex = null;
              _filterValue = '';
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(List<List<dynamic>> filteredData) {
    final totalRows = _data.length - 1;
    final filteredRows = filteredData.length - 1;
    return Container(
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$filteredRows / $totalRows 행'),
          Text('${_data.isNotEmpty ? _data[0].length : 0} 열'),
        ],
      ),
    );
  }

  List<List<dynamic>> _filterData() {
    var result = _data;

    // 검색 필터
    if (widget.searchQuery.isNotEmpty) {
      final query = widget.searchQuery.toLowerCase();
      result = [
        result[0],
        ...result.skip(1).where((row) {
          return row.any((cell) =>
              cell.toString().toLowerCase().contains(query));
        }),
      ];
    }

    // 열별 필터
    if (_filterColumnIndex != null && _filterValue.isNotEmpty) {
      final filterQuery = _filterValue.toLowerCase();
      result = [
        result[0],
        ...result.skip(1).where((row) {
          if (_filterColumnIndex! < row.length) {
            return row[_filterColumnIndex!]
                .toString()
                .toLowerCase()
                .contains(filterQuery);
          }
          return false;
        }),
      ];
    }

    return result;
  }

  List<DataColumn> _buildColumns() {
    if (_data.isEmpty) return [];

    final headers = _data[0];
    return List.generate(headers.length, (index) {
      final isFiltered = _filterColumnIndex == index;
      return DataColumn(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              headers[index].toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => setState(() {
                if (isFiltered) {
                  _filterColumnIndex = null;
                  _filterValue = '';
                } else {
                  _filterColumnIndex = index;
                  _filterValue = '';
                }
              }),
              child: Icon(
                Icons.filter_alt,
                size: 16,
                color: isFiltered ? Theme.of(context).colorScheme.primary : Colors.grey,
              ),
            ),
          ],
        ),
        onSort: (columnIndex, ascending) => _sort(columnIndex),
      );
    });
  }

  List<DataRow> _buildRows(List<List<dynamic>> data) {
    if (data.length <= 1) return [];

    return data.skip(1).map((row) {
      final columnCount = _data[0].length;
      return DataRow(
        cells: List.generate(columnCount, (index) {
          final cellValue = index < row.length ? row[index].toString() : '';
          final isHighlighted = widget.searchQuery.isNotEmpty &&
              cellValue.toLowerCase().contains(widget.searchQuery.toLowerCase());

          return DataCell(
            Container(
              color: isHighlighted ? Colors.yellow.withOpacity(0.5) : null,
              child: Text(cellValue),
            ),
          );
        }),
      );
    }).toList();
  }
}
