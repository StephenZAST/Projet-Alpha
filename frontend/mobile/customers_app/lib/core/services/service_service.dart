import '../models/service.dart';
import '../models/service_type.dart';
import 'api_service.dart';

/// 🛠️ Service Service - Alpha Client App
///
/// Gère les services de pressing avec le backend
/// Routes publiques : GET /api/services/all
class ServiceService {
  final ApiService _api = ApiService();

  /// 📋 Récupérer tous les services
  Future<List<Service>> getAllServices() async {
    try {
      final response = await _api.get('/services/all');
      
      if (response['success'] == true || response['services'] != null) {
        final servicesData = response['services'] ?? response['data'] ?? [];
        return (servicesData as List)
            .map((json) => Service.fromJson(json))
            .toList();
      }
      
      throw Exception(response['error'] ?? 'Erreur lors de la récupération des services');
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  /// 🏷️ Récupérer tous les types de service (nécessite authentification)
  Future<List<ServiceType>> getAllServiceTypes() async {
    try {
      final response = await _api.get('/service-types');
      
      if (response['success'] == true || response['serviceTypes'] != null) {
        final serviceTypesData = response['serviceTypes'] ?? response['data'] ?? [];
        return (serviceTypesData as List)
            .map((json) => ServiceType.fromJson(json))
            .toList();
      }
      
      throw Exception(response['error'] ?? 'Erreur lors de la récupération des types de service');
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  /// 🔍 Récupérer un type de service par ID (nécessite authentification)
  Future<ServiceType> getServiceTypeById(String serviceTypeId) async {
    try {
      final response = await _api.get('/service-types/$serviceTypeId');
      
      if (response['success'] == true || response['serviceType'] != null) {
        final serviceTypeData = response['serviceType'] ?? response['data'];
        return ServiceType.fromJson(serviceTypeData);
      }
      
      throw Exception(response['error'] ?? 'Type de service non trouvé');
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }
}
