import '../services/api_service.dart';
import '../models/delivery.dart';
import '../models/user.dart';

class DeliveryService {
  static final ApiService _apiService = ApiService();

  // ==================== GESTION DES LIVREURS ====================

  /// Récupère tous les livreurs
  static Future<List<DeliveryUser>> getAllDeliverers({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
  }) async {
    try {
      print('[DeliveryService] Récupération des livreurs - page: $page, limit: $limit');

      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
        'role': 'DELIVERY',
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (isActive != null) {
        queryParams['isActive'] = isActive.toString();
      }

      final response = await _apiService.get('/users', queryParams: queryParams);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> usersData = response['data'] as List<dynamic>;
        return usersData.map((userData) => DeliveryUser.fromJson(userData)).toList();
      }

      return [];
    } catch (e) {
      print('[DeliveryService] Erreur lors de la récupération des livreurs: $e');
      throw Exception('Erreur lors de la récupération des livreurs: $e');
    }
  }

  /// Récupère un livreur par son ID
  static Future<DeliveryUser?> getDelivererById(String delivererId) async {
    try {
      print('[DeliveryService] Récupération du livreur: $delivererId');

      final response = await _apiService.get('/users/$delivererId');

      if (response['success'] == true && response['data'] != null) {
        return DeliveryUser.fromJson(response['data']);
      }

      return null;
    } catch (e) {
      print('[DeliveryService] Erreur lors de la récupération du livreur: $e');
      throw Exception('Erreur lors de la récupération du livreur: $e');
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
    try {
      print('[DeliveryService] Création d\'un nouveau livreur: $email');

      final userData = {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'role': 'DELIVERY',
      };

      final response = await _apiService.post('/users', userData);

      if (response['success'] == true && response['data'] != null) {
        return DeliveryUser.fromJson(response['data']);
      }

      throw Exception('Erreur lors de la création du livreur');
    } catch (e) {
      print('[DeliveryService] Erreur lors de la création du livreur: $e');
      throw Exception('Erreur lors de la création du livreur: $e');
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
    try {
      print('[DeliveryService] Mise à jour du livreur: $delivererId');

      final updateData = <String, dynamic>{};

      if (email != null) updateData['email'] = email;
      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (phone != null) updateData['phone'] = phone;

      final response = await _apiService.put('/users/$delivererId', updateData);

      if (response['success'] == true && response['data'] != null) {
        return DeliveryUser.fromJson(response['data']);
      }

      throw Exception('Erreur lors de la mise à jour du livreur');
    } catch (e) {
      print('[DeliveryService] Erreur lors de la mise à jour du livreur: $e');
      throw Exception('Erreur lors de la mise à jour du livreur: $e');
    }
  }

  /// Supprime un livreur
  static Future<bool> deleteDeliverer(String delivererId) async {
    try {
      print('[DeliveryService] Suppression du livreur: $delivererId');

      final response = await _apiService.delete('/users/$delivererId');

      return response['success'] == true;
    } catch (e) {
      print('[DeliveryService] Erreur lors de la suppression du livreur: $e');
      throw Exception('Erreur lors de la suppression du livreur: $e');
    }
  }

  // ==================== STATISTIQUES DES LIVREURS ====================

  /// Récupère les statistiques d'un livreur
  static Future<DeliveryStats> getDelivererStats(String delivererId) async {
    try {
      print('[DeliveryService] Récupération des statistiques du livreur: $delivererId');

      final response = await _apiService.get('/delivery/stats/$delivererId');

      if (response['success'] == true && response['data'] != null) {
        return DeliveryStats.fromJson(response['data']);
      }

      // Retourner des statistiques vides si pas de données
      return DeliveryStats.fromJson({});
    } catch (e) {
      print('[DeliveryService] Erreur lors de la récupération des statistiques: $e');
      // Retourner des statistiques vides en cas d'erreur
      return DeliveryStats.fromJson({});
    }
  }

  /// Récupère les statistiques globales de livraison
  static Future<GlobalDeliveryStats> getGlobalDeliveryStats() async {
    try {
      print('[DeliveryService] Récupération des statistiques globales de livraison');

      final response = await _apiService.get('/delivery/stats/global');

      if (response['success'] == true && response['data'] != null) {
        return GlobalDeliveryStats.fromJson(response['data']);
      }

      // Retourner des statistiques vides si pas de données
      return GlobalDeliveryStats.fromJson({});
    } catch (e) {
      print('[DeliveryService] Erreur lors de la récupération des statistiques globales: $e');
      // Retourner des statistiques vides en cas d'erreur
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
      print('[DeliveryService] Récupération des commandes du livreur: $delivererId');

      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
        'delivererId': delivererId,
      };

      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _apiService.get('/orders', queryParams: queryParams);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> ordersData = response['data'] as List<dynamic>;
        return ordersData.map((orderData) => DeliveryOrder.fromJson(orderData)).toList();
      }

      return [];
    } catch (e) {
      print('[DeliveryService] Erreur lors de la récupération des commandes: $e');
      throw Exception('Erreur lors de la récupération des commandes: $e');
    }
  }

  /// Assigne une commande à un livreur
  static Future<bool> assignOrderToDeliverer(String orderId, String delivererId) async {
    try {
      print('[DeliveryService] Attribution de la commande $orderId au livreur $delivererId');

      final response = await _apiService.patch('/orders/$orderId/assign', {
        'delivererId': delivererId,
      });

      return response['success'] == true;
    } catch (e) {
      print('[DeliveryService] Erreur lors de l\'attribution de la commande: $e');
      throw Exception('Erreur lors de l\'attribution de la commande: $e');
    }
  }

  /// Met à jour le statut d'une commande (admin override)
  static Future<bool> updateOrderStatus(String orderId, String newStatus, {String? note}) async {
    try {
      print('[DeliveryService] Mise à jour du statut de la commande $orderId vers $newStatus');

      final updateData = {
        'status': newStatus,
      };

      if (note != null && note.isNotEmpty) {
        updateData['note'] = note;
      }

      final response = await _apiService.patch('/orders/$orderId/status', updateData);

      return response['success'] == true;
    } catch (e) {
      print('[DeliveryService] Erreur lors de la mise à jour du statut: $e');
      throw Exception('Erreur lors de la mise à jour du statut: $e');
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
      print('[DeliveryService] Récupération de toutes les livraisons actives');

      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      // Filtrer par statuts de livraison actifs
      if (status != null) {
        queryParams['status'] = status;
      } else {
        queryParams['status'] = 'COLLECTING,COLLECTED,PROCESSING,READY,DELIVERING';
      }

      if (delivererId != null) {
        queryParams['delivererId'] = delivererId;
      }

      final response = await _apiService.get('/orders', queryParams: queryParams);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> ordersData = response['data'] as List<dynamic>;
        return ordersData.map((orderData) => DeliveryOrder.fromJson(orderData)).toList();
      }

      return [];
    } catch (e) {
      print('[DeliveryService] Erreur lors de la récupération des livraisons actives: $e');
      throw Exception('Erreur lors de la récupération des livraisons actives: $e');
    }
  }

  // ==================== UTILITAIRES ====================

  /// Vérifie si un email est disponible pour un nouveau livreur
  static Future<bool> isEmailAvailable(String email) async {
    try {
      final response = await _apiService.get('/users/check-email', queryParams: {
        'email': email,
      });

      return response['available'] == true;
    } catch (e) {
      print('[DeliveryService] Erreur lors de la vérification de l\'email: $e');
      return false;
    }
  }

  /// Active ou désactive un livreur
  static Future<bool> toggleDelivererStatus(String delivererId, bool isActive) async {
    try {
      print('[DeliveryService] ${isActive ? 'Activation' : 'Désactivation'} du livreur: $delivererId');

      final response = await _apiService.patch('/users/$delivererId/status', {
        'isActive': isActive,
      });

      return response['success'] == true;
    } catch (e) {
      print('[DeliveryService] Erreur lors du changement de statut: $e');
      throw Exception('Erreur lors du changement de statut: $e');
    }
  }

  /// Réinitialise le mot de passe d'un livreur
  static Future<bool> resetDelivererPassword(String delivererId, String newPassword) async {
    try {
      print('[DeliveryService] Réinitialisation du mot de passe du livreur: $delivererId');

      final response = await _apiService.patch('/users/$delivererId/password', {
        'newPassword': newPassword,
      });

      return response['success'] == true;
    } catch (e) {
      print('[DeliveryService] Erreur lors de la réinitialisation du mot de passe: $e');
      throw Exception('Erreur lors de la réinitialisation du mot de passe: $e');
    }
  }
}