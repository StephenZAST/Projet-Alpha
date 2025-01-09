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
      print('Creating address with data: ${{
        'name': name,
        'street': street,
        'city': city,
        'postal_code': postalCode,
        'gps_latitude': latitude,
        'gps_longitude': longitude,
        'is_default': isDefault,
      }}');

      final response = await _dio.post('/api/addresses/create', data: {
        'name': name,
        'street': street,
        'city': city,
        'postal_code': postalCode,
        'gps_latitude': latitude,
        'gps_longitude': longitude,
        'is_default': isDefault,
      });

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 401) {
        throw Exception('Non autorisé. Veuillez vous reconnecter.');
      }

      return Address.fromJson(response.data['data']);
    } catch (e) {
      print('Error creating address: $e');
      rethrow;
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
      print('Updating address with ID: $id');
      final response = await _dio.patch('/api/addresses/update/$id', data: {
        'name': name,
        'street': street,
        'city': city,
        'postal_code': postalCode,
        'gps_latitude': latitude,
        'gps_longitude': longitude,
        'is_default': isDefault,
      });

      return Address.fromJson(response.data['data']);
    } on DioException catch (e) {
      print('Error updating address: ${e.response?.data}');
      throw Exception('Failed to update address: ${e.message}');
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      print('Deleting address with ID: $id');
      final response = await _dio.delete(
        '/api/addresses/delete/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_dio.options.headers['Authorization']}',
          },
        ),
      );

      if (response.statusCode == 403) {
        throw Exception(
            'Vous n\'avez pas la permission de supprimer cette adresse');
      }

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la suppression de l\'adresse');
      }
    } on DioException catch (e) {
      print('Error deleting address: ${e.response?.data}');
      throw Exception(
          e.response?.data['error'] ?? 'Erreur lors de la suppression');
    }
  }
}
