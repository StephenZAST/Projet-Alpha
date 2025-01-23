import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DrawerService extends GetxService {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final _isDrawerOpen = false.obs;

  bool get isDrawerOpen => _isDrawerOpen.value;

  void toggleDrawer() {
    try {
      print('[DrawerService] Toggle drawer called');
      if (scaffoldKey.currentState == null) {
        print('[DrawerService] Error: scaffoldKey.currentState is null');
        return;
      }

      if (!scaffoldKey.currentState!.isDrawerOpen) {
        print('[DrawerService] Opening drawer');
        scaffoldKey.currentState?.openDrawer();
        _isDrawerOpen.value = true;
      } else {
        print('[DrawerService] Closing drawer');
        scaffoldKey.currentState?.closeDrawer();
        _isDrawerOpen.value = false;
      }
    } catch (e) {
      print('[DrawerService] Error controlling drawer: $e');
    }
  }

  void closeDrawer() {
    if (scaffoldKey.currentState?.isDrawerOpen ?? false) {
      scaffoldKey.currentState?.closeDrawer();
      _isDrawerOpen.value = false;
    }
  }

  static DrawerService get to => Get.find<DrawerService>();
}
