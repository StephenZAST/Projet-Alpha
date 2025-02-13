import 'package:admin/models/address.dart';

import '../models/user.dart';
import './api_service.dart';

class UserService {
  static final _api = ApiService();
  static const _baseUrl = '/api/users';

  static Future<PaginatedResponse<User>> getUsers({
    int page = 1,
    int limit = 10,
    String? role,
    String? searchQuery,
  }) async {
    try {
      final response = await _api.get(_baseUrl, queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
        if (role != null) 'role': role,
        if (searchQuery != null && searchQuery.isNotEmpty)
          'search': searchQuery,
      });

      if (response.data == null) {
        throw 'Réponse invalide du serveur';
      }

      final List<User> users = (response.data['data'] as List)
          .map((json) => User.fromJson(json))
          .toList();

      return PaginatedResponse<User>(
        items: users,
        total: response.data['total'] ?? 0,
        currentPage: response.data['currentPage'] ?? page,
        totalPages: response.data['totalPages'] ?? 1,
      );
    } catch (e) {
      print('[UserService] Error getting users: $e');
      throw 'Erreur lors du chargement des utilisateurs';
    }
  }

  /// Récupère les détails d'un utilisateur par son ID
  static Future<User> getUserById(String userId) async {
    try {
      final response = await _api.get('$_baseUrl/$userId');

      if (response.data != null && response.data['success'] == true) {
        return User.fromJson(response.data['data']);
      }

      throw response.data?['message'] ?? 'Utilisateur non trouvé';
    } catch (e) {
      print('[UserService] Error getting user by id: $e');
      throw 'Erreur lors du chargement des détails de l\'utilisateur';
    }
  }

  /// Met à jour le rôle d'un utilisateur
  static Future<void> updateUserRole(String userId, String newRole) async {
    try {
      final response = await _api.patch(
        '$_baseUrl/$userId/role',
        data: {'role': newRole},
      );

      if (response.data == null || response.data['success'] != true) {
        throw response.data?['message'] ??
            'Erreur lors de la mise à jour du rôle';
      }
    } catch (e) {
      print('[UserService] Error updating user role: $e');
      throw 'Erreur lors de la mise à jour du rôle';
    }
  }

  /// Met à jour le statut d'un utilisateur (actif/inactif)
  static Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      final response = await _api.patch(
        '$_baseUrl/$userId/status',
        data: {'isActive': isActive},
      );

      if (response.data == null || response.data['success'] != true) {
        throw response.data?['message'] ??
            'Erreur lors de la mise à jour du statut';
      }
    } catch (e) {
      print('[UserService] Error updating user status: $e');
      throw 'Erreur lors de la mise à jour du statut';
    }
  }

  /// Met à jour les informations d'un utilisateur
  static Future<void> updateUser(
      String userId, Map<String, dynamic> userData) async {
    try {
      final response = await _api.put(
        '$_baseUrl/$userId',
        data: userData,
      );

      if (response.data == null || response.data['success'] != true) {
        throw response.data?['message'] ??
            'Erreur lors de la mise à jour de l\'utilisateur';
      }
    } catch (e) {
      print('[UserService] Error updating user: $e');
      throw 'Erreur lors de la mise à jour de l\'utilisateur';
    }
  }

  /// Récupère uniquement les clients
  static Future<List<User>> getClients() async {
    try {
      final response = await _api.get('$_baseUrl?role=CLIENT');

      if (response.data != null && response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((json) => User.fromJson(json))
            .toList();
      }

      throw response.data?['message'] ??
          'Erreur lors du chargement des clients';
    } catch (e) {
      print('[UserService] Error getting clients: $e');
      throw 'Erreur lors du chargement des clients';
    }
  }

  /// Récupère les adresses d'un utilisateur
  static Future<List<Address>> getUserAddresses(String userId) async {
    try {
      final response = await _api.get('/addresses/user/$userId');

      if (response.data != null && response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((json) => Address.fromJson(json))
            .toList();
      }

      throw response.data?['message'] ??
          'Erreur lors du chargement des adresses';
    } catch (e) {
      print('[UserService] Error getting user addresses: $e');
      throw 'Erreur lors du chargement des adresses';
    }
  }

  /// Récupère les statistiques des utilisateurs
  static Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await _api.get('$_baseUrl/stats');

      if (response.data != null && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }

      throw response.data?['message'] ??
          'Erreur lors du chargement des statistiques';
    } catch (e) {
      print('[UserService] Error getting user stats: $e');
      throw 'Erreur lors du chargement des statistiques';
    }
  }
}

class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int currentPage;
  final int totalPages;

  PaginatedResponse({
    required this.items,
    required this.total,
    required this.currentPage,
    required this.totalPages,
  });
}
