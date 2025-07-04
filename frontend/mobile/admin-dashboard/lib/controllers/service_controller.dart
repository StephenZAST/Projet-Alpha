import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/service.dart';
import '../services/service_service.dart';
import '../constants.dart';

class ServiceController extends GetxController {
  final services = <Service>[].obs;
  final serviceTypes = <Service>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final selectedServiceType = Rxn<Service>();

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  Future<void> fetchServices() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await ServiceService.getAllServices();
      services.value = result;
    } catch (e) {
      print('[ServiceController] Error fetching services: $e');
      errorMessage.value = 'Erreur lors du chargement des services';
      _showErrorSnackbar('Impossible de charger les services');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createService({
    required String name,
    required double price,
    String? description,
    String? typeId,
  }) async {
    try {
      isLoading.value = true;

      // Créer le DTO correct
      await ServiceService.createService(
        name: name, // Passer les paramètres requis individuellement
        price: price,
        description: description,
      );

      await fetchServices();
      Get.back();
      _showSuccessSnackbar('Service créé avec succès');
    } catch (e) {
      print('[ServiceController] Error creating service: $e');
      _showErrorSnackbar('Impossible de créer le service');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateService({
    required String id,
    String? name,
    double? price,
    String? description,
    String? typeId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Utiliser les paramètres nommés corrects
      await ServiceService.updateService(
        id: id,
        name: name,
        price: price,
        description: description,
      );

      await fetchServices();
      _showSuccessSnackbar('Service mis à jour avec succès');
    } catch (e) {
      print('[ServiceController] Error updating service: $e');
      errorMessage.value = 'Erreur lors de la mise à jour du service';

      _showErrorSnackbar('Impossible de mettre à jour le service');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteService(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await ServiceService.deleteService(id);
      await fetchServices();

      _showSuccessSnackbar('Service supprimé avec succès');
    } catch (e) {
      print('[ServiceController] Error deleting service: $e');
      errorMessage.value = 'Erreur lors de la suppression du service';

      _showErrorSnackbar('Impossible de supprimer le service');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchServices(String query) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (query.isEmpty) {
        await fetchServices();
        return;
      }

      final searchResults = services
          .where((service) =>
              service.name.toLowerCase().contains(query.toLowerCase()) ||
              (service.description?.toLowerCase() ?? '')
                  .contains(query.toLowerCase()))
          .toList();

      services.value = searchResults;
    } catch (e) {
      print('[ServiceController] Error searching services: $e');
      errorMessage.value = 'Erreur lors de la recherche';
    } finally {
      isLoading.value = false;
    }
  }

  Service? getServiceById(String id) {
    return services.firstWhereOrNull((s) => s.id == id);
  }

  void _showSuccessSnackbar(String message) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.success.withOpacity(0.85),
      borderRadius: 16,
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
      boxShadows: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
      isDismissible: true,
      overlayBlur: 2.5,
    );
  }

  void _showErrorSnackbar(String message) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.white, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.error.withOpacity(0.90),
      borderRadius: 16,
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 3),
      boxShadows: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
      isDismissible: true,
      overlayBlur: 2.5,
    );
  }
}
