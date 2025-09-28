import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/map_controller.dart';
import '../services/delivery_service.dart';
import '../services/navigation_service.dart';

/// 🔗 Binding Carte - Alpha Delivery App
///
/// Initialise les contrôleurs et services pour la cartographie
class MapBinding extends Bindings {
  @override
  void dependencies() {
    debugPrint('🔗 Initialisation MapBinding...');

    // Service de livraison (si pas déjà initialisé)
    Get.lazyPut<DeliveryService>(
      () => DeliveryService(),
      fenix: true,
    );

    // Service de navigation GPS
    Get.lazyPut<NavigationService>(
      () => NavigationService(),
      fenix: true,
    );

    // Contrôleur de la carte
    Get.lazyPut<MapController>(
      () => MapController(),
      fenix: true,
    );

    debugPrint('✅ MapBinding initialisé');
  }
}
