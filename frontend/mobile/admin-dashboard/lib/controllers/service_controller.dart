import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/service.dart';
import '../services/service_service.dart';

class ServiceController extends GetxController {
  final services = <Service>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  Future<void> fetchServices() async {
    isLoading.value = true;
    try {
      // API call
      services.value = await ServiceService.getServices();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createService(Service service) async {
    try {
      final serviceData = {
        'id': service.id,
        'name': service.name,
        'description': service.description,
        'basePrice': service.basePrice,
      };

      await ServiceService.createService(serviceData);
      await fetchServices();
      Get.snackbar(
        'Success',
        'Service created successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
