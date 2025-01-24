import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/admin_routes.dart';

class MenuAppController extends GetxController {
  final scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: 'MainScaffold');
  final selectedIndex = 0.obs;
  final isDrawerOpen = false.obs;
  final currentRoute = ''.obs;

  void controlMenu() {
    print('[MenuAppController] controlMenu called');

    try {
      if (scaffoldKey.currentState == null) {
        print('[MenuAppController] Error: scaffoldKey.currentState is null');
        return;
      }

      if (!scaffoldKey.currentState!.isDrawerOpen) {
        print('[MenuAppController] Opening drawer');
        scaffoldKey.currentState!.openDrawer();
        isDrawerOpen.value = true;
      } else {
        print('[MenuAppController] Closing drawer');
        scaffoldKey.currentState!.closeDrawer();
        isDrawerOpen.value = false;
      }
    } catch (e) {
      print('[MenuAppController] Error controlling drawer: $e');
    }
  }

  void closeDrawer() {
    scaffoldKey.currentState?.closeDrawer();
    isDrawerOpen.value = false;
  }

  void updateIndex(int index) {
    print('[MenuAppController] Updating index to: $index');
    selectedIndex.value = index;
    currentRoute.value = AdminRoutes.getRouteByIndex(index);

    // Fermer le drawer après la sélection sur mobile
    if (isDrawerOpen.value) {
      closeDrawer();
    }
  }

  void setDrawerState(bool isOpen) {
    isDrawerOpen.value = isOpen;
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
    switch (selectedIndex.value) {
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
    if (route != currentRoute.value) {
      final index = AdminRoutes.getIndexByRoute(route);
      if (index != selectedIndex.value) {
        selectedIndex.value = index;
        currentRoute.value = route;
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    print('[MenuAppController] Initialized with scaffoldKey: $scaffoldKey');

    ever(selectedIndex, (index) {
      print('[MenuAppController] Index changed to: $index');
    });

    ever(currentRoute, (route) {
      print('[MenuAppController] Route changed to: $route');
    });
  }
}
