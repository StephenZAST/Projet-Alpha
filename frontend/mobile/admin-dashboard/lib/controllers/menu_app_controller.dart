import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/admin_routes.dart';

class MenuAppController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final _selectedIndex = 0.obs;

  int get selectedIndex => _selectedIndex.value;

  void controlMenu() {
    if (!scaffoldKey.currentState!.isDrawerOpen) {
      scaffoldKey.currentState!.openDrawer();
    }
  }

  void updateSelectedIndex(int index) {
    _selectedIndex.value = index;
    // Navigation basée sur l'index sélectionné
    switch (index) {
      case 0:
        Get.offAllNamed(AdminRoutes.dashboard);
        break;
      case 1:
        Get.toNamed(AdminRoutes.orders);
        break;
      case 2:
        Get.toNamed(AdminRoutes.services);
        break;
      case 3:
        Get.toNamed(AdminRoutes.categories);
        break;
      case 4:
        Get.toNamed(AdminRoutes.users);
        break;
      case 5:
        Get.toNamed(AdminRoutes.profile);
        break;
    }
  }

  // Méthode pour mettre à jour l'index en fonction de la route actuelle
  void updateIndexFromRoute(String route) {
    switch (route) {
      case AdminRoutes.dashboard:
        _selectedIndex.value = 0;
        break;
      case AdminRoutes.orders:
        _selectedIndex.value = 1;
        break;
      case AdminRoutes.services:
        _selectedIndex.value = 2;
        break;
      case AdminRoutes.categories:
        _selectedIndex.value = 3;
        break;
      case AdminRoutes.users:
        _selectedIndex.value = 4;
        break;
      case AdminRoutes.profile:
        _selectedIndex.value = 5;
        break;
      default:
        if (route.startsWith(AdminRoutes.orders)) {
          _selectedIndex.value = 1;
        }
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Écouter les changements de route pour mettre à jour l'index sélectionné
    ever(Get.routing.current as RxString, (String route) {
      updateIndexFromRoute(route);
    });
  }
}
