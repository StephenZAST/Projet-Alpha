import 'package:admin/controllers/menu_app_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _storage = GetStorage();
  final _key = 'isDarkMode';
  final _isDarkMode = true.obs; // Rendre la variable observable

  bool get isDarkMode => _isDarkMode.value;

  @override
  void onInit() {
    super.onInit();
    _isDarkMode.value = _storage.read(_key) ?? true;
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void _applyTheme() {
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    // Reset the menu state to avoid UI glitches
    if (Get.isRegistered<MenuAppController>()) {
      final menuController = Get.find<MenuAppController>();
      final currentIndex = menuController.selectedIndex.value;
      // Preserve the current route while refreshing the state
      WidgetsBinding.instance.addPostFrameCallback((_) {
        menuController.updateIndex(currentIndex);
      });
    }
  }

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    _storage.write(_key, _isDarkMode.value);
    _applyTheme();
  }

  void setDarkMode(bool value) {
    _isDarkMode.value = value;
    _storage.write(_key, value);
    _applyTheme();
  }

  bool get darkMode => isDarkMode;
}
