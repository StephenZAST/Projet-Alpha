import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/delivery_service.dart';
import '../constants.dart';

/// 👤 Contrôleur Profil - Alpha Delivery App
///
/// Gère la logique métier du profil utilisateur pour les livreurs.
/// Permet la consultation et mise à jour des informations personnelles,
/// statistiques de performance, et paramètres du profil.
class ProfileController extends GetxController {
  // ==========================================================================
  // 👤 PROPRIÉTÉS RÉACTIVES
  // ==========================================================================

  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final user = Rxn<DeliveryUser>();
  final stats = Rxn<DeliveryStats>();
  final isEditing = false.obs;
  final isAvailable = true.obs;

  // Champs d'édition
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  // ==========================================================================
  // 🚀 INITIALISATION
  // ==========================================================================

  @override
  void onInit() {
    super.onInit();
    debugPrint('👤 Initialisation ProfileController...');

    // Charger le profil au démarrage
    loadProfile();
  }

  @override
  void onClose() {
    // Nettoyer les contrôleurs
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();

    debugPrint('🧹 ProfileController nettoyé');
    super.onClose();
  }

  // ==========================================================================
  // 📊 CHARGEMENT DU PROFIL
  // ==========================================================================

  /// Charge le profil de l'utilisateur connecté
  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      debugPrint('👤 Chargement du profil...');

      final authService = Get.find<AuthService>();
      final currentUser = authService.currentUser;

