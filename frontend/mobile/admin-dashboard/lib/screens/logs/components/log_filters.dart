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
      child: Wrap(
        spacing: defaultPadding,
        runSpacing: defaultPadding,
        children: [
          DateRangePicker(
            onChanged: (range) {
              controller.dateRange.value = range;
              controller.fetchLogs();
            },
          ),
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
      items: [
        'ADMIN.PROFILE_UPDATED',
        'AUTH.PASSWORD_CHANGED',
        'AUTH.LOGIN_SUCCEEDED',
        'USER.UPDATED',
        'USER.DELETED',
        'ORDER.STATUS_CHANGED',
        'ORDER.PRICING_CHANGED',
        'ORDER.PAYMENT_MARKED_PAID',
        'DATA.EXPORTED',
      ]
          .map((action) => DropdownMenuItem(
                value: action,
                child: Text(action),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
