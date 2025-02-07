import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/menu_app_controller.dart';
import '../../../responsive.dart';
import '../../../constants.dart';
import '../../../routes/admin_routes.dart';

class Header extends GetView<MenuAppController> {
  final String title;

  const Header({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: AppSpacing.paddingMD,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: AppRadius.radiusMD,
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black12 : Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (!Responsive.isDesktop(context))
              IconButton(
                icon: Icon(
                  Icons.menu,
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
                onPressed: () {
                  print('[Header] Menu button pressed');
                  print(
                      '[Header] Is Desktop: ${Responsive.isDesktop(context)}');
                  controller.controlMenu();
                },
              ),
            if (!Responsive.isDesktop(context)) SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.h3.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Get.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
              onPressed: () => Get.changeThemeMode(
                Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
              ),
              tooltip: Get.isDarkMode ? 'Mode clair' : 'Mode sombre',
            ),
            SizedBox(width: AppSpacing.md),
            IconButton(
              icon: Stack(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () => AdminRoutes.goToNotifications(),
              tooltip: 'Notifications',
            ),
            SizedBox(width: AppSpacing.md),
            Material(
              type: MaterialType.transparency,
              child: Obx(() => _buildProfileMenu(authController, isDark)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu(AuthController authController, bool isDark) {
    final userName = authController.user.value?.email.split('@')[0] ?? 'Admin';

    return PopupMenuButton<String>(
      offset: Offset(0, 40),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.gray800 : AppColors.gray50,
          borderRadius: AppRadius.radiusMD,
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(
                Icons.person_outline,
                color: AppColors.primary,
                size: 20,
              ),
              radius: 16,
            ),
            if (!Responsive.isMobile(Get.context!)) ...[
              SizedBox(width: AppSpacing.sm),
              Text(
                userName,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
            ],
            SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.keyboard_arrow_down,
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
              size: 20,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Mon profil'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: ListTile(
            leading: Icon(Icons.settings_outlined),
            title: Text('Paramètres'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: ListTile(
            leading: Icon(Icons.logout, color: AppColors.error),
            title: Text(
              'Déconnexion',
              style: TextStyle(color: AppColors.error),
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'profile':
            Get.toNamed(AdminRoutes.profile);
            break;
          case 'logout':
            authController.logout();
            break;
        }
      },
    );
  }
}
