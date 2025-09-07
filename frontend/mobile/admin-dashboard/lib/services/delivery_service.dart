import '../services/api_service.dart';
import '../models/delivery.dart';

class DeliveryService {
  static final ApiService _apiService = ApiService();

  // Helper: convert dynamic query values to Map<String, String>
  static Map<String, String> _buildQueryParams(Map<String, dynamic>? source) {
    final Map<String, String> params = {};
    if (source == null) return params;
    source.forEach((key, value) {
      if (value == null) return;
      if (value is List) {
        params[key] = value.join(',');
      } else {
        params[key] = value.toString();
      }
    });
    return params;
  }

  // Helper: safely extract a list from response['data']
  static List<T> _extractList<T>(dynamic data, T Function(dynamic) mapper) {
    if (data is List) {
      return data.map(mapper).toList();
    }
    return <T>[];
  }

  // ==================== GESTION DES LIVREURS ====================

  /// Récupère tous les livreurs (paged).
  static Future<List<DeliveryUser>> getAllDeliverers({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
  }) async {
    try {
      final query = _buildQueryParams({
        'page': page,
        'limit': limit,
        'role': 'DELIVERY',
        if (search != null && search.isNotEmpty) 'search': search,
        if (isActive != null) 'isActive': isActive,
      });

      final response = await _apiService.get('/users', queryParameters: query);
      final data = response.data;
      if (data is Map && data['success'] == true) {
        return _extractList<DeliveryUser>(
            data['data'], (u) => DeliveryUser.fromJson(u));
      }
      return <DeliveryUser>[];
    } catch (e) {
      // keep logs for debugging, but return empty list to avoid breaking callers
      print('[DeliveryService] getAllDeliverers error: $e');
      rethrow;
    }
  }

