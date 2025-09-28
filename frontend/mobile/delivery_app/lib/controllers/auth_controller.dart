import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';

/// 🔐 Contrôleur d'Authentification - Alpha Delivery App
/// 
/// Gère l'état d'authentification, la connexion, déconnexion
/// et la navigation conditionnelle pour les livreurs.
class AuthController extends GetxController {
  
  // ==========================================================================
  // 📦 SERVICES
  // ==========================================================================
  
  late final AuthService _authService;
  
  // ==========================================================================
  // 🎯 ÉTATS OBSERVABLES
  // ==========================================================================
  
  final _isLoading = false.obs;
  final _loginError = RxnString();
  
  // ==========================================================================
  // 🎯 GETTERS
  // ==========================================================================
  
  bool get isLoading => _isLoading.value;
  String? get loginError => _loginError.value;
  bool get isAuthenticated => _authService.isAuthenticated;
  
  // Getters observables
  RxBool get isLoadingRx => _isLoading;
  RxnString get loginErrorRx => _loginError;
  
  // ==========================================================================
  // 🚀 INITIALISATION
  // ==========================================================================
  
  @override
  void onInit() {
    super.onInit();
    debugPrint('🔐 Initialisation AuthController...');
    
    // Récupère le service d'authentification
    _authService = Get.find<AuthService>();
    
    // Écoute les changements d'état d'authentification
    _setupAuthListeners();
    
    debugPrint('✅ AuthController initialisé');
  }
  
  /// Configure les listeners d'authentification
  void _setupAuthListeners() {
    // Écoute les changements d'authentification
    ever(_authService.isAuthenticatedRx, (bool isAuthenticated) {
      if (isAuthenticated) {
        _onLoginSuccess();
      } else {
        _onLogoutComplete();
      }
    });
  }
  
  // ==========================================================================
  // 🔑 MÉTHODES D'AUTHENTIFICATION
  // ==========================================================================
  
