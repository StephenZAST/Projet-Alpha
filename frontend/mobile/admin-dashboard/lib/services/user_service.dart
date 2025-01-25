import 'package:admin/models/address.dart';

import '../models/user.dart';
import 'api_service.dart';

class UserService {
  static final _api = ApiService();
  static const String _basePath = '/users';

  static Future<List<User>> getClients() async {
    try {
      final response =
          await _api.get('/admin/users', queryParameters: {'role': 'CLIENT'});

      if (response.data != null && response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((json) => User.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('[UserService] Error getting clients: $e');
      throw 'Erreur lors du chargement des clients';
    }
  }

  static Future<List<User>> searchClients(String query) async {
    try {
      final response = await _api.get('/admin/users/search',
          queryParameters: {'query': query, 'role': 'CLIENT'});

      if (response.data != null && response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((json) => User.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('[UserService] Error searching clients: $e');
      throw 'Erreur lors de la recherche des clients';
    }
  }

  static Future<List<Address>> getUserAddresses(String userId) async {
    try {
      final response = await _api.get('$_basePath/$userId/addresses');

      if (response.data != null && response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((json) => Address.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('[UserService] Error getting user addresses: $e');
      throw 'Erreur lors du chargement des adresses';
    }
  }

  static Future<User> getUserDetails(String userId) async {
    try {
      final response = await _api.get('$_basePath/$userId');

      if (response.data != null && response.data['data'] != null) {
        return User.fromJson(response.data['data']);
      }
      throw 'Utilisateur non trouvé';
    } catch (e) {
      print('[UserService] Error getting user details: $e');
      throw 'Erreur lors du chargement des détails utilisateur';
    }
  }
}
