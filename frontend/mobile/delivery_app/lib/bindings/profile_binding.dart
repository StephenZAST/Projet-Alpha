import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/delivery_service.dart';
import '../controllers/profile_controller.dart';

/// 🔗 Binding Profil - Alpha Delivery App
///
/// Initialise les contrôleurs et services pour le profil utilisateur
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    debugPrint('🔗 Initialisation ProfileBinding...');

    // Service de livraison (si pas déjà initialisé)
    Get.lazyPut<DeliveryService>(
      () => DeliveryService(),
      fenix: true,
    );

    // Contrôleur du profil
    Get.lazyPut<ProfileController>(
      () => ProfileController(),
      fenix: true,
    );

    debugPrint('✅ ProfileBinding initialisé');
  }
}
