import '../models/service.dart';
import './api_service.dart';

class ServiceService {
  static final _api = ApiService();
  static const _baseUrl = '/api/services';

  static Future<List<Service>> getAllServices() async {
    try {
      final response = await _api.get('$_baseUrl/all');
      if (response.data != null && response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((json) => Service.fromJson(json))
            .toList();
      }
      if (response.data?['error'] != null) {
        throw response.data['error'];
      }
      return [];
    } catch (e) {
      print('[ServiceService] Error getting all services: $e');
      throw 'Erreur lors du chargement des services';
    }
  }

  static Future<Service> createService(ServiceCreateDTO dto) async {
    try {
      final response = await _api.post(
        '$_baseUrl/create',
        data: dto.toJson(),
      );
      if (response.data != null && response.data['data'] != null) {
        return Service.fromJson(response.data['data']);
      }
      if (response.data?['error'] != null) {
        throw response.data['error'];
      }
      throw 'Erreur lors de la création du service';
    } catch (e) {
      print('[ServiceService] Error creating service: $e');
      throw 'Erreur lors de la création du service';
    }
  }

  static Future<Service> updateService({
    required String id,
    required ServiceUpdateDTO dto,
  }) async {
    try {
      final response = await _api.patch(
        '$_baseUrl/update/$id',
        data: dto.toJson(),
      );
      if (response.data != null && response.data['data'] != null) {
        return Service.fromJson(response.data['data']);
      }
      if (response.data?['error'] != null) {
        throw response.data['error'];
      }
      throw 'Erreur lors de la mise à jour du service';
    } catch (e) {
      print('[ServiceService] Error updating service: $e');
      if (e.toString().contains('404')) {
        throw 'Service non trouvé';
      }
      throw 'Erreur lors de la mise à jour du service';
    }
  }

  static Future<void> deleteService(String id) async {
    try {
      final response = await _api.delete('$_baseUrl/delete/$id');
      if (response.data?['error'] != null) {
        throw response.data['error'];
      }
    } catch (e) {
      print('[ServiceService] Error deleting service: $e');
      if (e.toString().contains('404')) {
        throw 'Service non trouvé';
      }
      throw 'Erreur lors de la suppression du service';
    }
  }

  static Future<Service> getServiceById(String id) async {
    try {
      // Comme il n'y a pas d'endpoint spécifique pour obtenir un service par ID,
      // nous allons récupérer tous les services et filtrer
      final services = await getAllServices();
      final service = services.firstWhere(
        (service) => service.id == id,
        orElse: () => throw 'Service non trouvé',
      );
      return service;
    } catch (e) {
      print('[ServiceService] Error getting service by id: $e');
      throw 'Erreur lors du chargement du service';
    }
  }

  static Future<List<Service>> searchServices(String query) async {
    try {
      // Comme il n'y a pas d'endpoint de recherche,
      // nous allons récupérer tous les services et filtrer côté client
      final services = await getAllServices();
      if (query.isEmpty) return services;

      final normalizedQuery = query.toLowerCase().trim();
      return services
          .where((service) =>
              service.name.toLowerCase().contains(normalizedQuery) ||
              (service.description?.toLowerCase() ?? '')
                  .contains(normalizedQuery))
          .toList();
    } catch (e) {
      print('[ServiceService] Error searching services: $e');
      throw 'Erreur lors de la recherche de services';
    }
  }
}
