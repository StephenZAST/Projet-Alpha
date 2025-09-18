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
          trailing: Obx(() => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: themeController.isDarkMode
                          ? AppColors.primary.withOpacity(0.3)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Switch(
                  value: themeController.isDarkMode,
                  onChanged: (value) => themeController.toggleTheme(),
                  activeColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withOpacity(0.3),
                  inactiveThumbColor:
                      isDark ? AppColors.gray400 : AppColors.gray500,
                  inactiveTrackColor: isDark
                      ? AppColors.gray700.withOpacity(0.5)
                      : AppColors.gray300.withOpacity(0.5),
                ),
              )),
          isDark: isDark,
        ),
        _buildPreferenceItem(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          trailing: Obx(() => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: (profileController.profile.value?.preferences !=
                                  null &&
                              profileController.profile.value!
                                      .preferences['notifications'] ==
                                  true)
                          ? AppColors.success.withOpacity(0.3)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Switch(
                  value: profileController.profile.value?.preferences != null &&
                      profileController
                              .profile.value!.preferences['notifications'] ==
                          true,
                  onChanged: (value) => profileController.updatePreferences({
                    'notifications': value,
                  }),
                  activeColor: AppColors.success,
                  activeTrackColor: AppColors.success.withOpacity(0.3),
                  inactiveThumbColor:
                      isDark ? AppColors.gray400 : AppColors.gray500,
                  inactiveTrackColor: isDark
                      ? AppColors.gray700.withOpacity(0.5)
                      : AppColors.gray300.withOpacity(0.5),
                ),
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
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.md,
      ),
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardBgDark.withOpacity(0.4)
            : AppColors.cardBgLight.withOpacity(0.4),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDark
              ? AppColors.gray700.withOpacity(AppColors.glassBorderDarkOpacity)
              : AppColors.gray200
                  .withOpacity(AppColors.glassBorderLightOpacity),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown(
      AdminProfileController controller, bool isDark) {
    return Obx(() => Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.cardBgDark.withOpacity(0.4)
                : AppColors.cardBgLight.withOpacity(0.4),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: isDark
                  ? AppColors.gray700
                      .withOpacity(AppColors.glassBorderDarkOpacity)
                  : AppColors.gray200
                      .withOpacity(AppColors.glassBorderLightOpacity),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButton<String>(
            value: controller.profile.value?.preferences != null
                ? controller.profile.value!.preferences['language'] ?? 'fr'
                : 'fr',
            items: [
              DropdownMenuItem(
                value: 'fr',
                child: Text(
                  'Français',
                  style: TextStyle(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 'en',
                child: Text(
                  'English',
                  style: TextStyle(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                controller.updatePreferences({'language': value});
              }
            },
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
            underline: Container(),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: isDark ? AppColors.gray300 : AppColors.gray600,
            ),
            dropdownColor: isDark ? AppColors.gray800 : Colors.white,
          ),
        ));
  }
}
