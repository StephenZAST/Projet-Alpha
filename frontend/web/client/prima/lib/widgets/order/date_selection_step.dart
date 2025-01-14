import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:intl/intl.dart';

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
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDateSection(
            context,
            title: 'Date de collecte',
            subtitle: 'Quand souhaitez-vous que nous récupérions votre linge ?',
            icon: Icons.upload_outlined,
            value: collectionDate,
            onSelect: (date) => onDatesSelected(collection: date),
            minDate: DateTime.now(),
          ),
          const SizedBox(height: 32),
          _buildDateSection(
            context,
            title: 'Date de livraison',
            subtitle: 'Quand souhaitez-vous être livré ?',
            icon: Icons.local_shipping_outlined,
            value: deliveryDate,
            onSelect: (date) => onDatesSelected(delivery: date),
            minDate: collectionDate?.add(const Duration(days: 1)) ??
                DateTime.now().add(const Duration(days: 1)),
          ),
          const Spacer(),
          _buildNavigationButtons(context),
        ],
      ),
    );
  }

  Widget _buildDateSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required DateTime? value,
    required Function(DateTime?) onSelect,
    required DateTime minDate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.gray800,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.gray600,
              ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _selectDate(context, value, onSelect, minDate),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value != null
                        ? DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(value)
                        : 'Sélectionner une date',
                    style: TextStyle(
                      color:
                          value != null ? AppColors.gray800 : AppColors.gray500,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                  size: 20,
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
    if (picked != null) {
      onSelect(picked);
    }
  }

  Widget _buildNavigationButtons(BuildContext context) {
    final bool canProceed = collectionDate != null && deliveryDate != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Retour'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.gray600,
          ),
        ),
        ElevatedButton.icon(
          onPressed: canProceed ? onNext : null,
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Continuer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.gray300,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }
}
