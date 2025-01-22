import 'package:get/get.dart';
import '../models/admin.dart';
import '../services/admin_service.dart';
import '../constants.dart';

class AdminController extends GetxController {
  final isLoading = false.obs;
  final admin = Rxn<Admin>();
  final dashboardData = Rxn<Map<String, dynamic>>();
  final hasError = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final response = await AdminService.updateProfile(profileData);
      admin.value = Admin.fromJson(response);

      Get.snackbar(
        'Succès',
        'Profil mis à jour avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print('[AdminController] Error updating profile: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors de la mise à jour du profil';

      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour le profil',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final data = await AdminService.getDashboardData();
      dashboardData.value = data;
    } catch (e) {
      print('[AdminController] Error fetching dashboard data: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des données';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportData(String type) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      await AdminService.exportData(type);

      Get.snackbar(
        'Succès',
        'Export des données réussi',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print('[AdminController] Error exporting data: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors de l\'export des données';

      Get.snackbar(
        'Erreur',
        'Impossible d\'exporter les données',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      await AdminService.updateSystemSettings(settings);

      Get.snackbar(
        'Succès',
        'Paramètres mis à jour avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print('[AdminController] Error updating settings: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors de la mise à jour des paramètres';

      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour les paramètres',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getSystemActivity() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      await AdminService.getSystemActivity();
    } catch (e) {
      print('[AdminController] Error getting system activity: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement de l\'activité';
    } finally {
      isLoading.value = false;
    }
  }
}
