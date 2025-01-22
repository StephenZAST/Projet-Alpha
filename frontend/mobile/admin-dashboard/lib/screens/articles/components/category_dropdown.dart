import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/category_controller.dart';
import '../../../models/category.dart';

class CategoryDropdown extends StatefulWidget {
  final String? value;
  final Function(String?) onChanged;
  final bool isRequired;

  const CategoryDropdown({
    Key? key,
    this.value,
    required this.onChanged,
    this.isRequired = true,
  }) : super(key: key);

  @override
  _CategoryDropdownState createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  final controller = Get.find<CategoryController>();

  @override
  void initState() {
    super.initState();
    if (controller.categories.isEmpty) {
      controller.fetchCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.isLoading.value) {
        return DropdownButtonFormField<String>(
          items: [],
          onChanged: null,
          decoration: InputDecoration(
            labelText: 'Catégorie',
            suffixIcon: SizedBox(
              width: 24,
              height: 24,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          ),
        );
      }

      final items = [
        if (!widget.isRequired)
          DropdownMenuItem<String>(
            value: null,
            child: Text('Toutes les catégories'),
          ),
        ...controller.categories.map((Category category) {
          return DropdownMenuItem<String>(
            value: category.id,
            child: Row(
              children: [
                Icon(
                  Icons.folder,
                  size: 20,
                  color: widget.value == category.id
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                SizedBox(width: 8),
                Text(
                  category.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: widget.value == category.id
                        ? AppColors.primary
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          );
        }),
      ];

      return DropdownButtonFormField<String>(
        value: widget.value,
        items: items,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          labelText: 'Catégorie',
          hintText: 'Sélectionnez une catégorie',
          border: OutlineInputBorder(
            borderRadius: AppRadius.radiusSM,
            borderSide: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusSM,
            borderSide: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusSM,
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
        validator: widget.isRequired
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'La catégorie est requise';
                }
                return null;
              }
            : null,
      );
    });
  }
}
