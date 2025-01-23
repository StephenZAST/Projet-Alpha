import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../constants.dart';

class ThemeSwitch extends StatelessWidget {
  final bool showLabel;

  const ThemeSwitch({
    Key? key,
    this.showLabel = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<ThemeController>(
      init: ThemeController(),
      builder: (controller) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              controller.darkMode ? Icons.light_mode : Icons.dark_mode,
              color:
                  controller.darkMode ? AppColors.warning : AppColors.gray600,
              size: 22,
            ),
            tooltip: controller.darkMode
                ? 'Passer au thème clair'
                : 'Passer au thème sombre',
            onPressed: controller.toggleTheme,
            padding: EdgeInsets.all(AppSpacing.sm),
            splashRadius: 24,
          ),
          if (showLabel)
            Padding(
              padding: EdgeInsets.only(left: AppSpacing.sm),
              child: Text(
                controller.darkMode ? 'Mode Clair' : 'Mode Sombre',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Get.isDarkMode
                      ? AppColors.textLight
                      : AppColors.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
