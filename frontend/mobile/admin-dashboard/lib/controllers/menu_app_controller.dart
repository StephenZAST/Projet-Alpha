import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/admin_routes.dart';

class MenuAppController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final _selectedIndex = 0.obs;
  final _currentRoute = ''.obs;

  int get selectedIndex => _selectedIndex.value;
  String get currentRoute => _currentRoute.value;

  void controlMenu() {
    final state = scaffoldKey.currentState;
    if (state != null && !state.isDrawerOpen) {
      state.openDrawer();
    }
  }

  void _navigateTo(String route, {bool offAll = false}) {
    if (offAll) {
      Get.offAllNamed(route);
    } else {
      Get.toNamed(route);
    }
    _currentRoute.value = route;
    updateIndexFromRoute(route);
  }

  void updateSelectedIndex(int index) {
    _selectedIndex.value = index;
    // Navigation basée sur l'index sélectionné
    switch (index) {
      case 0:
        _navigateTo(AdminRoutes.dashboard, offAll: true);
        break;
      case 1:
        _navigateTo(AdminRoutes.orders);
        break;
      case 2:
        _navigateTo(AdminRoutes.services);
        break;
      case 3:
        _navigateTo(AdminRoutes.categories);
        break;
      case 4:
        _navigateTo(AdminRoutes.users);
        break;
      case 5:
        _navigateTo(AdminRoutes.profile);
        break;
    }
  }

  // Méthode pour mettre à jour l'index en fonction de la route actuelle
  void updateIndexFromRoute(String route) {
    _currentRoute.value = route;
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
    // Initialiser avec la route actuelle
    _currentRoute.value = Get.currentRoute;
    updateIndexFromRoute(_currentRoute.value);

    // Écouter les changements de route
    ever(_currentRoute, (route) => print('Route changed to: $route'));
  }
}
