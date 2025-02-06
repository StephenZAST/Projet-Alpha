import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../models/service_type.dart';

class ServiceTypeService {
  // Correction du chemin de l'API pour correspondre au backend
  static const String _baseUrl = '/api/service-types'; // Route simplifiée
  static final ApiService _apiService = ApiService();

  static Future<List<ServiceType>> getAllServiceTypes() async {
    try {
      print('[ServiceTypeService] Attempting to fetch from: $_baseUrl');
      final response = await _apiService.get(_baseUrl);
      print('[ServiceTypeService] Raw response: ${response.data}');

      if (response.data != null && response.data['data'] != null) {
        final List<ServiceType> types = (response.data['data'] as List)
            .map((item) => ServiceType.fromJson(item))
            .toList();
        print(
            '[ServiceTypeService] Parsed ${types.length} service types'); // Debug log
        return types;
      }
      return [];
    } catch (e) {
      print('[ServiceTypeService] Error with specific URL: $_baseUrl');
      print('[ServiceTypeService] Error details: $e');
      rethrow;
    }
  }

  static Future<ServiceType> createServiceType({
    required String name,
    String? description,
  }) async {
    try {
      final response = await _apiService.post(_baseUrl, data: {
        // Correction ici
        'name': name,
        'description': description,
      });
      return ServiceType.fromJson(response.data['data']);
    } catch (e) {
      print('[ServiceTypeService] Error creating service type: $e');
      rethrow;
    }
  }

  static Future<void> updateServiceType({
    required String id,
    String? name,
    String? description,
  }) async {
    try {
      await _apiService.patch('$_baseUrl/$id', data: {
        // Correction ici
        if (name != null) 'name': name,
        if (description != null) 'description': description,
      });
    } catch (e) {
      print('[ServiceTypeService] Error updating service type: $e');
      rethrow;
    }
  }

  static Future<void> deleteServiceType(String id) async {
    try {
      await _apiService.delete('$_baseUrl/$id'); // Correction ici
    } catch (e) {
      print('[ServiceTypeService] Error deleting service type: $e');
      rethrow;
    }
  }

  static List<ServiceType> _parseServiceTypeList(
      Map<String, dynamic> responseData) {
    if (responseData['data'] == null) return [];
    return (responseData['data'] as List)
        .map((item) => ServiceType.fromJson(item))
        .toList();
  }
}
