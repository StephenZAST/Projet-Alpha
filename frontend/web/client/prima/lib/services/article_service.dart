import 'package:dio/dio.dart';
import '../models/article.dart';
import '../models/article_category.dart';

class ArticleService {
  final Dio _dio;

  ArticleService(this._dio);

  Future<List<ArticleCategory>> getCategories() async {
    try {
      final response = await _dio.get('/api/article-categories');
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => ArticleCategory.fromJson(json)).toList();
      }
      throw response.data['message'] ?? 'Failed to load categories';
    } catch (e) {
      throw 'Error loading categories: $e';
    }
  }

  Future<List<Article>> getArticlesByCategory(String categoryId) async {
    try {
      final response = await _dio.get('/api/articles', queryParameters: {
        'categoryId': categoryId,
      });
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => Article.fromJson(json)).toList();
      }
      throw response.data['message'] ?? 'Failed to load articles';
    } catch (e) {
      throw 'Error loading articles: $e';
    }
  }
}
