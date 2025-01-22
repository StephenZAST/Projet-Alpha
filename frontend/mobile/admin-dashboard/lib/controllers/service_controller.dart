import 'package:get/get.dart';
import '../models/service.dart';
import '../services/service_service.dart';
import '../constants.dart';

class ServiceController extends GetxController {
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final services = <Service>[].obs;
  final selectedService = Rxn<Service>();

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  Future<void> fetchServices() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await ServiceService.getAllServices();
      services.value = result;
    } catch (e) {
      print('[ServiceController] Error fetching services: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des services';

      Get.snackbar(
        'Erreur',
        'Impossible de charger les services',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createService({
    required String name,
    required double price,
    String? description,
  }) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final dto = ServiceCreateDTO(
        name: name,
        price: price,
        description: description,
      );

      await ServiceService.createService(dto);
      await fetchServices();

      Get.snackbar(
        'Succès',
        'Service créé avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print('[ServiceController] Error creating service: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors de la création du service';

      Get.snackbar(
        'Erreur',
        'Impossible de créer le service',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateService({
    required String id,
    String? name,
    double? price,
    String? description,
  }) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final dto = ServiceUpdateDTO(
        name: name,
        price: price,
        description: description,
      );

      await ServiceService.updateService(id: id, dto: dto);
      await fetchServices();

      Get.snackbar(
        'Succès',
        'Service mis à jour avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print('[ServiceController] Error updating service: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors de la mise à jour du service';

      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour le service',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteService(String id) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      await ServiceService.deleteService(id);
      await fetchServices();

      Get.snackbar(
        'Succès',
        'Service supprimé avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print('[ServiceController] Error deleting service: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors de la suppression du service';

      Get.snackbar(
        'Erreur',
        'Impossible de supprimer le service',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchServices(String query) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      if (query.isEmpty) {
        await fetchServices();
        return;
      }

      final results = await ServiceService.searchServices(query);
      services.value = results;
    } catch (e) {
      print('[ServiceController] Error searching services: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors de la recherche';
    } finally {
      isLoading.value = false;
    }
  }

  Service? getServiceById(String id) {
    return services.firstWhereOrNull((s) => s.id == id);
  }
}
