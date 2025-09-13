import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/admin_profile_controller.dart';
import '../../../widgets/shared/glass_container.dart';
import '../../../widgets/shared/glass_button.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminProfileController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() => GlassContainer(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Row(
            children: [
              _buildProfileImage(context, controller, isDark),
              SizedBox(width: AppSpacing.xl),
              Expanded(child: _buildUserInfo(context, controller, isDark)),
              _buildActions(context, controller),
            ],
          ),
        ));
  }

  Widget _buildProfileImage(
      BuildContext context, AdminProfileController controller, bool isDark) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.2),
                AppColors.primaryLight.withOpacity(0.1),
              ],
            ),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 47,
            backgroundImage: controller.profile.value?.profileImage != null
                ? NetworkImage(controller.profile.value!.profileImage!)
                : null,
            backgroundColor: Colors.transparent,
            child: controller.profile.value?.profileImage == null
                ? Icon(
                    Icons.person_outline,
                    size: 50,
                    color: AppColors.primary,
                  )
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.gray800 : Colors.white,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context, AdminProfileController controller, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.profile.value?.fullName ?? 'Chargement...',
          style: AppTextStyles.h2.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Icon(
              Icons.email_outlined,
              size: 16,
              color: isDark ? AppColors.gray400 : AppColors.textMuted,
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              controller.profile.value?.email ?? '',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            _buildRoleBadge(controller.profile.value?.role ?? ''),
            SizedBox(width: AppSpacing.sm),
            _buildStatusBadge(true, isDark), // Assuming admin is always active
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        _buildStatsRow(controller, isDark),
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
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.primary.withOpacity(0.1),
          ],
        ),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.admin_panel_settings,
            size: 14,
            color: AppColors.primary,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            role.isNotEmpty ? role : 'Administrateur',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive, bool isDark) {
    final color = isActive ? AppColors.success : AppColors.error;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            isActive ? 'Actif' : 'Inactif',
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(AdminProfileController controller, bool isDark) {
    return Row(
      children: [
        _buildStatItem(
          'Dernière connexion',
          'Aujourd\'hui',
          Icons.access_time,
          isDark,
        ),
        SizedBox(width: AppSpacing.lg),
        _buildStatItem(
          'Sessions',
          '24',
          Icons.timeline,
          isDark,
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? AppColors.gray400 : AppColors.textMuted,
        ),
        SizedBox(width: AppSpacing.xs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, AdminProfileController controller) {
    return Column(
      children: [
        GlassButton(
          label: 'Changer photo',
          icon: Icons.photo_camera_outlined,
          variant: GlassButtonVariant.info,
          size: GlassButtonSize.small,
          onPressed: () => _showImagePicker(context),
        ),
        SizedBox(height: AppSpacing.sm),
        GlassButton(
          label: 'Paramètres',
          icon: Icons.settings_outlined,
          variant: GlassButtonVariant.secondary,
          size: GlassButtonSize.small,
          onPressed: () => _showSettingsDialog(context),
        ),
      ],
    );
  }

  void _showImagePicker(BuildContext context) {
    // TODO: Implémenter le sélecteur d'image
    Get.rawSnackbar(
      message: 'Fonctionnalité de changement de photo en cours de développement',
      backgroundColor: AppColors.info,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    // TODO: Implémenter les paramètres avancés
    Get.rawSnackbar(
      message: 'Paramètres avancés en cours de développement',
      backgroundColor: AppColors.info,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
    );
  }
}
