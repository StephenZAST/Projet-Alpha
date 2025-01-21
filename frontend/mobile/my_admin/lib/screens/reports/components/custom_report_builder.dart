import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import 'column_selector.dart';
import 'date_range_picker.dart';

class CustomReportBuilder extends StatelessWidget {
  final selectedColumns = <String>[].obs;
  final dateRange = Rx<DateTimeRange?>(null);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(defaultPadding),
      child: Column(
        children: [
          ColumnSelector(
            selectedColumns: selectedColumns,
            availableColumns: [
              'Order ID',
              'Customer',
              'Amount',
              'Status',
              'Date',
            ],
          ),
          DateRangePicker(
            onChanged: (range) => dateRange.value = range,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text('Save Template'),
                onPressed: () => _saveTemplate(),
              ),
              SizedBox(width: defaultPadding),
              ElevatedButton.icon(
                icon: Icon(Icons.download),
                label: Text('Generate Report'),
                onPressed: () => _generateReport(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveTemplate() {
    // TODO: Implement save template logic
  }

  void _generateReport() {
    // TODO: Implement generate report logic
  }
}
