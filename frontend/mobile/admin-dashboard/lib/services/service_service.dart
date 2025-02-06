import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../models/service.dart';

class ServiceService {
  static const String _baseUrl =
      '/api/services'; // Correction du chemin de l'API
  static final ApiService _api = ApiService();

  static Future<List<Service>> getAllServices() async {
    try {
      final response = await _api.get(_baseUrl);

      if (response.statusCode != 200) {
        throw 'Erreur lors de la récupération des services: ${response.statusCode}';
      }

      if (response.data != null && response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((item) => Service.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('[ServiceService] Error getting services: $e');
      rethrow;
    }
  }

  static Future<Service> createService({
    required String name,
    required double price,
    String? description,
  }) async {
    try {
      final response = await _api.post(_baseUrl, data: {
        'name': name,
        'price': price,
        if (description != null) 'description': description,
      });

      if (response.statusCode != 201) {
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
  }) async {
    try {
      final response = await _api.patch('$_baseUrl/$id', data: {
        if (name != null) 'name': name,
        if (price != null) 'price': price,
        if (description != null) 'description': description,
      });

      return Service.fromJson(response.data['data']);
    } catch (e) {
      print('[ServiceService] Error updating service: $e');
      rethrow;
    }
  }

  static Future<void> deleteService(String id) async {
    try {
      await _api.delete('$_baseUrl/$id');
    } catch (e) {
      print('[ServiceService] Error deleting service: $e');
      rethrow;
    }
  }
}
