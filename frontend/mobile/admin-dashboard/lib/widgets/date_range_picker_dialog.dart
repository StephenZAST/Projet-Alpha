import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants.dart';

class DateRangePickerDialog extends StatelessWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final TimeOfDay initialTime;

  const DateRangePickerDialog({
    Key? key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.initialTime = const TimeOfDay(hour: 9, minute: 0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sélectionner la date et l\'heure', style: AppTextStyles.h3),
            SizedBox(height: AppSpacing.lg),
            CalendarDatePicker(
              initialDate: initialDate,
              firstDate: firstDate,
              lastDate: lastDate,
              onDateChanged: (date) async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: initialTime,
                );

                if (time != null) {
                  final dateTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  );
                  Get.back(result: dateTime);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
