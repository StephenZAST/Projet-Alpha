import 'dart:convert';
import 'package:customers_app/core/utils/storage_service.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';

/// 📂 Service des Catégories - Alpha Client App
///
/// Gère les appels API pour les catégories d'articles
class CategoryService {
  final StorageService _storage = StorageService();

  /// 📋 Récupérer toutes les catégories
  Future<List<ArticleCategory>> getAllCategories() async {
    try {
      final token = StorageService.getToken();

      final url = ApiConfig.url('/article-categories');
      print('[CategoryService] GET $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.timeout);

      print('[CategoryService] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> categoriesJson = data['data'] ?? data;

        return categoriesJson
            .map((json) => ArticleCategory.fromJson(json))
            .toList();
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('[CategoryService] Erreur: $e');
      rethrow;
    }
  }

  /// 📋 Récupérer une catégorie par ID
  Future<ArticleCategory> getCategoryById(String categoryId) async {
    try {
      final token = StorageService.getToken();

      final url = ApiConfig.url('/article-categories/$categoryId');
      print('[CategoryService] GET $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ArticleCategory.fromJson(data['data'] ?? data);
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('[CategoryService] Erreur: $e');
      rethrow;
    }
  }
}

/// 📂 Modèle Catégorie d'Article
class ArticleCategory {
  final String id;
  final String name;
  final String? description;
  final DateTime? createdAt;

  ArticleCategory({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
  });

  factory ArticleCategory.fromJson(Map<String, dynamic> json) {
    return ArticleCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
