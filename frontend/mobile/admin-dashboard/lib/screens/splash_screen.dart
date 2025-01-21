import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    // Vérifier l'auth de manière asynchrone
    authController.checkAuth().then((_) {
      if (authController.isAuthenticated) {
        Get.offAllNamed('/dashboard');
      } else {
        Get.offAllNamed('/login');
      }
    });

    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
