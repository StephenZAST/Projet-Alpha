import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/admin_profile.dart';
import '../services/admin_profile_service.dart';
import '../constants.dart';

class AdminProfileController extends GetxController {
  final profile = Rxn<AdminProfile>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final isEditing = false.obs;

  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final adminProfile = await AdminProfileService.getProfile();
      profile.value = adminProfile;
    } catch (e) {
      errorMessage.value = 'Failed to load profile: $e';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void startEditing() {
    isEditing.value = true;
    fullNameController.text = profile.value?.fullName ?? '';
    phoneController.text = profile.value?.phoneNumber ?? '';
  }

  void cancelEditing() {
    isEditing.value = false;
    fullNameController.clear();
    phoneController.clear();
  }

  Future<void> changePassword() async {
    try {
      if (newPasswordController.text != confirmPasswordController.text) {
        throw 'Les mots de passe ne correspondent pas';
      }

      isLoading.value = true;
      errorMessage.value = '';

      await AdminProfileService.updatePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );

      // Réinitialiser les champs
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      Get.snackbar(
        'Succès',
        'Mot de passe modifié avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePreferences(Map<String, dynamic> newPreferences) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final currentPreferences = profile.value?.preferences ?? {};
      final updatedPreferences = {
        ...currentPreferences,
        ...newPreferences,
      };

      await AdminProfileService.updateProfile({
        'preferences': updatedPreferences,
      });

      await loadProfile();

      Get.snackbar(
        'Succès',
        'Préférences mises à jour',
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    } catch (e) {
      errorMessage.value = 'Erreur lors de la mise à jour des préférences';
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
