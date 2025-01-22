import 'dart:io';
import 'package:dio/dio.dart';
import '../models/article.dart';
import './api_service.dart';

class ArticleService {
  static final _api = ApiService();
  static const _baseUrl = '/api/articles';

  static Future<List<Article>> getAllArticles() async {
    try {
      final response = await _api.get(_baseUrl);
      if (response.data != null && response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((json) => Article.fromJson(json))
            .toList();
      }
      if (response.data?['error'] != null) {
        throw response.data['error'];
      }
      throw response.data?['message'] ??
          'Erreur lors du chargement des articles';
    } catch (e) {
      print('[ArticleService] Error getting all articles: $e');
      if (e is DioError && e.response?.statusCode == 500) {
        throw 'Erreur serveur lors du chargement des articles';
      }
      throw 'Erreur lors du chargement des articles';
    }
  }

  static Future<Article> getArticleById(String id) async {
    try {
      final response = await _api.get('$_baseUrl/$id');
      if (response.data != null && response.data['success'] == true) {
        return Article.fromJson(response.data['data']);
      }
      if (response.data?['error'] != null) {
        throw response.data['error'];
      }
      throw response.data?['message'] ?? 'Article non trouvé';
    } catch (e) {
      print('[ArticleService] Error getting article by id: $e');
      if (e is DioError) {
        if (e.response?.statusCode == 404) {
          throw 'Article non trouvé';
        }
        if (e.response?.statusCode == 500) {
          throw 'Erreur serveur lors du chargement de l\'article';
        }
      }
      throw 'Erreur lors du chargement de l\'article';
    }
  }

  static Future<Article> createArticle(ArticleCreateDTO dto) async {
    try {
      final response = await _api.post(
        _baseUrl,
        data: dto.toJson(),
      );
      if (response.data != null && response.data['success'] == true) {
        return Article.fromJson(response.data['data']);
      }
      if (response.data?['error'] != null) {
        throw response.data['error'];
      }
      throw response.data?['message'] ??
          'Erreur lors de la création de l\'article';
    } catch (e) {
      print('[ArticleService] Error creating article: $e');
      if (e is DioError && e.response?.statusCode == 500) {
        throw 'Erreur serveur lors de la création de l\'article';
      }
      throw 'Erreur lors de la création de l\'article';
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
      if (response.data != null && response.data['success'] == true) {
        return Article.fromJson(response.data['data']);
      }
      if (response.data?['error'] != null) {
        throw response.data['error'];
      }
      throw response.data?['message'] ??
          'Erreur lors de la mise à jour de l\'article';
    } catch (e) {
      print('[ArticleService] Error updating article: $e');
      if (e is DioError) {
        if (e.response?.statusCode == 404) {
          throw 'Article non trouvé';
        }
        if (e.response?.statusCode == 500) {
          throw 'Erreur serveur lors de la mise à jour de l\'article';
        }
      }
      throw 'Erreur lors de la mise à jour de l\'article';
    }
  }

  static Future<void> deleteArticle(String id) async {
    try {
      final response = await _api.delete('$_baseUrl/$id');
      if (response.data?['error'] != null) {
        throw response.data['error'];
      }
      if (response.data?['success'] != true) {
        throw response.data?['message'] ??
            'Erreur lors de la suppression de l\'article';
      }
    } catch (e) {
      print('[ArticleService] Error deleting article: $e');
      if (e is DioError) {
        if (e.response?.statusCode == 404) {
          throw 'Article non trouvé';
        }
        if (e.response?.statusCode == 500) {
          throw 'Erreur serveur lors de la suppression de l\'article';
        }
      }
      throw 'Erreur lors de la suppression de l\'article';
    }
  }

  static Future<List<Article>> searchArticles(String query) async {
    try {
      // Implémentation côté client puisque le backend n'a pas d'endpoint de recherche
      final articles = await getAllArticles();
      if (query.isEmpty) return articles;

      final normalizedQuery = query.toLowerCase().trim();
      return articles
          .where((article) =>
              article.name.toLowerCase().contains(normalizedQuery) ||
              (article.description?.toLowerCase() ?? '')
                  .contains(normalizedQuery))
          .toList();
    } catch (e) {
      print('[ArticleService] Error searching articles: $e');
      throw 'Erreur lors de la recherche d\'articles';
    }
  }

  static Future<List<Article>> getArticlesByCategory(String categoryId) async {
    try {
      // Récupérer tous les articles et filtrer par catégorie côté client
      final articles = await getAllArticles();
      return articles
          .where((article) => article.categoryId == categoryId)
          .toList();
    } catch (e) {
      print('[ArticleService] Error getting articles by category: $e');
      throw 'Erreur lors du chargement des articles par catégorie';
    }
  }

  static Future<Article> uploadArticleImage(
    String articleId,
    String imagePath,
  ) async {
    try {
      final file = await MultipartFile.fromFile(
        imagePath,
        filename: imagePath.split('/').last,
      );

      final formData = FormData();
      formData.files.add(MapEntry('image', file));

      final response = await _api.post(
        '$_baseUrl/$articleId/image',
        data: formData,
      );

      if (response.data != null && response.data['success'] == true) {
        return Article.fromJson(response.data['data']);
      }
      if (response.data?['error'] != null) {
        throw response.data['error'];
      }
      throw response.data?['message'] ??
          'Erreur lors du téléchargement de l\'image';
    } catch (e) {
      print('[ArticleService] Error uploading article image: $e');
      if (e is DioError) {
        if (e.response?.statusCode == 404) {
          throw 'Article non trouvé';
        }
        if (e.response?.statusCode == 500) {
          throw 'Erreur serveur lors du téléchargement de l\'image';
        }
      }
      throw 'Erreur lors du téléchargement de l\'image';
    }
  }
}
