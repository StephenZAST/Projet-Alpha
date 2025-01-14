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
      final response = await _dio.get('/api/articles');
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => Article.fromJson(json)).toList();
      }
      throw response.data['message'] ?? 'Failed to load articles';
    } catch (e) {
      throw 'Error loading articles: $e';
    }
  }

  Future<List<Article>> getArticles() async {
    try {
      final response = await _dio.get('/api/articles');
      print('Response received: ${response.data}');

      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> articlesJson = response.data['data'];
        print('Parsing ${articlesJson.length} articles');
        return articlesJson.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load articles: ${response.data['message']}');
      }
    } catch (e) {
      print('Error fetching articles: $e');
      throw Exception('Failed to load articles: $e');
    }
  }
}
