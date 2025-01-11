import 'package:dio/dio.dart';
import 'package:prima/models/article.dart';
import 'package:prima/models/article_category.dart';
import 'package:prima/models/service.dart'; // Utilisez uniquement ce modèle Service

class ArticleService {
  final Dio _dio;

  ArticleService(this._dio);

  Future<List<ArticleCategory>> getCategories() async {
    try {
      final response = await _dio.get('/api/article-categories');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => ArticleCategory.fromJson(json)).toList();
      }
      throw Exception('Failed to load categories');
    } catch (e) {
      throw Exception('Error loading categories: $e');
    }
  }

  Future<List<Article>> getArticlesByCategory(String categoryId) async {
    try {
      final response = await _dio.get('/api/articles', queryParameters: {
        'categoryId': categoryId,
      });
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => Article.fromJson(json)).toList();
      }
      throw Exception('Failed to load articles');
    } catch (e) {
      throw Exception('Error loading articles: $e');
    }
  }

  // Ajout de la méthode getServices
  Future<List<Service>> getServices() async {
    try {
      final response = await _dio.get('/api/services/all');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        // Correction du typage avec .map()
        return data
            .map((json) => Service.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load services');
    } catch (e) {
      print('Error loading services: $e');
      throw Exception('Error loading services: $e');
    }
  }
}