  /// Connexion avec email et mot de passe
  Future<void> login(String email, String password, {bool rememberMe = false}) async {
    try {
      _isLoading.value = true;
      _loginError.value = null;
      
      debugPrint('🔐 Tentative de connexion pour: $email');
      
      final result = await _authService.login(email, password);
      
      if (result.success) {
        debugPrint('✅ Connexion réussie');
        
        // Affiche un message de succès
        _showSuccessMessage('Connexion réussie !');
        
        // La navigation sera gérée par le listener
        
      } else {
        debugPrint('❌ Échec de la connexion: ${result.message}');
        _loginError.value = result.message ?? 'Erreur de connexion';
        
        // Affiche l'erreur
        _showErrorMessage(result.message ?? 'Erreur de connexion');
      }
      
    } catch (e) {
      debugPrint('❌ Erreur lors de la connexion: $e');
      _loginError.value = 'Une erreur inattendue s\'est produite';
      
      _showErrorMessage('Une erreur inattendue s\'est produite');
      
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Déconnexion
  Future<void> logout() async {
    try {
      debugPrint('🚪 Déconnexion en cours...');
      
      // Affiche un indicateur de chargement
      _showLoadingDialog();
      
      await _authService.logout();
      
      // Ferme le dialog de chargement
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      debugPrint('✅ Déconnexion terminée');
      
      // Affiche un message de confirmation
      _showSuccessMessage('Déconnexion réussie');
      
    } catch (e) {
      debugPrint('❌ Erreur lors de la déconnexion: $e');
      
      // Ferme le dialog de chargement
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      _showErrorMessage('Erreur lors de la déconnexion');
    }
  }
  
  /// Vérification de l'authentification au démarrage
  Future<void> checkAuthenticationStatus() async {
    try {
      debugPrint('🔍 Vérification du statut d\'authentification...');
      
      if (_authService.isAuthenticated) {
        debugPrint('✅ Utilisateur déjà connecté');
        _navigateToDashboard();
      } else {
        debugPrint('❌ Utilisateur non connecté');
        _navigateToLogin();
      }
      
    } catch (e) {
      debugPrint('❌ Erreur lors de la vérification: $e');
      _navigateToLogin();
    }
  }
  
  // ==========================================================================
  // 🧭 NAVIGATION
  // ==========================================================================
  
  /// Appelé lors d'une connexion réussie
  void _onLoginSuccess() {
    debugPrint('🎉 Connexion réussie - Navigation vers dashboard');
    _navigateToDashboard();
  }
  
  /// Appelé lors d'une déconnexion complète
  void _onLogoutComplete() {
    debugPrint('👋 Déconnexion complète - Navigation vers login');
    _navigateToLogin();
  }
  
  /// Navigation vers le dashboard
  void _navigateToDashboard() {
    Get.offAllNamed(AppRoutes.dashboard);
  }
  
  /// Navigation vers la page de connexion
  void _navigateToLogin() {
    Get.offAllNamed(AppRoutes.login);
  }
  
  // ==========================================================================
  // 💬 MESSAGES UTILISATEUR
  // ==========================================================================
  
  /// Affiche un message de succès
  void _showSuccessMessage(String message) {
    Get.snackbar(
      'Succès',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.success.withOpacity(0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      margin: const EdgeInsets.all(AppSpacing.md),
      borderRadius: MobileDimensions.radiusMD,
      duration: const Duration(seconds: 3),
    );
  }
  
  /// Affiche un message d'erreur
  void _showErrorMessage(String message) {
    Get.snackbar(
      'Erreur',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.error.withOpacity(0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      margin: const EdgeInsets.all(AppSpacing.md),
      borderRadius: MobileDimensions.radiusMD,
      duration: const Duration(seconds: 5),
    );
  }
  
  /// Affiche un message d'information
  void _showInfoMessage(String message) {
    Get.snackbar(
      'Information',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.info.withOpacity(0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.info, color: Colors.white),
      margin: const EdgeInsets.all(AppSpacing.md),
      borderRadius: MobileDimensions.radiusMD,
      duration: const Duration(seconds: 4),
    );
  }
  
  /// Affiche un dialog de chargement
  void _showLoadingDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Get.isDarkMode ? AppColors.cardBgDark : AppColors.cardBgLight,
            borderRadius: AppRadius.radiusLG,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Déconnexion en cours...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Get.isDarkMode ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
  
  // ==========================================================================
  // 🔧 MÉTHODES UTILITAIRES
  // ==========================================================================
  
  /// Efface l'erreur de connexion
  void clearLoginError() {
    _loginError.value = null;
  }
  
  /// Vérifie si l'utilisateur a le bon rôle
  bool hasDeliveryRole() {
    return _authService.isDeliveryUser;
  }
  
  /// Vérifie si l'utilisateur a des privilèges admin
  bool hasAdminPrivileges() {
    return _authService.hasAdminPrivileges;
  }
  
  /// Obtient le rôle de l'utilisateur
  String get userRole => _authService.currentUser?.role ?? '';
  
  /// Obtient le nom d'affichage du rôle
  String get roleDisplayName => _authService.roleDisplayName;
  
  /// Obtient la couleur du rôle
  Color get roleColor => _authService.roleColor;
  
  /// Obtient l'icône du rôle
  IconData get roleIcon => _authService.roleIcon;
  
  /// Obtient les informations de l'utilisateur connecté
  String get currentUserName {
    final user = _authService.currentUser;
    if (user != null) {
      return user.fullName;
    }
    return 'Utilisateur';
  }
  
  /// Obtient l'email de l'utilisateur connecté
  String get currentUserEmail {
    final user = _authService.currentUser;
    return user?.email ?? '';
  }
  
  /// Vérifie si l'utilisateur est actif
  bool get isUserActive {
    final user = _authService.currentUser;
    return user?.isActive ?? false;
  }
  
  /// Vérifie si l'utilisateur est disponible
  bool get isUserAvailable {
    final user = _authService.currentUser;
    return user?.isAvailable ?? false;
  }
  
  // ==========================================================================
  // 🔄 GESTION DES ERREURS
  // ==========================================================================
  
  /// Gère les erreurs d'authentification
  void handleAuthError(String error) {
    debugPrint('🚨 Erreur d\'authentification: $error');
    
    // Déconnecte l'utilisateur en cas d'erreur critique
    if (error.contains('401') || error.contains('token')) {
      logout();
    } else {
      _showErrorMessage(error);
    }
  }
  
  /// Réinitialise l'état du contrôleur
  void reset() {
    _isLoading.value = false;
    _loginError.value = null;
  }
  
  @override
  void onClose() {
    reset();
    super.onClose();
  }
}