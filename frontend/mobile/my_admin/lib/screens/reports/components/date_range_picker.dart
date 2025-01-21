import 'package:flutter/material.dart';

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
