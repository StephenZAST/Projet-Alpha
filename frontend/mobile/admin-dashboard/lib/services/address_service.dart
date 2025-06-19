import 'package:admin/models/address.dart';
import 'api_service.dart';

class AddressService {
  static final _api = ApiService();
  static const String _basePath = '/api/addresses';

  static Future<List<Address>> getAddresses() async {
    try {
      final response = await _api.get('$_basePath/all');
      print('[AddressService] Raw response: [33m${response.data}\u001b[0m');

      if (response.data == null || response.data['data'] == null) {
        throw 'Failed to fetch addresses';
      }

      final List<Address> addresses = [];
      for (var item in response.data['data'] as List) {
        try {
          addresses.add(Address.fromJson(item));
        } catch (e) {
          print('[AddressService] Error parsing address: $e');
          print('[AddressService] Problematic data: $item');
        }
      }

      return addresses;
    } catch (e) {
      print('[AddressService] Error getting addresses: $e');
      rethrow;
    }
  }

  static Future<Address> getAddressById(String id) async {
    try {
      final response = await _api.get('$_basePath/$id');

      if (response.data == null || response.data['data'] == null) {
        throw 'Address not found';
      }

      return Address.fromJson(response.data['data']);
    } catch (e) {
      print('[AddressService] Error getting address $id: $e');
      rethrow;
    }
  }

  static Future<Address> createAddress(Map<String, dynamic> addressData) async {
    try {
      final response = await _api.post('$_basePath/create', data: addressData);

      if (response.data == null || response.data['data'] == null) {
        throw response.data['message'] ?? 'Failed to create address';
      }

      return Address.fromJson(response.data['data']);
    } catch (e) {
      print('[AddressService] Error creating address: $e');
      rethrow;
    }
  }

  static Future<Address> updateAddress(
      String id, Map<String, dynamic> addressData) async {
    try {
      final response = await _api.put('$_basePath/$id', data: addressData);

      if (!response.data['success']) {
        throw response.data['message'] ?? 'Failed to update address';
      }

      return Address.fromJson(response.data['data']);
    } catch (e) {
      print('[AddressService] Error updating address: $e');
      rethrow;
    }
  }

  static Future<void> deleteAddress(String id) async {
    try {
      final response = await _api.delete('$_basePath/$id');

      if (!response.data['success']) {
        throw response.data['message'] ?? 'Failed to delete address';
      }
    } catch (e) {
      print('[AddressService] Error deleting address: $e');
      rethrow;
    }
  }
}
