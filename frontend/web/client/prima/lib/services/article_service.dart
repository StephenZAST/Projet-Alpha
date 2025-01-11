import 'package:dio/dio.dart';
import 'package:prima/models/article.dart';
import 'package:prima/models/article_category.dart';
import 'package:prima/models/service.dart';

class ArticleService {
  final Dio _dio;

  ArticleService(this._dio);

  Future<List<Service>> getServices() async {
    try {
      print('Making request to: /api/services/all');
      print('Request data: ${_dio.options.headers}');

      final response = await _dio.get('/api/services/all');

      print('Response received: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];

        final services = data
            .map((json) {
              try {
                return Service.fromJson(json);
              } catch (e) {
                print('Error parsing service: $e');
                print('Invalid service data: $json');
                return null;
              }
            })
            .whereType<Service>()
            .toList();

        print('Successfully parsed ${services.length} services');
        return services;
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to load services: ${response.statusCode}',
      );
    } on DioException catch (e) {
      print('DioError in getServices: ${e.message}');
      print('DioError response: ${e.response?.data}');
      throw Exception('Network error while loading services: ${e.message}');
    } catch (e) {
      print('Unexpected error in getServices: $e');
      throw Exception('Error loading services: $e');
    }
  }

  Future<List<Article>> getArticlesByCategory(String categoryId) async {
    try {
      print('Fetching articles for category: $categoryId');

      final response = await _dio
          .get('/api/articles', queryParameters: {'categoryId': categoryId});

      print('Articles response: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final articles = data.map((json) => Article.fromJson(json)).toList();
        print('Parsed ${articles.length} articles for category $categoryId');
        return articles;
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to load articles',
      );
    } catch (e) {
      print('Error loading articles for category $categoryId: $e');
      throw Exception('Error loading articles: $e');
    }
  }

  Future<List<ArticleCategory>> getCategories() async {
    try {
      print('Fetching categories');

      final response = await _dio.get('/api/article-categories');

      print('Categories response: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final categories =
            data.map((json) => ArticleCategory.fromJson(json)).toList();
        print('Parsed ${categories.length} categories');
        return categories;
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to load categories',
      );
    } catch (e) {
      print('Error loading categories: $e');
      throw Exception('Error loading categories: $e');
    }
  }
}
