import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/admin_controller.dart';

class ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Obx(() {
        final admin = controller.admin.value;
        if (admin == null) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        return Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                admin.fullName.substring(0, 1).toUpperCase(),
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              admin.fullName,
              style: AppTextStyles.h2.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              admin.email,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: AppRadius.radiusSM,
              ),
              child: Text(
                admin.role.toUpperCase(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (admin.lastLogin != null) ...[
              SizedBox(height: AppSpacing.md),
              Text(
                'Dernière connexion: ${_formatDate(admin.lastLogin!)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
