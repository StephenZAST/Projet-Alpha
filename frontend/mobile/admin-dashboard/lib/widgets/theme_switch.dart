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
    final controller = Get.find<ThemeController>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() => IconButton(
              icon: Icon(
                controller.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: controller.toggleTheme,
              tooltip: controller.isDarkMode ? 'Mode clair' : 'Mode sombre',
            )),
        if (showLabel)
          Obx(() => Text(
                controller.isDarkMode ? 'Mode sombre' : 'Mode clair',
                style: Theme.of(context).textTheme.bodyMedium,
              )),
      ],
    );
  }
}
