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

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Erreur',
      message,
      backgroundColor: AppColors.error,
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
}
