import '../services/api_service.dart';
import '../models/service_type.dart';

class ServiceTypeService {
  static const String _baseUrl = '/api/service-types';
  static final ApiService _apiService = ApiService();

  static Future<List<ServiceType>> getAllServiceTypes(
      {bool includeInactive = false}) async {
    try {
      final response = await _apiService.get(_baseUrl,
          queryParameters: includeInactive ? {'includeInactive': true} : null);
      if (response.data != null && response.data['data'] != null) {
        final List<ServiceType> types = (response.data['data'] as List)
            .map((item) => ServiceType.fromJson(item))
            .toList();
        return types;
      }
      return [];
    } catch (e) {
      print('Error fetching service types: $e');
      rethrow;
    }
  }

  static Future<ServiceType> createServiceType(
      Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post(_baseUrl, data: data);
      if (response.data != null && response.data['data'] != null) {
        return ServiceType.fromJson(response.data['data']);
      }
      throw 'Erreur lors de la création du type de service';
    } catch (e) {
      print('Error creating service type: $e');
      rethrow;
    }
  }

  static Future<ServiceType> updateServiceType(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('$_baseUrl/$id', data: data);
      if (response.data != null && response.data['data'] != null) {
        return ServiceType.fromJson(response.data['data']);
      }
      throw 'Erreur lors de la modification du type de service';
    } catch (e) {
      print('Error updating service type: $e');
      rethrow;
    }
  }

  static Future<void> deleteServiceType(String id) async {
    try {
      final response = await _apiService.delete('$_baseUrl/$id');
      if (response.data != null && response.data['success'] == true) {
        return;
      }
      throw 'Erreur lors de la suppression du type de service';
    } catch (e) {
      print('Error deleting service type: $e');
      rethrow;
    }
  }
}
