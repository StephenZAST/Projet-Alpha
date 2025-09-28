import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

/// 🔗 Binding d'Authentification - Alpha Delivery App
///
/// Initialise les contrôleurs nécessaires pour l'authentification
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    debugPrint('🔗 Initialisation AuthBinding...');

    // Contrôleur d'authentification
    Get.lazyPut<AuthController>(
      () => AuthController(),
      fenix: true,
    );

    debugPrint('✅ AuthBinding initialisé');
  }
}
