import 'package:admin/theme/glass_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/users_controller.dart';
import '../../../constants.dart';

class ViewToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: 4),
          decoration: GlassStyle.containerDecoration(
            context: context,
            opacity: isDark ? 0.2 : 0.1,
            borderRadius: 30,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildToggleOption(
                context: context,
                icon: Icons.view_list_rounded,
                label: 'Liste',
                isSelected: controller.viewMode.value == ViewMode.list,
                onTap: () => controller.toggleView(ViewMode.list),
              ),
              SizedBox(width: 8),
              _buildToggleOption(
                context: context,
                icon: Icons.grid_view_rounded,
                label: 'Grille',
                isSelected: controller.viewMode.value == ViewMode.grid,
                onTap: () => controller.toggleView(ViewMode.grid),
              ),
            ],
          ),
        ));
  }

  Widget _buildToggleOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? AppColors.primary.withOpacity(0.2)
                    : AppColors.primary.withOpacity(0.1))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.gray400 : AppColors.gray600),
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.gray400 : AppColors.gray600),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
