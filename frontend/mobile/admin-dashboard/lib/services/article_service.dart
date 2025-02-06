import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../models/article.dart';

class ArticleService {
  static const String _baseUrl = '/api/articles';
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

  // Renommé pour éviter la duplication
  static Future<Article> addNewArticle(ArticleCreateDTO dto) async {
    try {
      final response = await _api.post(_baseUrl, data: dto.toJson());
      return Article.fromJson(response.data['data']);
    } catch (e) {
      print('Error creating article: $e');
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
      print('Error updating article: $e');
      rethrow;
    }
  }

  static Future<void> removeArticle(String id) async {
    try {
      await _api.delete('$_baseUrl/$id');
    } catch (e) {
      print('Error deleting article: $e');
      rethrow;
    }
  }

  static Future<List<Article>> searchArticles(String query) async {
    try {
      final response = await _api.get('$_baseUrl/search', queryParameters: {
        'q': query,
      });
      return _parseArticleList(response.data);
    } catch (e) {
      print('Error searching articles: $e');
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
