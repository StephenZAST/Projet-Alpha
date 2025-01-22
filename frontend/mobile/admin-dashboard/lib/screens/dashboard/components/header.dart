import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/components/notification_badge.dart';
import 'package:admin/screens/notifications/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../widgets/theme_switch.dart';

class Header extends StatelessWidget {
  final String title;

  const Header({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: Get.isDarkMode ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (!Responsive.isDesktop(context))
            IconButton(
              icon: Icon(Icons.menu,
                  color: Get.isDarkMode
                      ? AppColors.textLight
                      : AppColors.textPrimary),
              onPressed: () => context.read<MenuAppController>().controlMenu(),
            ),
          if (!Responsive.isDesktop(context)) SizedBox(width: AppSpacing.md),
          Text(
            title,
            style: AppTextStyles.h3.copyWith(
              color:
                  Get.isDarkMode ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          if (!Responsive.isMobile(context))
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: SearchField(),
              ),
            ),
          if (!Responsive.isMobile(context)) ThemeSwitch(),
          SizedBox(width: AppSpacing.md),
          NotificationBadge(),
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color:
                  Get.isDarkMode ? AppColors.textLight : AppColors.textPrimary,
            ),
            onPressed: () => Get.to(() => NotificationsScreen()),
          ),
          SizedBox(width: AppSpacing.md),
          ProfileCard(),
        ],
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppColors.gray800 : AppColors.gray50,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: Get.isDarkMode ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage("assets/images/profile_pic.png"),
            radius: 16,
          ),
          if (!Responsive.isMobile(context)) ...[
            SizedBox(width: AppSpacing.sm),
            Text(
              "Admin",
              style: AppTextStyles.bodyMedium.copyWith(
                color: Get.isDarkMode
                    ? AppColors.textLight
                    : AppColors.textPrimary,
              ),
            ),
          ],
          SizedBox(width: AppSpacing.xs),
          Icon(
            Icons.keyboard_arrow_down,
            color: Get.isDarkMode ? AppColors.textLight : AppColors.textPrimary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: AppTextStyles.bodyMedium.copyWith(
        color: Get.isDarkMode ? AppColors.textLight : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: "Rechercher...",
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: Get.isDarkMode ? AppColors.gray500 : AppColors.gray400,
        ),
        fillColor: Get.isDarkMode ? AppColors.gray800 : AppColors.gray50,
        filled: true,
        contentPadding: EdgeInsets.all(AppSpacing.sm),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMD,
          borderSide: BorderSide(
            color:
                Get.isDarkMode ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMD,
          borderSide: BorderSide(
            color:
                Get.isDarkMode ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMD,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: Get.isDarkMode ? AppColors.gray400 : AppColors.gray500,
          size: 20,
        ),
      ),
    );
  }
}
