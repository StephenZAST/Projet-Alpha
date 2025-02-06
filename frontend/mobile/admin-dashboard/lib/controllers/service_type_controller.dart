import 'package:get/get.dart';
import '../services/service_type_service.dart';
import '../models/service_type.dart';
import '../constants.dart';

class ServiceTypeController extends GetxController {
  final serviceTypes = <ServiceType>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchServiceTypes();
  }

  Future<void> fetchServiceTypes() async {
    try {
      isLoading.value = true;
      final response = await ServiceTypeService.getAllServiceTypes();
      serviceTypes.value = response;
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des types de services';
      _showErrorSnackbar('Impossible de charger les types de services');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createServiceType({
    required String name,
    String? description,
  }) async {
    try {
      isLoading.value = true;
      await ServiceTypeService.createServiceType(
        name: name,
        description: description,
      );
      await fetchServiceTypes();
      Get.back();
      Get.snackbar(
        'Succès',
        'Type de service créé avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    } catch (e) {
      _showErrorSnackbar('Erreur lors de la création');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateServiceType({
    required String id,
    required String name,
    String? description,
  }) async {
    try {
      isLoading.value = true;
      await ServiceTypeService.updateServiceType(
        id: id,
        name: name,
        description: description,
      );
      await fetchServiceTypes();
      Get.back();
      Get.snackbar(
        'Succès',
        'Type de service mis à jour avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    } catch (e) {
      _showErrorSnackbar('Erreur lors de la mise à jour');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteServiceType(String id) async {
    try {
      isLoading.value = true;
      await ServiceTypeService.deleteServiceType(id);
      await fetchServiceTypes();
      Get.back();
      Get.snackbar(
        'Succès',
        'Type de service supprimé avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    } catch (e) {
      _showErrorSnackbar('Erreur lors de la suppression');
    } finally {
      isLoading.value = false;
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Erreur',
      message,
      backgroundColor: AppColors.error,
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Succès',
      message,
      backgroundColor: AppColors.success,
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
}
