import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants.dart'; // Ajout de l'import pour MenuIndices
import '../screens/articles/articles_screen.dart';
import '../screens/categories/categories_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/services/services_screen.dart';
import '../screens/services/service_types_screen.dart';
import '../screens/users/users_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../routes/admin_routes.dart';
import '../controllers/users_controller.dart';
import '../screens/services/service_article_couples_screen.dart';
import '../screens/subscriptions/subscription_management_page.dart';
import '../screens/offers/offers_screen.dart';
import '../screens/affiliates/affiliates_screen.dart';
import '../controllers/affiliates_controller.dart';

class MenuAppController extends GetxController {
  // Singleton pattern
  static final MenuAppController _instance = MenuAppController._internal();
  factory MenuAppController() => _instance;
  MenuAppController._internal();

  // GlobalKey unique
  final scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: 'MainScaffold');

  // Variables observables
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
    print('[MenuAppController] Current index: ${selectedIndex.value}');
    print('[MenuAppController] Trying to update to index: $index');

    selectedIndex.value = index;
    currentRoute.value = AdminRoutes.getRouteByIndex(index);

    print('[MenuAppController] New route: ${currentRoute.value}');
    print('[MenuAppController] Screen to show: ${_getScreenName(index)}');

    if (isDrawerOpen.value) {
      closeDrawer();
    }

    // Si on navigue vers l'écran des utilisateurs, initialiser le contrôleur
    if (index == MenuIndices.users && !Get.isRegistered<UsersController>()) {
      Get.put(UsersController());
    }
    
    // Si on navigue vers l'écran des affiliés, initialiser le contrôleur
    if (index == MenuIndices.affiliates && !Get.isRegistered<AffiliatesController>()) {
      Get.put(AffiliatesController());
    }
  }

  String _getScreenName(int index) {
    switch (index) {
      case MenuIndices.dashboard:
        return 'DashboardScreen';
      case MenuIndices.orders:
        return 'OrdersScreen';
      case MenuIndices.services:
        return 'ServicesScreen';
      case MenuIndices.categories:
        return 'CategoriesScreen';
      case MenuIndices.articles:
        return 'ArticlesScreen';
      case MenuIndices.serviceTypes:
        return 'ServiceTypesScreen';
      case MenuIndices.users:
        return 'UsersScreen';
      case MenuIndices.profile:
        return 'ProfileScreen';
      case MenuIndices.notifications:
        return 'NotificationsScreen';
      case MenuIndices.serviceArticleCouples:
        return 'ServiceArticleCouplesScreen';
      case MenuIndices.subscriptions:
        return 'SubscriptionManagementPage';
      case MenuIndices.affiliates:
        return 'AffiliatesScreen';
      default:
        return 'Unknown';
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
  void goToArticles() => updateIndex(4); // Nouvelle section
  void goToServiceTypes() => updateIndex(5); // Nouvelle section
  void goToUsers() => updateIndex(6);
  void goToAffiliates() => updateIndex(7); // 🤝 Nouvelle section Affiliés
  void goToProfile() => updateIndex(8);
  void goToNotifications() => updateIndex(9);
  void goToSubscriptions() => updateIndex(11); // Nouvelle section

  // Obtenir le titre de la page actuelle
  String getCurrentPageTitle() {
    switch (selectedIndex.value) {
      case MenuIndices.dashboard:
        return 'Tableau de bord';
      case MenuIndices.orders:
        return 'Commandes';
      case MenuIndices.services:
        return 'Services';
      case MenuIndices.categories:
        return 'Catégories';
      case MenuIndices.articles:
        return 'Articles';
      case MenuIndices.serviceTypes:
        return 'Types de services';
      case MenuIndices.users:
        return 'Utilisateurs';
      case MenuIndices.profile:
        return 'Profil';
      case MenuIndices.notifications:
        return 'Notifications';
      case MenuIndices.subscriptions:
        return 'Abonnements';
      case MenuIndices.affiliates:
        return 'Affiliés';
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

  Widget getScreen() {
    final index = selectedIndex.value;
    print('[MenuAppController] getScreen called with index: $index');

    // Correction du switch statement
    switch (index) {
      case MenuIndices.dashboard:
        return DashboardScreen();
      case MenuIndices.orders:
        return OrdersScreen();
      case MenuIndices.services:
        return ServicesScreen();
      case MenuIndices.categories:
        return CategoriesScreen();
      case MenuIndices.articles:
        return ArticlesScreen();
      case MenuIndices.serviceTypes:
        return ServiceTypesScreen();
      case MenuIndices.serviceArticleCouples:
        return ServiceArticleCouplesScreen();
      case MenuIndices.users:
        // S'assurer que le UsersController est enregistré
        if (!Get.isRegistered<UsersController>()) {
          Get.put(UsersController(), permanent: true);
        }
        return UsersScreen();
      case MenuIndices.profile:
        return const ProfileScreen();
      case MenuIndices.notifications:
        return NotificationsScreen();
      case MenuIndices.subscriptions:
        return SubscriptionManagementPage();
      case MenuIndices.offers:
        return OffersScreen();
      case MenuIndices.affiliates:
        // S'assurer que le AffiliatesController est enregistré
        if (!Get.isRegistered<AffiliatesController>()) {
          Get.put(AffiliatesController(), permanent: true);
        }
        return AffiliatesScreen();
      default:
        return DashboardScreen();
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
