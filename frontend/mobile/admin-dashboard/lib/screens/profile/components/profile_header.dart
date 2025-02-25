import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/admin_profile_controller.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminProfileController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() => Card(
          elevation: 0,
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusMD,
            side: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                _buildProfileImage(context, controller),
                SizedBox(width: AppSpacing.lg),
                Expanded(child: _buildUserInfo(context, controller)),
              ],
            ),
          ),
        ));
  }

  Widget _buildProfileImage(
      BuildContext context, AdminProfileController controller) {
    return CircleAvatar(
      radius: 50,
      backgroundImage: controller.profile.value?.profileImage != null
          ? NetworkImage(controller.profile.value!.profileImage!)
          : null,
      child: controller.profile.value?.profileImage == null
          ? Icon(Icons.person_outline, size: 50, color: AppColors.textLight)
          : null,
      backgroundColor: AppColors.primary.withOpacity(0.1),
    );
  }

  Widget _buildUserInfo(
      BuildContext context, AdminProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          controller.profile.value?.fullName ?? 'Chargement...',
          style: AppTextStyles.h3,
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          controller.profile.value?.email ?? '',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        _buildRoleBadge(controller.profile.value?.role ?? ''),
      ],
    );
  }

  Widget _buildRoleBadge(String role) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: AppRadius.radiusXS,
      ),
      child: Text(
        role,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
