import 'package:admin/models/address.dart';

import '../models/user.dart';
import './api_service.dart';

class UserService {
  static final _api = ApiService();
  static const _basePath = '/admin/users';

  /// Récupère la liste des utilisateurs avec pagination et filtres
  static Future<UserPageData> getUsers({
    int page = 1,
    int limit = 50,
    String? role,
    String? query,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (role != null) 'role': role,
        if (query != null && query.isNotEmpty) 'query': query,
      };

      final response = await _api.get(_basePath, queryParameters: queryParams);

      if (response.data != null && response.data['success'] == true) {
        return UserPageData(
          users: (response.data['data'] as List)
              .map((json) => User.fromJson(json))
              .toList(),
          total: response.data['pagination']['total'] as int,
          currentPage: page,
          totalPages: response.data['pagination']['totalPages'] as int,
        );
      }

      throw response.data?['message'] ??
          'Erreur lors du chargement des utilisateurs';
    } catch (e) {
      print('[UserService] Error getting users: $e');
      throw 'Erreur lors du chargement des utilisateurs';
    }
  }

  /// Récupère les détails d'un utilisateur par son ID
  static Future<User> getUserById(String userId) async {
    try {
      final response = await _api.get('$_basePath/$userId');

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
        '$_basePath/$userId/role',
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
        '$_basePath/$userId/status',
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
        '$_basePath/$userId',
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
      final response = await _api.get('$_basePath?role=CLIENT');

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
      final response = await _api.get('$_basePath/stats');

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

class UserPageData {
  final List<User> users;
  final int total;
  final int currentPage;
  final int totalPages;

  UserPageData({
    required this.users,
    required this.total,
    required this.currentPage,
    required this.totalPages,
  });
}
