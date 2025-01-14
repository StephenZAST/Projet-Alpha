import 'package:flutter/material.dart';

class PickupTime {
  final DateTime date;
  final TimeOfDay time;

  PickupTime({required this.date, required this.time});

  DateTime get dateTime {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }
}
