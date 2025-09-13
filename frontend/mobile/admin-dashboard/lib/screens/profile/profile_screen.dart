import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import '../../controllers/admin_profile_controller.dart';
import 'components/profile_header.dart';
import 'components/profile_form.dart';
import 'components/password_change_section.dart';
import 'components/preferences_section.dart';
import '../../constants.dart';
import '../../widgets/shared/glass_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(AdminProfileController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.gray50,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDark),
              SizedBox(height: AppSpacing.lg),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ProfileHeader(),
                      SizedBox(height: AppSpacing.lg),
                      ProfileForm(),
                      SizedBox(height: AppSpacing.lg),
                      PasswordChangeSection(),
                      SizedBox(height: AppSpacing.lg),
                      PreferencesSection(),
                      SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mon Profil',
              style: AppTextStyles.h1.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'Gérez vos informations personnelles et préférences',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            GlassButton(
              label: 'Aide',
              icon: Icons.help_outline,
              variant: GlassButtonVariant.info,
              size: GlassButtonSize.small,
              onPressed: () => _showHelpDialog(context),
            ),
            SizedBox(width: AppSpacing.sm),
            GlassButton(
              label: 'Actualiser',
              icon: Icons.refresh_outlined,
              variant: GlassButtonVariant.secondary,
              size: GlassButtonSize.small,
              onPressed: () {
                final controller = Get.find<AdminProfileController>();
                controller.loadProfile();
              },
            ),
          ],
        ),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: 400,
          padding: EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.gray900.withOpacity(0.95)
                : Colors.white.withOpacity(0.95),
            borderRadius: AppRadius.radiusLG,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
            ),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.radiusLG,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.help_outline, size: 48, color: AppColors.primary),
                  SizedBox(height: AppSpacing.md),
                  Text('Aide - Profil Admin', style: AppTextStyles.h4),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Cette page vous permet de gérer vos informations personnelles, changer votre mot de passe et configurer vos préférences.',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  GlassButton(
                    label: 'Compris',
                    variant: GlassButtonVariant.primary,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
