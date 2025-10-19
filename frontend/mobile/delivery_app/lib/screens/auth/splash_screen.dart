import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants.dart';
import '../../services/auth_service.dart';

/// 🎯 Écran de Splash / Initialisation
///
/// Affiche un écran de chargement pendant que la session
/// est vérifiée et restaurée depuis le stockage local.
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Lancer la vérification de la session
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Initialise l'application et vérifie la session
  Future<void> _initializeApp() async {
    try {
      debugPrint('🔍 [SplashScreen] Vérification de la session...');

      // Attend un peu pour l'UX (affiche le splash)
      await Future.delayed(const Duration(milliseconds: 800));

      // Récupère le service d'authentification
      final authService = Get.find<AuthService>();

      debugPrint(
          '📊 [SplashScreen] État: isAuthenticated=${authService.isAuthenticated}');

      // Vérifie si l'utilisateur est authentifié
      if (authService.isAuthenticated) {
        debugPrint(
            '✅ [SplashScreen] Utilisateur authentifié, accès au dashboard');

        // Navigation vers le dashboard
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed('/dashboard');
      } else {
        debugPrint(
            '❌ [SplashScreen] Utilisateur non authentifié, accès à la connexion');

        // Navigation vers la page de connexion
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed('/login');
      }
    } catch (e) {
      debugPrint('❌ [SplashScreen] Erreur: $e');

      // En cas d'erreur, on va sur la page de connexion
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.gray50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animé
            ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0)
                  .animate(_animationController),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.local_shipping_rounded,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Titre
            Text(
              'Alpha Delivery',
              style: AppTextStyles.h3.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Sous-titre
            Text(
              'Service de livraison de laverie',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Indicateur de chargement
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              strokeWidth: 3,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Texte de chargement
            FadeTransition(
              opacity: _animationController,
              child: Text(
                'Initialisation...',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.gray500 : AppColors.gray600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
