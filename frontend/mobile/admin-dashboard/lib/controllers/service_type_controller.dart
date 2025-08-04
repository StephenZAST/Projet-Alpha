import 'package:get/get.dart';
import '../models/service_type.dart';
import '../services/service_type_service.dart';

class ServiceTypeController extends GetxController {
  var serviceTypes = <ServiceType>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchServiceTypes();
  }

  Future<void> fetchServiceTypes() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final types = await ServiceTypeService.getAllServiceTypes();
      // Filtrer pour n'afficher que les services types actifs
      serviceTypes.assignAll(types.where((t) => t.isActive == true).toList());
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des types de service';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addServiceType(Map<String, dynamic> data) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final newType = await ServiceTypeService.createServiceType(data);
      serviceTypes.add(newType);
      return true;
    } catch (e) {
      errorMessage.value = 'Erreur lors de la création du type de service';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateServiceType(String id, Map<String, dynamic> data) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final updatedType = await ServiceTypeService.updateServiceType(id, data);
      final idx = serviceTypes.indexWhere((t) => t.id == id);
      if (idx != -1) serviceTypes[idx] = updatedType;
      return true;
    } catch (e) {
      errorMessage.value = 'Erreur lors de la modification du type de service';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteServiceType(String id) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await ServiceTypeService.deleteServiceType(id);
      serviceTypes.removeWhere((t) => t.id == id);
      return true;
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('violates foreign key constraint') ||
          errorStr.contains('constraint') ||
          errorStr.contains('liée')) {
        errorMessage.value =
            "Impossible de supprimer ce type de service car il est lié à des articles, des couples ou des commandes. Veuillez d'abord supprimer les liens ou couples associés avant de réessayer.";
      } else {
        errorMessage.value = 'Erreur lors de la suppression du type de service';
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
