import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:spring_button/spring_button.dart';

enum RecurrenceType { none, weekly, biweekly, monthly }

class RecurrenceSelection extends StatelessWidget {
  final RecurrenceType selectedRecurrence;
  final Function(RecurrenceType) onRecurrenceSelected;

  const RecurrenceSelection({
    Key? key,
    required this.selectedRecurrence,
    required this.onRecurrenceSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Fréquence de collecte',
            style: TextStyle(
              color: AppColors.gray700,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionButton(
                  'Pas de récurrence',
                  RecurrenceType.none,
                  selectedRecurrence,
                  onRecurrenceSelected,
                ),
                _buildOptionButton(
                  'Hebdomadaire',
                  RecurrenceType.weekly,
                  selectedRecurrence,
                  onRecurrenceSelected,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionButton(
                  'Bi-mensuelle',
                  RecurrenceType.biweekly,
                  selectedRecurrence,
                  onRecurrenceSelected,
                ),
                _buildOptionButton(
                  'Mensuelle',
                  RecurrenceType.monthly,
                  selectedRecurrence,
                  onRecurrenceSelected,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionButton(
      String label,
      RecurrenceType type,
      RecurrenceType selectedRecurrence,
      Function(RecurrenceType) onRecurrenceSelected) {
    final isSelected = selectedRecurrence == type;
    return Expanded(
      child: SpringButton(
        SpringButtonType.OnlyScale,
        Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.gray50,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.gray200,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.gray800,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        onTap: () => onRecurrenceSelected(type),
        scaleCoefficient: 0.9,
        useCache: false,
      ),
    );
  }
}
