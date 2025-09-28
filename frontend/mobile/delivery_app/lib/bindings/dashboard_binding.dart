import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';
import '../services/delivery_service.dart';

/// 🔗 Binding Dashboard - Alpha Delivery App
///
/// Initialise les contrôleurs et services pour le dashboard
class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    debugPrint('🔗 Initialisation DashboardBinding...');

    // Service de livraison (si pas déjà initialisé)
    Get.lazyPut<DeliveryService>(
      () => DeliveryService(),
      fenix: true,
    );

    // Contrôleur du dashboard
    Get.lazyPut<DashboardController>(
      () => DashboardController(),
      fenix: true,
    );

    debugPrint('✅ DashboardBinding initialisé');
  }
}
