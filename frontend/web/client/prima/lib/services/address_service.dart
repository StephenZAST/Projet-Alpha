import 'package:dio/dio.dart';
import '../models/address.dart';

class AddressService {
  final Dio dio;

  AddressService(this.dio);

  Future<List<Address>> getAddresses() async {
    final response = await dio.get('/api/addresses');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => Address.fromJson(json)).toList();
    }
    throw Exception('Failed to load addresses');
  }

  Future<Address> createAddress({
    required String name,
    required String street,
    required String city,
    required String postalCode,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    final response = await dio.post(
      '/api/addresses',
      data: {
        'name': name,
        'street': street,
        'city': city,
        'postal_code': postalCode,
        'gps_latitude': latitude,
        'gps_longitude': longitude,
        'is_default': isDefault,
      },
    );

    if (response.statusCode == 201) {
      return Address.fromJson(response.data['data']);
    }
    throw Exception('Failed to create address: ${response.data['error']}');
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
    final response = await dio.put(
      '/api/addresses/$id',
      data: {
        'name': name,
        'street': street,
        'city': city,
        'postal_code': postalCode,
        'gps_latitude': latitude,
        'gps_longitude': longitude,
        'is_default': isDefault,
      },
    );

    if (response.statusCode == 200) {
      return Address.fromJson(response.data['data']);
    }
    throw Exception('Failed to update address: ${response.data['error']}');
  }

  Future<void> deleteAddress(String id) async {
    final response = await dio.delete('/api/addresses/$id');

    if (response.statusCode != 200) {
      throw Exception('Failed to delete address: ${response.data['error']}');
    }
  }
}
