import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/log_controller.dart';

class LogFilters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LogController>();

    return Container(
      padding: EdgeInsets.all(defaultPadding),
      child: Row(
        children: [
          Expanded(
            child: DateRangePicker(
              onChanged: (range) {
                controller.dateRange.value = range;
                controller.fetchLogs();
              },
            ),
          ),
          SizedBox(width: defaultPadding),
          ActionFilter(
            onChanged: (action) {
              controller.selectedAction.value = action ?? '';
              controller.fetchLogs();
            },
          ),
        ],
      ),
    );
  }
}

class DateRangePicker extends StatelessWidget {
  final Function(DateTimeRange?) onChanged;

  const DateRangePicker({Key? key, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        onChanged(picked);
      },
      child: Text('Select Date Range'),
    );
  }
}

class ActionFilter extends StatelessWidget {
  final Function(String?) onChanged;

  const ActionFilter({Key? key, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      hint: Text('Select Action'),
      items: ['CREATE', 'UPDATE', 'DELETE']
          .map((action) => DropdownMenuItem(
                value: action,
                child: Text(action),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
