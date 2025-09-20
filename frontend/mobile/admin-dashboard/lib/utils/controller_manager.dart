import 'package:get/get.dart';
import '../controllers/article_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/affiliates_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/orders_controller.dart';

/// Gestionnaire centralisé des contrôleurs pour éviter les conflits de navigation
class ControllerManager {
  static final ControllerManager _instance = ControllerManager._internal();
  factory ControllerManager() => _instance;
  ControllerManager._internal();

  /// Initialise tous les contrôleurs de manière sécurisée
  static void initializeAllControllers() {
    try {
      // Dashboard Controller
      if (!Get.isRegistered<DashboardController>()) {
        Get.put(DashboardController(), permanent: true);
        print('[ControllerManager] DashboardController initialisé');
      }

      // Article Controller
      if (!Get.isRegistered<ArticleController>()) {
        Get.put(ArticleController(), permanent: true);
        print('[ControllerManager] ArticleController initialisé');
      }

      // Category Controller
      if (!Get.isRegistered<CategoryController>()) {
        Get.put(CategoryController(), permanent: true);
        print('[ControllerManager] CategoryController initialisé');
      }

      // Affiliates Controller
      if (!Get.isRegistered<AffiliatesController>()) {
        Get.put(AffiliatesController(), permanent: true);
        print('[ControllerManager] AffiliatesController initialisé');
      }

      // Orders Controller
      if (!Get.isRegistered<OrdersController>()) {
        Get.put(OrdersController(), permanent: true);
        print('[ControllerManager] OrdersController initialisé');
      }

      print('[ControllerManager] Tous les contrôleurs sont initialisés');
    } catch (e) {
      print('[ControllerManager] Erreur lors de l\'initialisation: $e');
    }
  }

  /// Récupère un contrôleur de manière sécurisée
  static T safeGet<T extends GetxController>() {
    try {
      if (Get.isRegistered<T>()) {
        return Get.find<T>();
      } else {
        throw Exception('Controller ${T.toString()} not registered');
      }
    } catch (e) {
      print('[ControllerManager] Erreur lors de la récupération de ${T.toString()}: $e');
      rethrow;
    }
  }

  /// Réinitialise un contrôleur spécifique si nécessaire
  static void resetController<T extends GetxController>() {
    try {
      if (Get.isRegistered<T>()) {
        Get.delete<T>();
        print('[ControllerManager] ${T.toString()} supprimé');
      }
    } catch (e) {
      print('[ControllerManager] Erreur lors de la suppression de ${T.toString()}: $e');
    }
  }

  /// Nettoie tous les contrôleurs (à utiliser avec précaution)
  static void disposeAll() {
    try {
      Get.deleteAll();
      print('[ControllerManager] Tous les contrôleurs supprimés');
    } catch (e) {
      print('[ControllerManager] Erreur lors de la suppression: $e');
    }
  }

  /// Vérifie l'état des contrôleurs
  static void checkControllersStatus() {
    print('[ControllerManager] État des contrôleurs:');
    print('- DashboardController: ${Get.isRegistered<DashboardController>()}');
    print('- ArticleController: ${Get.isRegistered<ArticleController>()}');
    print('- CategoryController: ${Get.isRegistered<CategoryController>()}');
    print('- AffiliatesController: ${Get.isRegistered<AffiliatesController>()}');
    print('- OrdersController: ${Get.isRegistered<OrdersController>()}');
  }
}