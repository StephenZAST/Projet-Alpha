import 'package:dio/dio.dart';
import 'package:prima/models/address.dart';

class AddressService {
  final Dio _dio;

  AddressService(this._dio);

  Future<Address> createAddress({
    required String name,
    required String street,
    required String city,
    required String postalCode,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    try {
      final response = await _dio.post('/addresses/create', data: {
        'name': name,
        'street': street,
        'city': city,
        'postalCode': postalCode,
        'gpsLatitude': latitude,
        'gpsLongitude': longitude,
        'isDefault': isDefault,
      });

      return Address.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception('Failed to create address: ${e.response?.data['error']}');
    }
  }

  Future<List<Address>> getAddresses() async {
    try {
      final response = await _dio.get('/addresses/all');
      return (response.data['data'] as List)
          .map((json) => Address.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to get addresses: ${e.response?.data['error']}');
    }
  }

  Future<Address> updateAddress({
    required String id,
    required String name,
    required String street,
    required String city,
    required String postalCode,
    double? latitude,
    double? longitude,
    required bool isDefault,
  }) async {
    try {
      final response = await _dio.patch('/addresses/update/$id', data: {
        'name': name,
        'street': street,
        'city': city,
        'postalCode': postalCode,
        'gpsLatitude': latitude,
        'gpsLongitude': longitude,
        'isDefault': isDefault,
      });

      return Address.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception('Failed to update address: ${e.response?.data['error']}');
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await _dio.delete('/addresses/delete/$id');
    } on DioException catch (e) {
      throw Exception('Failed to delete address: ${e.response?.data['error']}');
    }
  }
}
