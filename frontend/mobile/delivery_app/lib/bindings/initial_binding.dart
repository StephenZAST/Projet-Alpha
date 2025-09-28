import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../controllers/app_controller.dart';

/// 🔗 Binding Initial - Alpha Delivery App
///
/// Initialise tous les services et contrôleurs globaux
/// nécessaires au fonctionnement de l'application.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    debugPrint('🔗 Initialisation des dépendances globales...');

    // =======================================================================
    // 🛠️ SERVICES CORE (Permanent)
    // =======================================================================

    // Service d'authentification - DOIT être initialisé en premier
    Get.put<AuthService>(
      AuthService(),
      permanent: true,
    );

    // Service API - Communication avec le backend
    Get.put<ApiService>(
      ApiService(),
      permanent: true,
    );

    // Service de géolocalisation
    Get.put<LocationService>(
      LocationService(),
      permanent: true,
    );

    // Service de notifications
    Get.put<NotificationService>(
      NotificationService(),
      permanent: true,
    );

    // =======================================================================
    // 🎮 CONTRÔLEURS GLOBAUX
    // =======================================================================

    // Contrôleur principal de l'application
    Get.put<AppController>(
      AppController(),
      permanent: true,
    );

    debugPrint('✅ Dépendances globales initialisées');
  }
}
