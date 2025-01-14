import 'package:flutter/material.dart';

class DateSelectionStep extends StatelessWidget {
  final DateTime? collectionDate;
  final DateTime? deliveryDate;
  final Function({DateTime? collection, DateTime? delivery}) onDatesSelected;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const DateSelectionStep({
    Key? key,
    this.collectionDate,
    this.deliveryDate,
    required this.onDatesSelected,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ... implémentation de la sélection de dates ...
  }
}
