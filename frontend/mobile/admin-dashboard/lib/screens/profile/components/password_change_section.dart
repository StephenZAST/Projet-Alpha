import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/admin_profile_controller.dart';
import '../../../constants.dart';
import '../../../widgets/shared/glass_button.dart';

class PasswordChangeSection extends StatelessWidget {
  const PasswordChangeSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminProfileController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Changer le mot de passe', style: AppTextStyles.h4),
            SizedBox(height: AppSpacing.lg),
            _buildPasswordFields(controller, isDark),
            SizedBox(height: AppSpacing.lg),
            _buildSubmitButton(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordFields(AdminProfileController controller, bool isDark) {
    return Column(
      children: [
        _buildPasswordField(
          controller.currentPasswordController,
          'Mot de passe actuel',
          isDark,
        ),
        SizedBox(height: AppSpacing.md),
        _buildPasswordField(
          controller.newPasswordController,
          'Nouveau mot de passe',
          isDark,
        ),
        SizedBox(height: AppSpacing.md),
        _buildPasswordField(
          controller.confirmPasswordController,
          'Confirmer le nouveau mot de passe',
          isDark,
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String label,
    bool isDark,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      style: TextStyle(
        color: isDark ? AppColors.textLight : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? AppColors.gray300 : AppColors.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: isDark
                ? AppColors.gray700
                    .withOpacity(AppColors.glassBorderDarkOpacity)
                : AppColors.gray200
                    .withOpacity(AppColors.glassBorderLightOpacity),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: isDark
                ? AppColors.gray700
                    .withOpacity(AppColors.glassBorderDarkOpacity)
                : AppColors.gray200
                    .withOpacity(AppColors.glassBorderLightOpacity),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: AppColors.primary.withOpacity(0.8),
            width: 2,
          ),
        ),
        filled: true,
        fillColor: isDark
            ? AppColors.cardBgDark.withOpacity(0.6)
            : AppColors.cardBgLight.withOpacity(0.6),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AdminProfileController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GlassButton(
          label: 'Mettre à jour le mot de passe',
          icon: Icons.lock_outline,
          variant: GlassButtonVariant.warning,
          onPressed: controller.changePassword,
        ),
      ],
    );
  }
}
