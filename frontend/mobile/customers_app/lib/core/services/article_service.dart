import '../models/article.dart';
import 'api_service.dart';

/// 📦 Service Article - Alpha Client App
///
/// Gère les articles de pressing avec le backend
/// Routes publiques : GET /api/articles, GET /api/articles/:id
class ArticleService {
  final ApiService _api = ApiService();

  /// 📋 Récupérer tous les articles
  Future<List<Article>> getAllArticles({bool onlyActive = true}) async {
    try {
      final queryParams = onlyActive ? {'isActive': 'true'} : null;
      final response = await _api.get('/articles', queryParameters: queryParams);
      
      if (response['success'] == true || response['articles'] != null) {
        final articlesData = response['articles'] ?? response['data'] ?? [];
        return (articlesData as List)
            .map((json) => Article.fromJson(json))
            .toList();
      }
      
      throw Exception(response['error'] ?? 'Erreur lors de la récupération des articles');
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  /// 🔍 Récupérer un article par ID
  Future<Article> getArticleById(String articleId) async {
    try {
      final response = await _api.get('/articles/$articleId');
      
      if (response['success'] == true || response['article'] != null) {
        final articleData = response['article'] ?? response['data'];
        return Article.fromJson(articleData);
      }
      
      throw Exception(response['error'] ?? 'Article non trouvé');
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  /// 📂 Récupérer les articles par catégorie
  Future<List<Article>> getArticlesByCategory(String categoryId) async {
    try {
      final response = await _api.get('/articles/category/$categoryId');
      
      if (response['success'] == true || response['articles'] != null) {
        final articlesData = response['articles'] ?? response['data'] ?? [];
        return (articlesData as List)
            .map((json) => Article.fromJson(json))
            .toList();
      }
      
      throw Exception(response['error'] ?? 'Erreur lors de la récupération des articles');
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }
}

/// 📂 Modèle Catégorie d'Article
class ArticleCategory {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final int? displayOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ArticleCategory({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.displayOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ArticleCategory.fromJson(Map<String, dynamic> json) {
    return ArticleCategory(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      icon: json['icon'],
      displayOrder: json['display_order'] ?? json['displayOrder'],
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'display_order': displayOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'ArticleCategory(id: $id, name: $name)';
}
