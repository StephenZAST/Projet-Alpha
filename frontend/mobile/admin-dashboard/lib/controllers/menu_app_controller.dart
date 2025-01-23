import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/admin_routes.dart';

class MenuAppController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final _selectedIndex = 0.obs;
  final _isDrawerOpen = false.obs;
  final _currentRoute = ''.obs;

  int get selectedIndex => _selectedIndex.value;
  bool get isDrawerOpen => _isDrawerOpen.value;
  String get currentRoute => _currentRoute.value;

  void controlMenu() {
    print('[MenuAppController] controlMenu called');
    print('[MenuAppController] scaffoldKey: $scaffoldKey');

    try {
      if (scaffoldKey.currentState == null) {
        print('[MenuAppController] Error: scaffoldKey.currentState is null');
        return;
      }

      if (!scaffoldKey.currentState!.isDrawerOpen) {
        print('[MenuAppController] Opening drawer');
        scaffoldKey.currentState!.openDrawer();
        _isDrawerOpen.value = true;
      } else {
        print('[MenuAppController] Closing drawer');
        scaffoldKey.currentState!.closeDrawer();
        _isDrawerOpen.value = false;
      }
    } catch (e) {
      print('[MenuAppController] Error controlling drawer: $e');
    }
  }

  void closeDrawer() {
    scaffoldKey.currentState?.closeDrawer();
    _isDrawerOpen.value = false;
  }

  void updateIndex(int index) {
    print('[MenuAppController] Updating index to: $index');
    _selectedIndex.value = index;
    _currentRoute.value = AdminRoutes.getRouteByIndex(index);

    // Fermer le drawer après la sélection sur mobile
    if (_isDrawerOpen.value) {
      closeDrawer();
    }
  }

  void setDrawerState(bool isOpen) {
    _isDrawerOpen.value = isOpen;
  }

  // Navigation directe via index
  void goToDashboard() => updateIndex(0);
  void goToOrders() => updateIndex(1);
  void goToServices() => updateIndex(2);
  void goToCategories() => updateIndex(3);
  void goToUsers() => updateIndex(4);
  void goToProfile() => updateIndex(5);
  void goToNotifications() => updateIndex(6);

  // Obtenir le titre de la page actuelle
  String getCurrentPageTitle() {
    switch (_selectedIndex.value) {
      case 0:
        return 'Tableau de bord';
      case 1:
        return 'Commandes';
      case 2:
        return 'Services';
      case 3:
        return 'Catégories';
      case 4:
        return 'Utilisateurs';
      case 5:
        return 'Profil';
      case 6:
        return 'Notifications';
      default:
        return 'Tableau de bord';
    }
  }

  // Synchroniser l'index avec la route actuelle
  void syncWithRoute(String route) {
    if (route != _currentRoute.value) {
      final index = AdminRoutes.getIndexByRoute(route);
      if (index != _selectedIndex.value) {
        _selectedIndex.value = index;
        _currentRoute.value = route;
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    print('[MenuAppController] Initialized with scaffoldKey: $scaffoldKey');

    // Écouter les changements de route
    ever(_currentRoute, (route) {
      print('[MenuAppController] Route changed to: $route');
    });

    // Écouter les changements d'index
    ever(_selectedIndex, (index) {
      print('[MenuAppController] Index changed to: $index');
    });
  }

  @override
  void onReady() {
    super.onReady();
    print('[MenuAppController] Ready with scaffoldKey: $scaffoldKey');
  }
}
