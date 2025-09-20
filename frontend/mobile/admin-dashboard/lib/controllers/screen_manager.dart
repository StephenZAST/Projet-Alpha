import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/dashboard/dashboard_screen_new.dart';
import '../screens/articles/articles_screen.dart';
import '../screens/categories/categories_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/services/services_screen.dart';
import '../screens/users/users_screen.dart';
import '../screens/affiliates/affiliates_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/services/service_types_screen.dart';
import '../screens/services/service_article_couples_screen.dart';
import '../screens/subscriptions/subscription_management_page.dart';
import '../screens/offers/offers_screen.dart';
import '../screens/loyalty/loyalty_screen.dart';
import '../screens/delivery/delivery_screen.dart';
import '../constants.dart';

/// Gestionnaire centralisé des écrans pour éviter les instances multiples
class ScreenManager extends GetxController {
  static final ScreenManager _instance = ScreenManager._internal();
  factory ScreenManager() => _instance;
  ScreenManager._internal();

  // Cache des écrans pour éviter les reconstructions multiples
  final Map<int, Widget> _screenCache = {};
  final currentScreenIndex = 0.obs;

  /// Obtient un écran de manière sécurisée avec cache
  Widget getScreen(int index) {
    print('[ScreenManager] getScreen called with index: $index');
    
    // Mettre à jour l'index actuel
    currentScreenIndex.value = index;
    
    // Vérifier le cache d'abord
    if (_screenCache.containsKey(index)) {
      print('[ScreenManager] Returning cached screen for index: $index');
      return _screenCache[index]!;
    }

    // Créer et cacher le nouvel écran
    Widget screen = _createScreen(index);
    _screenCache[index] = screen;
    
    print('[ScreenManager] Created and cached new screen for index: $index');
    return screen;
  }

  /// Crée un nouvel écran basé sur l'index
  Widget _createScreen(int index) {
    switch (index) {
      case MenuIndices.dashboard:
        return DashboardScreenNew(key: Key('dashboard_${DateTime.now().millisecondsSinceEpoch}'));
      case MenuIndices.orders:
        return OrdersScreen(key: Key('orders_${DateTime.now().millisecondsSinceEpoch}'));
      case MenuIndices.services:
        return ServicesScreen(key: Key('services_${DateTime.now().millisecondsSinceEpoch}'));
      case MenuIndices.categories:
        return CategoriesScreen(key: Key('categories_${DateTime.now().millisecondsSinceEpoch}'));
      case MenuIndices.articles:
        return ArticlesScreen(key: Key('articles_${DateTime.now().millisecondsSinceEpoch}'));
      case MenuIndices.serviceTypes:
        return ServiceTypesScreen(key: Key('service_types_${DateTime.now().millisecondsSinceEpoch}'));
      case MenuIndices.serviceArticleCouples:
        return ServiceArticleCouplesScreen(key: Key('service_couples_${DateTime.now().millisecondsSinceEpoch}'));
      case MenuIndices.users:
        return UsersScreen(key: Key('users_${DateTime.now().millisecondsSinceEpoch}'));
      case MenuIndices.profile:
        return ProfileScreen(key: Key('profile_${DateTime.now().millisecondsSinceEpoch}'));
      case MenuIndices.notifications:
        return NotificationsScreen(key: Key('notifications_${DateTime.now().millisecondsSinceEpoch}'));
      case MenuIndices.subscriptions:
        return SubscriptionManagementPage(key: Key('subscriptions_${DateTime.now().millisecondsSinceEpoch}'));
      case MenuIndices.offers:
        return OffersScreen(key: Key('offers_${DateTime.now().millisecondsSinceEpoch}'));
      case MenuIndices.affiliates:
        return AffiliatesScreen(key: Key('affiliates_${DateTime.now().millisecondsSinceEpoch}'));
      case MenuIndices.loyalty:
        return LoyaltyScreen(key: Key('loyalty_${DateTime.now().millisecondsSinceEpoch}'));
      case MenuIndices.delivery:
        return DeliveryScreen(key: Key('delivery_${DateTime.now().millisecondsSinceEpoch}'));
      default:
        return DashboardScreenNew(key: Key('dashboard_default_${DateTime.now().millisecondsSinceEpoch}'));
    }
  }

  /// Force la recréation d'un écran spécifique
  void refreshScreen(int index) {
    print('[ScreenManager] Refreshing screen for index: $index');
    _screenCache.remove(index);
  }

  /// Force la recréation de tous les écrans
  void refreshAllScreens() {
    print('[ScreenManager] Refreshing all screens');
    _screenCache.clear();
  }

  /// Nettoie le cache des écrans non utilisés
  void cleanupUnusedScreens() {
    final currentIndex = currentScreenIndex.value;
    _screenCache.removeWhere((index, screen) => index != currentIndex);
    print('[ScreenManager] Cleaned up unused screens, kept index: $currentIndex');
  }

  /// Obtient le nom de l'écran pour le debug
  String getScreenName(int index) {
    switch (index) {
      case MenuIndices.dashboard:
        return 'Dashboard';
      case MenuIndices.orders:
        return 'Orders';
      case MenuIndices.services:
        return 'Services';
      case MenuIndices.categories:
        return 'Categories';
      case MenuIndices.articles:
        return 'Articles';
      case MenuIndices.serviceTypes:
        return 'ServiceTypes';
      case MenuIndices.serviceArticleCouples:
        return 'ServiceArticleCouples';
      case MenuIndices.users:
        return 'Users';
      case MenuIndices.profile:
        return 'Profile';
      case MenuIndices.notifications:
        return 'Notifications';
      case MenuIndices.subscriptions:
        return 'Subscriptions';
      case MenuIndices.offers:
        return 'Offers';
      case MenuIndices.affiliates:
        return 'Affiliates';
      case MenuIndices.loyalty:
        return 'Loyalty';
      case MenuIndices.delivery:
        return 'Delivery';
      default:
        return 'Unknown';
    }
  }

  @override
  void onInit() {
    super.onInit();
    print('[ScreenManager] Initialized');
  }

  @override
  void onClose() {
    _screenCache.clear();
    super.onClose();
  }
}