  /// Récupère un livreur par son ID
  static Future<DeliveryUser?> getDelivererById(String delivererId) async {
    try {
      final response = await _apiService.get('/users/$delivererId');
      final data = response.data;
      if (data is Map && data['success'] == true && data['data'] != null) {
        return DeliveryUser.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      print('[DeliveryService] getDelivererById error: $e');
      rethrow;
    }
  }

  /// Crée un nouveau livreur
  static Future<DeliveryUser> createDeliverer({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    String? zone,
    String? vehicleType,
    String? licenseNumber,
  }) async {
    final payload = <String, dynamic>{
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'role': 'DELIVERY',
      if (zone != null) 'zone': zone,
      if (vehicleType != null) 'vehicleType': vehicleType,
      if (licenseNumber != null) 'licenseNumber': licenseNumber,
    };

    try {
      final response = await _apiService.post('/users', data: payload);
      final data = response.data;
      if (data is Map && data['success'] == true && data['data'] != null) {
        return DeliveryUser.fromJson(data['data']);
      }
      throw Exception('Création livreur échouée');
    } catch (e) {
      print('[DeliveryService] createDeliverer error: $e');
      rethrow;
    }
  }

  /// Met à jour un livreur
  static Future<DeliveryUser> updateDeliverer(
    String delivererId, {
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    bool? isActive,
    String? zone,
    String? vehicleType,
    String? licenseNumber,
  }) async {
    final updateData = <String, dynamic>{
      if (email != null) 'email': email,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (phone != null) 'phone': phone,
      if (isActive != null) 'isActive': isActive,
      if (zone != null) 'zone': zone,
      if (vehicleType != null) 'vehicleType': vehicleType,
      if (licenseNumber != null) 'licenseNumber': licenseNumber,
    };

    try {
      final response =
          await _apiService.put('/users/$delivererId', data: updateData);
      final data = response.data;
      if (data is Map && data['success'] == true && data['data'] != null) {
        return DeliveryUser.fromJson(data['data']);
      }
      throw Exception('Mise à jour livreur échouée');
    } catch (e) {
      print('[DeliveryService] updateDeliverer error: $e');
      rethrow;
    }
  }

  /// Supprime un livreur
  static Future<bool> deleteDeliverer(String delivererId) async {
    try {
      final response = await _apiService.delete('/users/$delivererId');
      final data = response.data;
      return data is Map && data['success'] == true;
    } catch (e) {
      print('[DeliveryService] deleteDeliverer error: $e');
      rethrow;
    }
  }

  // ==================== STATISTIQUES DES LIVREURS ====================

  /// Récupère les statistiques d'un livreur
  static Future<DeliveryStats> getDelivererStats(String delivererId) async {
    try {
      final response = await _apiService.get('/delivery/stats/$delivererId');
      final data = response.data;
      if (data is Map && data['success'] == true && data['data'] != null) {
        return DeliveryStats.fromJson(data['data']);
      }
      return DeliveryStats.fromJson({});
    } catch (e) {
      print('[DeliveryService] getDelivererStats error: $e');
      return DeliveryStats.fromJson({});
    }
  }

  /// Récupère les statistiques globales de livraison
  static Future<GlobalDeliveryStats> getGlobalDeliveryStats() async {
    try {
      final response = await _apiService.get('/delivery/stats/global');
      final data = response.data;
      if (data is Map && data['success'] == true && data['data'] != null) {
        return GlobalDeliveryStats.fromJson(data['data']);
      }
      return GlobalDeliveryStats.fromJson({});
    } catch (e) {
      print('[DeliveryService] getGlobalDeliveryStats error: $e');
      return GlobalDeliveryStats.fromJson({});
    }
  }

  // ==================== GESTION DES COMMANDES ====================

  /// Récupère les commandes assignées à un livreur
  static Future<List<DeliveryOrder>> getDelivererOrders(
    String delivererId, {
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final query = _buildQueryParams({
        'page': page,
        'limit': limit,
        'delivererId': delivererId,
        if (status != null) 'status': status,
      });

      final response = await _apiService.get('/orders', queryParameters: query);
      final data = response.data;
      if (data is Map && data['success'] == true) {
        return _extractList<DeliveryOrder>(
            data['data'], (o) => DeliveryOrder.fromJson(o));
      }
      return <DeliveryOrder>[];
    } catch (e) {
      print('[DeliveryService] getDelivererOrders error: $e');
      rethrow;
    }
  }

  /// Assigne une commande à un livreur
  static Future<bool> assignOrderToDeliverer(
      String orderId, String delivererId) async {
    try {
      final response = await _apiService
          .patch('/orders/$orderId/assign', data: {'delivererId': delivererId});
      final data = response.data;
      return data is Map && data['success'] == true;
    } catch (e) {
      print('[DeliveryService] assignOrderToDeliverer error: $e');
      rethrow;
    }
  }

  /// Met à jour le statut d'une commande (admin override)
  static Future<bool> updateOrderStatus(String orderId, String newStatus,
      {String? note}) async {
    try {
      final updateData = <String, dynamic>{
        'status': newStatus,
        if (note != null) 'note': note
      };
      final response =
          await _apiService.patch('/orders/$orderId/status', data: updateData);
      final data = response.data;
      return data is Map && data['success'] == true;
    } catch (e) {
      print('[DeliveryService] updateOrderStatus error: $e');
      rethrow;
    }
  }

  /// Récupère toutes les commandes en cours de livraison
  static Future<List<DeliveryOrder>> getAllActiveDeliveries({
    int page = 1,
    int limit = 50,
    String? status,
    String? delivererId,
  }) async {
    try {
      final defaultStatuses =
          'COLLECTING,COLLECTED,PROCESSING,READY,DELIVERING';
      final query = _buildQueryParams({
        'page': page,
        'limit': limit,
        'status': status ?? defaultStatuses,
        if (delivererId != null) 'delivererId': delivererId,
      });

      final response = await _apiService.get('/orders', queryParameters: query);
      final data = response.data;
      if (data is Map && data['success'] == true) {
        return _extractList<DeliveryOrder>(
            data['data'], (o) => DeliveryOrder.fromJson(o));
      }
      return <DeliveryOrder>[];
    } catch (e) {
      print('[DeliveryService] getAllActiveDeliveries error: $e');
      rethrow;
    }
  }

  // ==================== UTILITAIRES ====================

  /// Vérifie si un email est disponible pour un nouveau livreur
  static Future<bool> isEmailAvailable(String email) async {
    try {
      final response = await _apiService
          .get('/users/check-email', queryParameters: {'email': email});
      final data = response.data;
      if (data is Map) {
        if (data.containsKey('available')) return data['available'] == true;
        if (data['data'] != null &&
            data['data'] is Map &&
            data['data']['available'] != null) {
          return data['data']['available'] == true;
        }
      }
      return false;
    } catch (e) {
      print('[DeliveryService] isEmailAvailable error: $e');
      return false;
    }
  }

  /// Active ou désactive un livreur
  static Future<bool> toggleDelivererStatus(
      String delivererId, bool isActive) async {
    try {
      final response = await _apiService
          .patch('/users/$delivererId/status', data: {'isActive': isActive});
      final data = response.data;
      return data is Map && data['success'] == true;
    } catch (e) {
      print('[DeliveryService] toggleDelivererStatus error: $e');
      rethrow;
    }
  }

  /// Réinitialise le mot de passe d'un livreur
  static Future<bool> resetDelivererPassword(
      String delivererId, String newPassword) async {
    try {
      final response = await _apiService.patch('/users/$delivererId/password',
          data: {'newPassword': newPassword});
      final data = response.data;
      return data is Map && data['success'] == true;
    } catch (e) {
      print('[DeliveryService] resetDelivererPassword error: $e');
      rethrow;
    }
  }
}
