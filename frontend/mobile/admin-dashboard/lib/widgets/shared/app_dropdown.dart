import 'package:flutter/material.dart';
import '../../constants.dart';

class AppDropdown<T> extends StatelessWidget {
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final bool isExpanded;

  const AppDropdown({
    Key? key,
    this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isExpanded = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.radiusSM,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: DropdownButton<T>(
        value: value,
        hint: hint != null
            ? Text(
                hint!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        items: items,
        onChanged: onChanged,
        isExpanded: isExpanded,
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.textSecondary,
        ),
        underline: SizedBox(),
        dropdownColor: Theme.of(context).cardColor,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? AppColors.textLight : AppColors.textPrimary,
        ),
      ),
    );
  }
}
