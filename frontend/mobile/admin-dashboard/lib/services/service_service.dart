import '../services/api_service.dart';
import '../models/service.dart';

class ServiceService {
  static const String _baseUrl = '/api/services';
  static final ApiService _apiService = ApiService();

  static Future<List<Service>> getAllServices() async {
    try {
      // Correction: utiliser le bon endpoint backend
      final response = await _apiService.get('$_baseUrl/all');
      if (response.data != null && response.data['data'] != null) {
        final List<Service> services = (response.data['data'] as List)
            .map((item) => Service.fromJson(item))
            .toList();
        return services;
      }
      return [];
    } catch (e) {
      print('Error fetching services: $e');
      rethrow;
    }
  }

  static Future<Service> createService({
    required String name,
    required double price,
    String? description,
    String? typeId,
  }) async {
    try {
      // Correction: utiliser le bon endpoint backend
      final response = await _apiService.post('$_baseUrl/create', data: {
        'name': name,
        'price': price,
        if (description != null) 'description': description,
        if (typeId != null) 'service_type_id': typeId,
      });
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw 'Erreur lors de la création du service: ${response.statusCode}';
      }
      return Service.fromJson(response.data['data']);
    } catch (e) {
      print('[ServiceService] Error creating service: $e');
      rethrow;
    }
  }

  static Future<Service> updateService({
    required String id,
    String? name,
    double? price,
    String? description,
    String? typeId,
  }) async {
    try {
      // Correction: utiliser le bon endpoint backend
      final response = await _apiService.patch('$_baseUrl/update/$id', data: {
        if (name != null) 'name': name,
        if (price != null) 'price': price,
        if (description != null) 'description': description,
        if (typeId != null) 'service_type_id': typeId,
      });
      return Service.fromJson(response.data['data']);
    } catch (e) {
      print('[ServiceService] Error updating service: $e');
      rethrow;
    }
  }

  static Future<void> deleteService(String id) async {
    try {
      // Correction: utiliser le bon endpoint backend
      await _apiService.delete('$_baseUrl/delete/$id');
    } catch (e) {
      print('[ServiceService] Error deleting service: $e');
      rethrow;
    }
  }
}
