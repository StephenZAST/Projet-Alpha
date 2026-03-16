import '../models/user.dart';
import './api_service.dart';

class UserIdSearchService {
  static final _api = ApiService();
  static const _baseUrl = '/api/users';

  /// Recherche des utilisateurs par extrait d'ID
  /// Minimum 4 caractères requis
  /// Exemples: "2c8e", "4033", "aeb3", "8acb98fe1d1c", "06657ef1"
  static Future<List<User>> searchUsersByIdFragment(
    String idFragment, {
    int limit = 10,
  }) async {
    try {
      // Valider l'extrait
      final fragment = idFragment.trim();
      if (fragment.length < 4) {
        return [];
      }

      print('[UserIdSearchService] Searching for ID fragment: $fragment');

      final response = await _api.get(
        '$_baseUrl/search-by-id',
        queryParameters: {
          'idFragment': fragment,
          'limit': limit.toString(),
        },
      );

      print('[UserIdSearchService] Response status: ${response.statusCode}');
      print('[UserIdSearchService] Response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<User> users = (response.data['data'] as List)
            .map((json) => User.fromJson(json))
            .toList();

        print('[UserIdSearchService] Found ${users.length} users');
        return users;
      }

      print('[UserIdSearchService] No users found or error in response');
      return [];
    } catch (e) {
      print('[UserIdSearchService] Error searching by ID fragment: $e');
      return [];
    }
  }
}
