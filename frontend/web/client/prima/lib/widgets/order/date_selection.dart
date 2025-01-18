import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/widgets/order/recurrence_selection.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DateSelection extends StatefulWidget {
  final DateTime? collectionDate;
  final DateTime? deliveryDate;
  final TimeOfDay? collectionTime;
  final TimeOfDay? deliveryTime;
  final Function(DateTime?) onCollectionDateSelected;
  final Function(DateTime?) onDeliveryDateSelected;
  final Function(TimeOfDay?) onCollectionTimeSelected;
  final Function(TimeOfDay?) onDeliveryTimeSelected;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final RecurrenceType selectedRecurrence;
  final Function(RecurrenceType) onRecurrenceSelected;

  const DateSelection({
    Key? key,
    this.collectionDate,
    this.deliveryDate,
    this.collectionTime,
    this.deliveryTime,
    required this.onCollectionDateSelected,
    required this.onDeliveryDateSelected,
    required this.onCollectionTimeSelected,
    required this.onDeliveryTimeSelected,
    required this.onNext,
    required this.onPrevious,
    required this.selectedRecurrence,
    required this.onRecurrenceSelected,
  }) : super(key: key);

  @override
  _DateSelectionState createState() => _DateSelectionState();
}

class _DateSelectionState extends State<DateSelection> {
  bool _isLocaleInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('fr_FR', null);
    if (mounted) {
      setState(() => _isLocaleInitialized = true);
    }
  }

  String _formatDay(DateTime date) {
    if (!_isLocaleInitialized) return date.day.toString();
    return DateFormat.d('fr_FR').format(date);
  }

  String _formatWeekday(DateTime date) {
    if (!_isLocaleInitialized) return '';
    return DateFormat.E('fr_FR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDateTimePicker(
            context: context,
            title: 'Date et heure de collecte',
            selectedDate: widget.collectionDate,
            selectedTime: widget.collectionTime,
            onSelectDate: (date) {
              widget.onCollectionDateSelected(date);
              if (date != null) {
                widget
                    .onDeliveryDateSelected(date.add(const Duration(days: 3)));
              }
            },
            onSelectTime: widget.onCollectionTimeSelected,
            minDate: DateTime.now(),
          ),
          const SizedBox(height: 24),
          _buildDateTimePicker(
            context: context,
            title: 'Date et heure de livraison',
            selectedDate: widget.deliveryDate,
            selectedTime: widget.deliveryTime,
            onSelectDate: widget.onDeliveryDateSelected,
            onSelectTime: widget.onDeliveryTimeSelected,
            minDate: widget.collectionDate?.add(const Duration(days: 1)) ??
                DateTime.now().add(const Duration(days: 1)),
          ),
          const SizedBox(height: 32),
          RecurrenceSelection(
            selectedRecurrence: widget.selectedRecurrence,
            onRecurrenceSelected: widget.onRecurrenceSelected,
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePicker({
    required BuildContext context,
    required String title,
    required DateTime? selectedDate,
    required TimeOfDay? selectedTime,
    required Function(DateTime?) onSelectDate,
    required Function(TimeOfDay?) onSelectTime,
    required DateTime minDate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.gray700,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () =>
                  _selectDate(context, selectedDate, onSelectDate, minDate),
              color: AppColors.gray500,
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 30,
            itemBuilder: (context, index) {
              final day = DateTime.now().add(Duration(days: index));
              final isSelected = selectedDate != null &&
                  day.year == selectedDate.year &&
                  day.month == selectedDate.month &&
                  day.day == selectedDate.day;

              return GestureDetector(
                onTap: () => onSelectDate(day),
                child: Container(
                  width: 56,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.gray50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.gray200,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatDay(day),
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.gray700,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatWeekday(day),
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.gray500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectTime(context, selectedTime, onSelectTime),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  selectedTime?.format(context) ?? 'Sélectionner une heure',
                  style: TextStyle(
                    color: selectedTime != null
                        ? AppColors.gray800
                        : AppColors.gray500,
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
            colorScheme: const ColorScheme.light(
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

  Future<void> _selectTime(
    BuildContext context,
    TimeOfDay? initialTime,
    Function(TimeOfDay?) onSelectTime,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
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
    if (picked != null) onSelectTime(picked);
  }
}
