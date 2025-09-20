import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants.dart';
import '../routes/admin_routes.dart';
import '../controllers/users_controller.dart';
import '../controllers/affiliates_controller.dart';
import '../controllers/loyalty_controller.dart';
import '../controllers/delivery_controller.dart';
import '../controllers/screen_manager.dart';
import '../utils/controller_manager.dart';

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
    if (index == MenuIndices.affiliates &&
        !Get.isRegistered<AffiliatesController>()) {
      Get.put(AffiliatesController());
    }

    // Si on navigue vers l'écran de fidélité, initialiser le contrôleur
    if (index == MenuIndices.loyalty &&
        !Get.isRegistered<LoyaltyController>()) {
      Get.put(LoyaltyController());
    }

    // Si on navigue vers l'écran de livraison, initialiser le contrôleur
    if (index == MenuIndices.delivery &&
        !Get.isRegistered<DeliveryController>()) {
      Get.put(DeliveryController());
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
      case MenuIndices.loyalty:
        return 'LoyaltyScreen';
      case MenuIndices.delivery:
        return 'DeliveryScreen';
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
  void goToLoyalty() => updateIndex(8); // ⭐ Nouvelle section Loyalty & Rewards
  void goToDelivery() => updateIndex(9); // 🚚 Nouvelle section Gestion Livreurs
  void goToProfile() => updateIndex(10);
  void goToNotifications() => updateIndex(11);
  void goToSubscriptions() => updateIndex(13); // Nouvelle section

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
      case MenuIndices.loyalty:
        return 'Système de Fidélité';
      case MenuIndices.delivery:
        return 'Gestion Livreurs';
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

    try {
      // Initialiser tous les contrôleurs nécessaires
      ControllerManager.initializeAllControllers();
      
      // Initialiser le ScreenManager s'il n'existe pas
      if (!Get.isRegistered<ScreenManager>()) {
        Get.put(ScreenManager(), permanent: true);
      }
      
      final screenManager = Get.find<ScreenManager>();
      
      // Initialiser les contrôleurs spécifiques selon l'écran
      _initializeScreenControllers(index);
      
      // Obtenir l'écran via le ScreenManager
      return screenManager.getScreen(index);
      
    } catch (e) {
      print('[MenuAppController] Error getting screen: $e');
      // Fallback vers le dashboard en cas d'erreur
      return Container(
        child: Center(
          child: Text('Erreur de chargement de l\'écran'),
        ),
      );
    }
  }

  void _initializeScreenControllers(int index) {
    switch (index) {
      case MenuIndices.users:
        if (!Get.isRegistered<UsersController>()) {
          Get.put(UsersController(), permanent: true);
        }
        break;
      case MenuIndices.affiliates:
        if (!Get.isRegistered<AffiliatesController>()) {
          Get.put(AffiliatesController(), permanent: true);
        }
        break;
      case MenuIndices.loyalty:
        if (!Get.isRegistered<LoyaltyController>()) {
          Get.put(LoyaltyController(), permanent: true);
        }
        break;
      case MenuIndices.delivery:
        if (!Get.isRegistered<DeliveryController>()) {
          Get.put(DeliveryController(), permanent: true);
        }
        break;
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
