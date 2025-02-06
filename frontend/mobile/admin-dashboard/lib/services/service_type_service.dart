import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../models/service_type.dart';

class ServiceTypeService {
  static const String _baseUrl = '/api/service-types';
  static final ApiService _api = ApiService();

  static Future<List<ServiceType>> getAllServiceTypes() async {
    try {
      final response = await _api.get(_baseUrl);
      return _parseServiceTypeList(response.data);
    } catch (e) {
      print('[ServiceTypeService] Error getting service types: $e');
      rethrow;
    }
  }

  static Future<ServiceType> createServiceType({
    required String name,
    String? description,
  }) async {
    try {
      final response = await _api.post(_baseUrl, data: {
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
      await _api.patch('$_baseUrl/$id', data: {
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
      await _api.delete('$_baseUrl/$id');
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
