import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  bool get isDarkMode => _box.read(_key) ?? false;

  ThemeMode get theme => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void changeTheme() {
    Get.changeThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
    _box.write(_key, !isDarkMode);
    update();
  }

  void initTheme() {
    Get.changeThemeMode(theme);
  }
}
