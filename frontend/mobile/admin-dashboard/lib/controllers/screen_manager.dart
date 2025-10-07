import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/articles/articles_screen.dart';
import '../screens/categories/categories_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/services/services_screen.dart';
import '../screens/users/users_screen.dart';
import '../screens/affiliates/affiliate_management_screen.dart';
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

    // Pour ArticlesScreen, toujours créer une nouvelle instance pour éviter les problèmes
    if (index == MenuIndices.articles) {
      print('[ScreenManager] Creating fresh ArticlesScreen instance');
      return _createScreen(index);
    }

    // Vérifier le cache d'abord pour les autres écrans
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
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    switch (index) {
      case MenuIndices.dashboard:
        return DashboardScreen(key: Key('dashboard_$timestamp'));
      case MenuIndices.orders:
        return _wrapWithKey(OrdersScreen(), 'orders_$timestamp');
      case MenuIndices.services:
        return _wrapWithKey(ServicesScreen(), 'services_$timestamp');
      case MenuIndices.categories:
        return _wrapWithKey(CategoriesScreen(), 'categories_$timestamp');
      case MenuIndices.articles:
        return ArticlesScreen(key: Key('articles_$timestamp'));
      case MenuIndices.serviceTypes:
        return _wrapWithKey(ServiceTypesScreen(), 'service_types_$timestamp');
      case MenuIndices.serviceArticleCouples:
        return _wrapWithKey(
            ServiceArticleCouplesScreen(), 'service_couples_$timestamp');
      case MenuIndices.users:
        return _wrapWithKey(UsersScreen(), 'users_$timestamp');
      case MenuIndices.profile:
        return _wrapWithKey(ProfileScreen(), 'profile_$timestamp');
      case MenuIndices.notifications:
        return _wrapWithKey(NotificationsScreen(), 'notifications_$timestamp');
      case MenuIndices.subscriptions:
        return _wrapWithKey(
            SubscriptionManagementPage(), 'subscriptions_$timestamp');
      case MenuIndices.offers:
        return _wrapWithKey(OffersScreen(), 'offers_$timestamp');
      case MenuIndices.affiliates:
        return _wrapWithKey(
            AffiliateManagementScreen(), 'affiliates_$timestamp');
      case MenuIndices.loyalty:
        return _wrapWithKey(LoyaltyScreen(), 'loyalty_$timestamp');
      case MenuIndices.delivery:
        return _wrapWithKey(DeliveryScreen(), 'delivery_$timestamp');
      default:
        return DashboardScreen(key: Key('dashboard_default_$timestamp'));
    }
  }

  /// Enveloppe un écran dans un Container avec une clé unique
  Widget _wrapWithKey(Widget screen, String keyName) {
    return Container(
      key: Key(keyName),
      child: screen,
    );
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
    print(
        '[ScreenManager] Cleaned up unused screens, kept index: $currentIndex');
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
