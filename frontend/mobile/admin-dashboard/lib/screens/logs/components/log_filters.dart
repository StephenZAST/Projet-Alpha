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
          UserFilter(
            onSubmitted: (userId) {
              controller.selectedUserId.value = userId;
              controller.fetchLogs();
            },
          ),
        ],
      ),
    );
  }
}

class UserFilter extends StatelessWidget {
  final ValueChanged<String> onSubmitted;

  const UserFilter({Key? key, required this.onSubmitted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Admin ID',
          border: OutlineInputBorder(),
        ),
        onSubmitted: onSubmitted,
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
        'USER.CREATED',
        'USER.ROLE_CHANGED',
        'USER.DELETED',
        'ORDER.STATUS_CHANGED',
        'ORDER.PRICING_CHANGED',
        'ORDER.PAYMENT_MARKED_PAID',
        'DATA.EXPORTED',
        'CATALOG.ARTICLE_SERVICE_CREATED',
        'CATALOG.ARTICLE_SERVICE_UPDATED',
        'CATALOG.ARTICLE_SERVICE_DELETED',
        'CATALOG.SERVICE_CREATED',
        'CATALOG.SERVICE_UPDATED',
        'CATALOG.SERVICE_DELETED',
        'CATALOG.ARTICLE_CREATED',
        'CATALOG.ARTICLE_UPDATED',
        'CATALOG.ARTICLE_DELETED',
        'CATALOG.SERVICE_TYPE_CREATED',
        'CATALOG.SERVICE_TYPE_UPDATED',
        'CATALOG.SERVICE_TYPE_DELETED',
        'CATALOG.ARTICLE_CATEGORY_CREATED',
        'CATALOG.ARTICLE_CATEGORY_UPDATED',
        'CATALOG.ARTICLE_CATEGORY_DELETED',
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
