import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../models/article.dart';

class ArticleService {
  static const String _baseUrl =
      '/api/articles'; // Le chemin est correct maintenant
  static final ApiService _api = ApiService();

  static Future<List<Article>> getAllArticles() async {
    try {
      final response = await _api.get(_baseUrl);

      if (response.data != null && response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((item) => Article.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('[ArticleService] Error getting articles: $e');
      rethrow;
    }
  }

  static Future<Article> addNewArticle(ArticleCreateDTO dto) async {
    try {
      final response = await _api.post(_baseUrl, data: dto.toJson());
      return Article.fromJson(response.data['data']);
    } catch (e) {
      print('[ArticleService] Error creating article: $e');
      rethrow;
    }
  }

  static Future<Article> updateArticle({
    required String id,
    required ArticleUpdateDTO dto,
  }) async {
    try {
      final response = await _api.patch(
        '$_baseUrl/$id',
        data: dto.toJson(),
      );
      return Article.fromJson(response.data['data']);
    } catch (e) {
      print('[ArticleService] Error updating article: $e');
      rethrow;
    }
  }

  static Future<void> archiveArticle(String id, String reason) async {
    try {
      await _api.post('$_baseUrl/$id/archive', data: {'reason': reason});
    } catch (e) {
      print('[ArticleService] Error archiving article: $e');
      rethrow;
    }
  }

  static Future<void> deleteArticle(String id) async {
    try {
      final response = await _api.delete('$_baseUrl/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete article');
      }
    } catch (e) {
      print('[ArticleService] Error deleting article: $e');
      rethrow;
    }
  }

  static Future<List<Article>> searchArticles(String query) async {
    try {
      final response = await _api.get(_baseUrl, queryParameters: {
        'search': query,
      });
      return _parseArticleList(response.data);
    } catch (e) {
      print('[ArticleService] Error searching articles: $e');
      rethrow;
    }
  }

  // Méthode utilitaire pour parser les listes d'articles
  static List<Article> _parseArticleList(Map<String, dynamic> responseData) {
    if (responseData['data'] == null) return [];
    return (responseData['data'] as List)
        .map((item) => Article.fromJson(item))
        .toList();
  }
}
