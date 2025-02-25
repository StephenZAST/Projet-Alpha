import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/admin_profile_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../constants.dart';

class PreferencesSection extends StatelessWidget {
  const PreferencesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<AdminProfileController>();
    final themeController = Get.find<ThemeController>();
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
            Text('Préférences', style: AppTextStyles.h4),
            SizedBox(height: AppSpacing.lg),
            _buildPreferencesList(
                context, profileController, themeController, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesList(
    BuildContext context,
    AdminProfileController profileController,
    ThemeController themeController,
    bool isDark,
  ) {
    return Column(
      children: [
        _buildPreferenceItem(
          icon: Icons.dark_mode_outlined,
          title: 'Mode sombre',
          trailing: Obx(() => Switch(
                value: themeController.isDarkMode,
                onChanged: (value) => themeController.toggleTheme(),
              )),
          isDark: isDark,
        ),
        _buildPreferenceItem(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          trailing: Obx(() => Switch(
                value: profileController
                            .profile.value?.preferences?['notifications'] ==
                        true
                    ? true
                    : false,
                onChanged: (value) => profileController.updatePreferences({
                  'notifications': value,
                }),
              )),
          isDark: isDark,
        ),
        _buildPreferenceItem(
          icon: Icons.language_outlined,
          title: 'Langue',
          trailing: _buildLanguageDropdown(profileController, isDark),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildPreferenceItem({
    required IconData icon,
    required String title,
    required Widget trailing,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown(
      AdminProfileController controller, bool isDark) {
    return Obx(() => DropdownButton<String>(
          value: controller.profile.value?.preferences?['language'] ?? 'fr',
          items: [
            DropdownMenuItem(value: 'fr', child: Text('Français')),
            DropdownMenuItem(value: 'en', child: Text('English')),
          ],
          onChanged: (value) {
            if (value != null) {
              controller.updatePreferences({'language': value});
            }
          },
          style: AppTextStyles.bodyMedium,
          underline: Container(),
        ));
  }
}
