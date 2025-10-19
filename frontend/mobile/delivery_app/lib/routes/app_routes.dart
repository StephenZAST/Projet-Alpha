import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/orders/order_details_screen.dart';
import '../screens/orders/advanced_search_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/map/delivery_map_screen.dart';

import '../bindings/auth_binding.dart';
import '../bindings/dashboard_binding.dart';
import '../bindings/orders_binding.dart';
import '../bindings/map_binding.dart';
import '../bindings/profile_binding.dart';
import '../services/auth_service.dart';

/// 🧭 Configuration des Routes - Alpha Delivery App
///
/// Définit toutes les routes de navigation avec leurs bindings
/// et middlewares pour une navigation mobile optimisée.
class AppRoutes {
  // ==========================================================================
  // 📍 NOMS DES ROUTES
  // ==========================================================================

  static const String initial = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String orders = '/orders';
  static const String orderDetails = '/orders/details';
  static const String advancedSearch = '/orders/search';
  static const String map = '/map';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // ==========================================================================
  // 🗺️ DÉFINITION DES ROUTES
  // ==========================================================================

  static List<GetPage> get routes => [
        // Route initiale - Écran de splash
        GetPage(
          name: initial,
          page: () => const SplashScreen(),
          transition: Transition.fade,
        ),

        // =======================================================================
        // 🔐 AUTHENTIFICATION
        // =======================================================================

        GetPage(
          name: login,
          page: () => const LoginScreen(),
          binding: AuthBinding(),
          transition: Transition.fadeIn,
        ),

        // =======================================================================
        // 🏠 DASHBOARD PRINCIPAL
        // =======================================================================

        GetPage(
          name: dashboard,
          page: () => const DashboardScreen(),
          binding: DashboardBinding(),
          transition: Transition.cupertino,
          middlewares: [AuthMiddleware()],
        ),

        // =======================================================================
        // 📦 GESTION DES COMMANDES
        // =======================================================================

        GetPage(
          name: orders,
          page: () => const OrdersScreen(),
          binding: OrdersBinding(),
          transition: Transition.cupertino,
          middlewares: [AuthMiddleware()],
        ),

        GetPage(
          name: orderDetails,
          page: () => const OrderDetailsScreen(),
          binding: OrdersBinding(),
          transition: Transition.rightToLeft,
          middlewares: [AuthMiddleware()],
        ),

        GetPage(
          name: advancedSearch,
          page: () => const AdvancedSearchScreen(),
          binding: OrdersBinding(),
          transition: Transition.rightToLeft,
          middlewares: [AuthMiddleware()],
        ),

        // =======================================================================
        // 🗺️ CARTE ET NAVIGATION
        // =======================================================================

        GetPage(
          name: map,
          page: () => const DeliveryMapScreen(),
          binding: MapBinding(),
          transition: Transition.cupertino,
          middlewares: [AuthMiddleware()],
        ),

        // =======================================================================
        // 👤 PROFIL ET PARAMÈTRES
        // =======================================================================

        GetPage(
          name: profile,
          page: () => const ProfileScreen(),
          binding: ProfileBinding(),
          transition: Transition.cupertino,
          middlewares: [AuthMiddleware()],
        ),

        GetPage(
          name: settings,
          page: () => const SettingsScreen(),
          binding: ProfileBinding(),
          transition: Transition.rightToLeft,
          middlewares: [AuthMiddleware()],
        ),
      ];

  // ==========================================================================
  // 🔄 MÉTHODES DE NAVIGATION UTILITAIRES
  // ==========================================================================

  /// Navigation vers le dashboard avec nettoyage de la pile
  static void toDashboard() {
    Get.offAllNamed(dashboard);
  }

  /// Navigation vers la page de connexion avec nettoyage de la pile
  static void toLogin() {
    Get.offAllNamed(login);
  }

  /// Navigation vers les détails d'une commande
  static void toOrderDetails(String orderId) {
    Get.toNamed(orderDetails, arguments: {'orderId': orderId});
  }

  /// Navigation vers la carte avec filtres optionnels
  static void toMap({Map<String, dynamic>? filters}) {
    Get.toNamed(map, arguments: filters);
  }

  /// Navigation vers les paramètres
  static void toSettings() {
    Get.toNamed(settings);
  }

