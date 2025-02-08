import 'package:flutter/material.dart';
import '../constants.dart';

class DateRangePicker extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?, DateTime?) onDateRangeSelected;
  final bool isDark;

  const DateRangePicker({
    Key? key,
    this.startDate,
    this.endDate,
    required this.onDateRangeSelected,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDateRangePicker(context),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.gray800 : AppColors.gray50,
          borderRadius: AppRadius.radiusSM,
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 20,
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              _formatDateRange(),
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateRange() {
    if (startDate == null && endDate == null) {
      return 'Sélectionner une période';
    }

    final start = startDate != null
        ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
        : '';
    final end = endDate != null
        ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
        : '';

    return '$start - $end';
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: isDark ? ThemeData.dark() : ThemeData.light(),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateRangeSelected(picked.start, picked.end);
    }
  }
}
