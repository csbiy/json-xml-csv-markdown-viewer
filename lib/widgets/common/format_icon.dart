import 'package:flutter/material.dart';
import '../../models/file_data.dart';

class FormatIcon extends StatelessWidget {
  final FileFormat format;
  final double size;

  const FormatIcon({
    super.key,
    required this.format,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getColor(format),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          _getLabel(format),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getColor(FileFormat format) {
    switch (format) {
      case FileFormat.json:
        return Colors.orange;
      case FileFormat.xml:
        return Colors.green;
      case FileFormat.csv:
        return Colors.blue;
      case FileFormat.markdown:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getLabel(FileFormat format) {
    switch (format) {
      case FileFormat.json:
        return 'JS';
      case FileFormat.xml:
        return 'XM';
      case FileFormat.csv:
        return 'CS';
      case FileFormat.markdown:
        return 'MD';
      default:
        return '?';
    }
  }
}