  /// Retour à la page précédente avec vérification
  static void back() {
    if (Navigator.canPop(Get.context!)) {
      Get.back();
    } else {
      Get.offAllNamed(dashboard);
    }
  }

  /// Navigation avec transition personnalisée
  static void toWithTransition(
    String route, {
    dynamic arguments,
    Transition? transition,
  }) {
    if (transition != null) {
      Get.toNamed(
        route,
        arguments: arguments,
      )?.then((_) {
        // Appliquer la transition si nécessaire
        // Note: Get.toNamed ne supporte pas directement les transitions
        // Cette méthode peut être étendue si nécessaire
      });
    } else {
      Get.toNamed(
        route,
        arguments: arguments,
      );
    }
  }
}

/// 🛡️ Middleware d'Authentification
///
/// Vérifie que l'utilisateur est connecté avant d'accéder aux routes protégées
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // Vérification de l'authentification
    try {
      final authService = Get.find<AuthService>();

      debugPrint('🔐 [AuthMiddleware] Vérification pour: $route');
      debugPrint(
          '📊 [AuthMiddleware] Authentifié: ${authService.isAuthenticated}');

      // Si la route est login ou initial, on la laisse passer
      if (route == AppRoutes.login || route == AppRoutes.initial) {
        // Mais si l'utilisateur est déjà authentifié, rediriger vers dashboard
        if (authService.isAuthenticated) {
          debugPrint(
              '✅ [AuthMiddleware] Utilisateur déjà connecté, redirection vers dashboard');
          return const RouteSettings(name: AppRoutes.dashboard);
        }
        return null;
      }

      // Pour les autres routes, on vérifie l'authentification
      if (!authService.isAuthenticated) {
        debugPrint(
            '❌ [AuthMiddleware] Non authentifié, redirection vers login');
        return const RouteSettings(name: AppRoutes.login);
      }

      debugPrint('✅ [AuthMiddleware] Accès autorisé à: $route');
      return null;
    } catch (e) {
      debugPrint('❌ [AuthMiddleware] Erreur: $e');
      return const RouteSettings(name: AppRoutes.login);
    }
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    debugPrint('🧭 Navigation vers: ${page?.name}');
    return page;
  }

  @override
  List<Bindings>? onBindingsStart(List<Bindings>? bindings) {
    debugPrint('🔗 Initialisation des bindings: ${bindings?.length}');
    return bindings;
  }

  @override
  GetPageBuilder? onPageBuildStart(GetPageBuilder? page) {
    debugPrint('🏗️ Construction de la page commencée');
    return page;
  }

  @override
  Widget onPageBuilt(Widget page) {
    debugPrint('✅ Page construite avec succès');
    return page;
  }
}

/// 🎯 Extensions utiles pour la navigation
extension AppRoutesExtension on GetInterface {
  /// Vérifie si on peut revenir en arrière
  bool get canGoBack {
    final context = Get.context;
    return context != null && Navigator.canPop(context);
  }

  /// Navigation sécurisée avec gestion d'erreur
  Future<T?>? toNamedSafe<T>(
    String page, {
    dynamic arguments,
    Map<String, String>? parameters,
  }) {
    try {
      return toNamed<T>(page, arguments: arguments, parameters: parameters);
    } catch (e) {
      debugPrint('❌ Erreur de navigation vers $page: $e');
      return null;
    }
  }

  /// Remplacement sécurisé de la route actuelle
  Future<T?>? offNamedSafe<T>(
    String page, {
    dynamic arguments,
    Map<String, String>? parameters,
  }) {
    try {
      return offNamed<T>(page, arguments: arguments, parameters: parameters);
    } catch (e) {
      debugPrint('❌ Erreur de remplacement vers $page: $e');
      return null;
    }
  }

  /// Navigation avec nettoyage complet sécurisé
  Future<T?>? offAllNamedSafe<T>(
    String page, {
    dynamic arguments,
    Map<String, String>? parameters,
  }) {
    try {
      return offAllNamed<T>(page, arguments: arguments, parameters: parameters);
    } catch (e) {
      debugPrint('❌ Erreur de navigation complète vers $page: $e');
      return null;
    }
  }
}
