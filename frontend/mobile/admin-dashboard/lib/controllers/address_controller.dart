import 'package:get/get.dart';
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
}