      if (currentUser != null) {
        user.value = currentUser;
        _populateControllers();
        debugPrint(
            '✅ Profil chargé: ${currentUser.firstName} ${currentUser.lastName}');
      } else {
        throw Exception('Utilisateur non connecté');
      }
    } catch (e) {
      debugPrint('❌ Erreur chargement profil: $e');
      hasError.value = true;
      errorMessage.value = 'Impossible de charger le profil';

      Get.snackbar(
        'Erreur',
        'Impossible de charger le profil',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Actualise le profil (pull-to-refresh)
  Future<void> refreshProfile() async {
    await loadProfile();
  }

  // ==========================================================================
  // ✏️ ÉDITION DU PROFIL
  // ==========================================================================

  /// Active le mode édition
  void startEditing() {
    _populateControllers();
    isEditing.value = true;
    debugPrint('✏️ Mode édition activé');
  }

  /// Annule l'édition et restaure les valeurs
  void cancelEditing() {
    _populateControllers();
    isEditing.value = false;
    debugPrint('❌ Édition annulée');
  }

  /// Remplit les contrôleurs avec les données actuelles
  void _populateControllers() {
    if (user.value != null) {
      firstNameController.text = user.value!.firstName;
      lastNameController.text = user.value!.lastName;
      phoneController.text = user.value!.phone ?? '';
      emailController.text = user.value!.email;
    }
  }

  /// Sauvegarde les modifications du profil
  Future<bool> saveProfile() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      debugPrint('💾 Sauvegarde du profil...');

      // Validation des champs
      if (!_validateFields()) {
        return false;
      }

      final profileData = {
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'phone': phoneController.text.trim().isEmpty
            ? null
            : phoneController.text.trim(),
      };

      final deliveryService = Get.find<DeliveryService>();
      final updatedUser = await deliveryService.updateProfile(profileData);

      // Mettre à jour l'utilisateur dans AuthService
      final authService = Get.find<AuthService>();
      authService.setCurrentUser(updatedUser);

      // Mettre à jour localement
      user.value = updatedUser;

      isEditing.value = false;

      Get.snackbar(
        'Succès',
        'Profil mis à jour avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );

      debugPrint('✅ Profil sauvegardé');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur sauvegarde profil: $e');
      hasError.value = true;
      errorMessage.value = 'Impossible de sauvegarder le profil';

      Get.snackbar(
        'Erreur',
        'Impossible de sauvegarder le profil',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Valide les champs du formulaire
  bool _validateFields() {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final phone = phoneController.text.trim();

    if (firstName.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Le prénom est obligatoire',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return false;
    }

    if (lastName.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Le nom est obligatoire',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return false;
    }

    if (phone.isNotEmpty && !_isValidPhoneNumber(phone)) {
      Get.snackbar(
        'Erreur',
        'Numéro de téléphone invalide',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return false;
    }

    return true;
  }

  /// Valide un numéro de téléphone (format simple)
  bool _isValidPhoneNumber(String phone) {
    // Format Sénégal: +221 XX XXX XX XX ou 77 XXX XX XX
    final phoneRegex = RegExp(r'^(\+221|221)?[76-8]\d{7}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'\s+'), ''));
  }

  // ==========================================================================
  // 📊 STATISTIQUES ET PERFORMANCE
  // ==========================================================================

  /// Retourne les statistiques formatées pour l'affichage
  Map<String, String> getFormattedStats() {
    final stats = user.value?.stats;
    if (stats == null) {
      return {
        'totalOrders': '0',
        'completedOrders': '0',
        'successRate': '0%',
        'averageRating': '0.0',
      };
    }

    final total = stats.totalDeliveries;
    final completed = stats.completedDeliveries;
    final successRate = total > 0 ? ((completed / total) * 100).round() : 0;
    final rating = stats.averageRating.toStringAsFixed(1);

    return {
      'totalOrders': total.toString(),
      'completedOrders': completed.toString(),
      'successRate': '$successRate%',
      'averageRating': rating,
    };
  }

  double getSuccessRate() {
    final stats = user.value?.stats;
    if (stats == null || stats.totalDeliveries == 0) return 0.0;

    return (stats.completedDeliveries / stats.totalDeliveries) * 100;
  }

  /// Retourne le niveau de performance basé sur les stats
  String getPerformanceLevel() {
    final rate = getSuccessRate();

    if (rate >= 95) return 'Excellent';
    if (rate >= 85) return 'Très bien';
    if (rate >= 75) return 'Bien';
    if (rate >= 60) return 'Correct';
    return 'À améliorer';
  }

  /// Retourne la couleur associée au niveau de performance
  Color getPerformanceColor() {
    final rate = getSuccessRate();

    if (rate >= 95) return AppColors.success;
    if (rate >= 85) return Colors.blue;
    if (rate >= 75) return Colors.orange;
    if (rate >= 60) return Colors.amber;
    return AppColors.error;
  }

  // ==========================================================================
  // 🔐 GESTION DE COMPTE
  // ==========================================================================

  /// Change le mot de passe
  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      debugPrint('🔐 Changement de mot de passe...');

      final deliveryService = Get.find<DeliveryService>();
      final success =
          await deliveryService.changePassword(currentPassword, newPassword);

      if (success) {
        Get.snackbar(
          'Succès',
          'Mot de passe changé avec succès',
          backgroundColor: AppColors.success,
          colorText: AppColors.textLight,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        debugPrint('✅ Mot de passe changé');
        return true;
      } else {
        throw Exception('Échec du changement de mot de passe');
      }
    } catch (e) {
      debugPrint('❌ Erreur changement mot de passe: $e');
      hasError.value = true;
      errorMessage.value = 'Impossible de changer le mot de passe';

      Get.snackbar(
        'Erreur',
        'Impossible de changer le mot de passe',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Déconnecte l'utilisateur
  Future<void> logout() async {
    try {
      debugPrint('🚪 Déconnexion...');

      final authService = Get.find<AuthService>();
      await authService.logout();

      debugPrint('✅ Déconnexion réussie');
    } catch (e) {
      debugPrint('❌ Erreur déconnexion: $e');
    }
  }

  // ==========================================================================
  // 📱 UTILITAIRES
  // ==========================================================================

  /// Retourne le nom complet formaté
  String getFullName() {
    if (user.value == null) return '';
    return '${user.value!.firstName} ${user.value!.lastName}';
  }

  /// Retourne les initiales pour l'avatar
  String getInitials() {
    if (user.value == null) return '';
    return '${user.value!.firstName[0]}${user.value!.lastName[0]}'
        .toUpperCase();
  }

  /// Vérifie si le profil est complet
  bool isProfileComplete() {
    if (user.value == null) return false;

    return user.value!.firstName.isNotEmpty &&
        user.value!.lastName.isNotEmpty &&
        user.value!.phone != null &&
        user.value!.phone!.isNotEmpty;
  }

  /// Bascule le statut de disponibilité du livreur
  Future<void> toggleAvailability() async {
    try {
      debugPrint('🟢 Basculement disponibilité...');

      final newStatus = !isAvailable.value;

      final deliveryService = Get.find<DeliveryService>();
      await deliveryService.updateAvailability(newStatus);

      isAvailable.value = newStatus;

      Get.snackbar(
        'Statut mis à jour',
        newStatus
            ? 'Vous êtes maintenant disponible pour les livraisons'
            : 'Vous ne recevrez plus de nouvelles commandes',
        backgroundColor: newStatus ? AppColors.success : AppColors.warning,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );

      debugPrint('✅ Disponibilité mise à jour: $newStatus');
    } catch (e) {
      debugPrint('❌ Erreur basculement disponibilité: $e');

      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour votre disponibilité',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    }
  }
}
