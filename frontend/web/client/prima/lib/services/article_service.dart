import 'package:dio/dio.dart';
import 'package:prima/widgets/order_bottom_sheet.dart';

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
}
