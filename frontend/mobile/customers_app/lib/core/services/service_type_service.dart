import 'api_service.dart';
import '../models/service_type.dart';

/// 🏷️ Service de Gestion des Types de Service - Alpha Client App
///
/// Gère les interactions avec l'API backend pour les types de service
/// Routes : /api/service-types/*
class ServiceTypeService {
  final ApiService _api = ApiService();

  /// 📋 Récupérer tous les types de service actifs
  /// GET /api/service-types?isActive=true
  Future<List<ServiceType>> getAllServiceTypes() async {
    try {
      final response = await _api.get(
        '/service-types',
        queryParameters: {'isActive': 'true'},
      );

      if (response['success'] == true || response['data'] != null) {
        final data = response['data'] ?? [];
        return (data as List)
            .map((json) => ServiceType.fromJson(json))
            .toList();
      }

      throw Exception(response['error'] ?? 'Erreur lors de la récupération des types de service');
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  /// 🔍 Récupérer un type de service par son ID
  /// GET /api/service-types/:id
  Future<ServiceType> getServiceTypeById(String id) async {
    try {
      final response = await _api.get('/service-types/$id');

      if (response['success'] == true && response['data'] != null) {
        return ServiceType.fromJson(response['data']);
      }

      throw Exception(response['error'] ?? 'Type de service non trouvé');
    } catch (e) {
      throw Exception('Erreur de récupération: ${e.toString()}');
    }
  }
}
