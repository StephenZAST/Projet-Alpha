import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/admin_profile_controller.dart';
import '../../../constants.dart';

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
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: AppRadius.radiusSM),
        filled: true,
        fillColor: isDark ? AppColors.gray800 : AppColors.gray50,
      ),
    );
  }

  Widget _buildSubmitButton(AdminProfileController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: controller.changePassword,
          icon: Icon(Icons.lock_outline),
          label: Text('Mettre à jour le mot de passe'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }
}
