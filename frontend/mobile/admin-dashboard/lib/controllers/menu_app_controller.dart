import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/admin_routes.dart';

class MenuAppController extends GetxController {
  GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'MainScaffold');
  final _selectedIndex = 0.obs;
  final _currentRoute = ''.obs;
  final _isDrawerOpen = false.obs;

  int get selectedIndex => _selectedIndex.value;
  String get currentRoute => _currentRoute.value;
  bool get isDrawerOpen => _isDrawerOpen.value;

  @override
  void onInit() {
    super.onInit();
    print('[MenuAppController] Initializing with scaffoldKey: $scaffoldKey');
    _currentRoute.value = Get.currentRoute;
    updateIndexFromRoute(_currentRoute.value);
    ever(_currentRoute,
        (route) => print('[MenuAppController] Route changed to: $route'));
  }

  void setDrawerState(bool isOpen) {
    _isDrawerOpen.value = isOpen;
  }

  void controlMenu() {
    try {
      print('[MenuAppController] controlMenu called');
      print('[MenuAppController] scaffoldKey: $scaffoldKey');
      print('[MenuAppController] currentState: ${scaffoldKey.currentState}');

      if (scaffoldKey.currentState != null) {
        if (scaffoldKey.currentState!.isDrawerOpen) {
          scaffoldKey.currentState?.closeDrawer();
          _isDrawerOpen.value = false;
        } else {
          scaffoldKey.currentState?.openDrawer();
          _isDrawerOpen.value = true;
        }
      } else {
        print('[MenuAppController] Error: scaffoldKey.currentState is null');
      }
    } catch (e) {
      print('[MenuAppController] Error controlling drawer: $e');
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
}
