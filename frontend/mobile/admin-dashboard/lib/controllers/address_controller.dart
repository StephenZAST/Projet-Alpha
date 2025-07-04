import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants.dart';
import '../models/address.dart';
import '../services/address_service.dart';

class AddressController extends GetxController {
  final addresses = <Address>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final loadedAddresses = await AddressService.getAddresses();
      addresses.assignAll(loadedAddresses);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des adresses';
      print('[AddressController] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Address?> getAddressById(String id) async {
    try {
      return await AddressService.getAddressById(id);
    } catch (e) {
      print('[AddressController] Error getting address $id: $e');
      return null;
    }
  }

  Future<Address?> createAddress(Map<String, dynamic> addressData) async {
    try {
      final newAddress = await AddressService.createAddress(addressData);
      addresses.add(newAddress);
      return newAddress;
    } catch (e) {
      print('[AddressController] Error creating address: $e');
      return null;
    }
  }

  void _showSuccessSnackbar(String message) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.success.withOpacity(0.85),
      borderRadius: 16,
      margin: AppSpacing.marginMD,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
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
          Icon(Icons.error_outline, color: AppColors.error, size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.error.withOpacity(0.90),
      borderRadius: 16,
      margin: AppSpacing.marginMD,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 3),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
      isDismissible: true,
      overlayBlur: 2.5,
    );
  }
}
