import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';

class DateSelection extends StatelessWidget {
  final DateTime? collectionDate;
  final DateTime? deliveryDate;
  final Function(DateTime?) onCollectionDateSelected;
  final Function(DateTime?) onDeliveryDateSelected;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const DateSelection({
    Key? key,
    this.collectionDate,
    this.deliveryDate,
    required this.onCollectionDateSelected,
    required this.onDeliveryDateSelected,
    required this.onNext,
    required this.onPrevious,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDateField(
            context: context,
            label: 'Date de collecte',
            value: collectionDate,
            onSelect: (date) {
              onCollectionDateSelected(date);
              // Proposer une date de livraison automatique (+3 jours)
              if (date != null) {
                onDeliveryDateSelected(date.add(const Duration(days: 3)));
              }
            },
            minDate: DateTime.now(),
          ),
          const SizedBox(height: 24),
          _buildDateField(
            context: context,
            label: 'Date de livraison',
            value: deliveryDate,
            onSelect: (date) => onDeliveryDateSelected(date),
            minDate: collectionDate?.add(const Duration(days: 1)) ??
                DateTime.now().add(const Duration(days: 1)),
          ),
          const Spacer(),
          _buildNavigationButtons(context),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime? value,
    required Function(DateTime?) onSelect,
    required DateTime minDate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.gray700,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context, value, onSelect, minDate),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  value?.toString().split(' ')[0] ?? 'Sélectionner une date',
                  style: TextStyle(
                    color:
                        value != null ? AppColors.gray800 : AppColors.gray500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime? initialDate,
    Function(DateTime?) onSelect,
    DateTime minDate,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? minDate,
      firstDate: minDate,
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.gray800,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onSelect(picked);
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: onPrevious,
          child: const Text('Retour'),
        ),
        ElevatedButton(
          onPressed: () {
            if (collectionDate != null && deliveryDate != null) {
              onNext();
            }
          },
          child: const Text('Suivant'),
        ),
      ],
    );
  }
}
