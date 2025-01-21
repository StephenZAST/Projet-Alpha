import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ColumnSelector extends StatelessWidget {
  final RxList<String> selectedColumns;
  final List<String> availableColumns;

  ColumnSelector({
    required this.selectedColumns,
    required this.availableColumns,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: availableColumns.map((column) {
        return Obx(() {
          final isSelected = selectedColumns.contains(column);
          return FilterChip(
            label: Text(column),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                selectedColumns.add(column);
              } else {
                selectedColumns.remove(column);
              }
            },
          );
        });
      }).toList(),
    );
  }
}
