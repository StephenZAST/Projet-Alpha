import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/delivery_service.dart';
import '../controllers/orders_controller.dart';

/// 🔗 Binding Commandes - Alpha Delivery App
///
/// Initialise les contrôleurs et services pour la gestion des commandes
class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    debugPrint('🔗 Initialisation OrdersBinding...');

    // Service de livraison (si pas déjà initialisé)
    Get.lazyPut<DeliveryService>(
      () => DeliveryService(),
      fenix: true,
    );

    // Contrôleur des commandes
    Get.lazyPut<OrdersController>(
      () => OrdersController(),
      fenix: true,
    );

    debugPrint('✅ OrdersBinding initialisé');
  }
}
