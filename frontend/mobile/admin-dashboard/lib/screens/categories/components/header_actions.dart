import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/category_controller.dart';
import '../../../widgets/shared/app_button.dart';
import 'category_dialog.dart';

class CategoryHeaderActions extends StatelessWidget {
  final CategoryController controller;

  const CategoryHeaderActions({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: controller.searchCategories,
            decoration: InputDecoration(
              hintText: 'Rechercher une catégorie...',
              prefixIcon: Icon(
                Icons.search,
                color: isDark ? AppColors.textLight : AppColors.textSecondary,
              ),
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
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(width: defaultPadding),
        AppButton(
          label: 'Nouvelle catégorie',
          icon: Icons.add,
          onPressed: () => Get.dialog(CategoryDialog()),
        ),
      ],
    );
  }
}
