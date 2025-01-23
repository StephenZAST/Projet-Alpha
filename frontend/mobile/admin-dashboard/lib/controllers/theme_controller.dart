import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _storage = GetStorage();
  final _key = 'isDarkMode';

  final isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _loadThemeFromStorage();
    _applyTheme();
  }

  bool _loadThemeFromStorage() {
    return _storage.read(_key) ?? false;
  }

  void _saveThemeToStorage() {
    _storage.write(_key, isDarkMode.value);
  }

  void _applyTheme() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _applyTheme();
    _saveThemeToStorage();
  }

  void setDarkMode(bool value) {
    isDarkMode.value = value;
    _applyTheme();
    _saveThemeToStorage();
  }

  bool get darkMode => isDarkMode.value;
}
