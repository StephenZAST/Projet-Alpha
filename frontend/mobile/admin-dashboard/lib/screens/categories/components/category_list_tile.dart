import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/category.dart';
import '../../../constants.dart';
import '../../../widgets/shared/action_button.dart';
import '../../../controllers/category_controller.dart';

class CategoryListTile extends StatelessWidget {
  final Category category;
  final Function(Category) onEdit;
  final Function(Category) onDelete;
  final bool selected;
  final VoidCallback? onSelect;

  const CategoryListTile({
    Key? key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
    this.selected = false,
    this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<CategoryController>();
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.white70,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => Checkbox(
                  value: controller.selectedCategoryIds.contains(category.id),
                  onChanged: (v) =>
                      controller.toggleCategorySelection(category.id),
                  activeColor: AppColors.primary,
                )),
            Icon(
              Icons.folder_outlined,
              color: AppColors.primary,
            ),
          ],
        ),
        title: Row(
          children: [
            Text(
              category.name,
              style: AppTextStyles.bodyLarge.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 8),
            if (!category.isActive)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Inactive',
                    style: TextStyle(color: AppColors.error, fontSize: 12)),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (category.description != null &&
                category.description!.isNotEmpty)
              Text(
                category.description!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                ),
              ),
            SizedBox(height: 2),
            Text(
              '${category.articlesCount} article${category.articlesCount > 1 ? 's' : ''}',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ActionButton(
              icon: Icons.edit_rounded,
              label: '',
              color: AppColors.primary,
              onTap: () => onEdit(category),
              variant: ActionButtonVariant.ghost,
              isCompact: true,
            ),
            SizedBox(width: AppSpacing.xs),
            ActionButton(
              icon: Icons.delete_rounded,
              label: '',
              color: AppColors.error,
              onTap: () => onDelete(category),
              variant: ActionButtonVariant.ghost,
              isCompact: true,
            ),
          ],
        ),
      ),
    );
  }
}
