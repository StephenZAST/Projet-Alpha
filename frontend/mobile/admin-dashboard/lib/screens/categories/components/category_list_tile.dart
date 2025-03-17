import 'package:flutter/material.dart';
import '../../../models/category.dart';
import '../../../constants.dart';
import '../../../widgets/shared/action_button.dart';

class CategoryListTile extends StatelessWidget {
  final Category category;
  final Function(Category) onEdit;
  final Function(Category) onDelete;

  const CategoryListTile({
    Key? key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        Icons.folder_outlined,
        color: AppColors.primary,
      ),
      title: Text(
        category.name,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDark ? AppColors.textLight : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        category.description ?? '',
        style: AppTextStyles.bodySmall.copyWith(
          color: isDark ? AppColors.gray400 : AppColors.gray600,
        ),
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
    );
  }
}
