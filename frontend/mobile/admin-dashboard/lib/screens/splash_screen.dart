import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants.dart';
import '../controllers/auth_controller.dart';

class SplashScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo ou icône de l'application
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cleaning_services,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Alpha Laundry Admin',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
