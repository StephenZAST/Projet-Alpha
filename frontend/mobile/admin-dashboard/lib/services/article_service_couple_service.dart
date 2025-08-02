import '../services/api_service.dart';

class ArticleServiceCoupleService {
  static const String _baseUrl = '/api/article-services/prices';
  static final ApiService _api = ApiService();

  /// Récupère les prix pour un couple ServiceType/Service/Article
  static Future<Map<String, dynamic>> getPricesForCouple({
    required String serviceTypeId,
    required String serviceId,
    required String articleId,
  }) async {
    try {
      final response = await _api.get(
        _baseUrl,
        queryParameters: {
          'serviceTypeId': serviceTypeId,
          'serviceId': serviceId,
          'articleId': articleId,
        },
      );
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      print('Error fetching prices for couple: $e');
      rethrow;
    }
  }

  /// Récupère tous les couples service/article avec leurs prix
  static Future<List<Map<String, dynamic>>>
      getAllServiceArticleCouples() async {
    try {
      final response = await _api.get(_baseUrl);
      if (response.data != null && response.data['data'] != null) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      print('[ArticleServiceCoupleService] Error fetching couples: $e');
      return [];
    }
  }

  /// Ajoute un nouveau couple service/article
  static Future<bool> addServiceArticleCouple(Map<String, dynamic> data) async {
    try {
      final response = await _api.post(_baseUrl, data: data);
      return response.statusCode == 201;
    } catch (e) {
      print('[ArticleServiceCoupleService] Error adding couple: $e');
      return false;
    }
  }

  /// Met à jour un couple service/article
  static Future<bool> updateServiceArticleCouple(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _api.patch('$_baseUrl/$id', data: data);
      return response.statusCode == 200;
    } catch (e) {
      print('[ArticleServiceCoupleService] Error updating couple: $e');
      return false;
    }
  }

  /// Supprime un couple service/article
  static Future<bool> deleteServiceArticleCouple(String id) async {
    try {
      final response = await _api.delete('$_baseUrl/$id');
      return response.statusCode == 200;
    } catch (e) {
      print('[ArticleServiceCoupleService] Error deleting couple: $e');
      return false;
    }
  }
}
