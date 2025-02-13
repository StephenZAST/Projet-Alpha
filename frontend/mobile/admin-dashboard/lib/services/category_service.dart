import '../models/category.dart';
import './api_service.dart';

class CategoryService {
  static final _api = ApiService();
  static const _baseUrl = '/api/article-categories'; // Ajout du préfixe /api/

  static Future<List<Category>> getAllCategories() async {
    try {
      print('[CategoryService] Fetching categories...');
      final response = await _api.get(_baseUrl);

      if (response.statusCode == 401) {
        throw 'Session expirée. Veuillez vous reconnecter.';
      }

      if (response.statusCode != 200) {
        throw 'Erreur serveur: ${response.statusCode}';
      }

      print('[CategoryService] Raw response: ${response.data}');

      if (response.data is Map && response.data['data'] != null) {
        if (response.data['data'] is List) {
          return (response.data['data'] as List)
              .map((json) => Category.fromJson(json))
              .toList();
        }
      }

      // Si la réponse est directement une liste
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Category.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      print('[CategoryService] Error getting categories: $e');
      throw Exception(
          'Une erreur est survenue lors du chargement des catégories');
    }
  }

  static Future<Category> createCategory(CategoryCreateDTO dto) async {
    try {
      final response = await _api.post(
        _baseUrl,
        data: dto.toJson(),
      );
      // Les autres endpoints utilisent simplement {data}
      if (response.data is Map && response.data['data'] != null) {
        return Category.fromJson(response.data['data']);
      }
      if (response.data?['error'] != null) {
        throw response.data['error'];
      }
      throw Exception('Erreur lors de la création de la catégorie');
    } catch (e) {
      print('[CategoryService] Error creating category: $e');
      throw Exception(
          'Une erreur est survenue lors de la création de la catégorie');
    }
  }

  static Future<Category> updateCategory({
    required String id,
    required CategoryUpdateDTO dto,
  }) async {
    try {
      final response = await _api.patch(
        '$_baseUrl/$id',
        data: dto.toJson(),
      );
      if (response.data != null && response.data['data'] != null) {
        return Category.fromJson(response.data['data']);
      }
      if (response.data?['error'] != null) {
        throw response.data['error'];
      }
      throw 'Erreur lors de la mise à jour de la catégorie';
    } catch (e) {
      print('[CategoryService] Error updating category: $e');
      throw 'Erreur lors de la mise à jour de la catégorie';
    }
  }

  static Future<void> deleteCategory(String id) async {
    try {
      final response = await _api.delete('$_baseUrl/$id');
      if (response.data?['error'] != null) {
        throw response.data['error'];
      }
      // Le backend renvoie un message de succès qu'on pourrait utiliser si nécessaire
      return;
    } catch (e) {
      print('[CategoryService] Error deleting category: $e');
      throw 'Erreur lors de la suppression de la catégorie';
    }
  }

  static Future<Category?> getCategoryById(String id) async {
    try {
      final response = await _api.get('$_baseUrl/$id');
      if (response.data is Map) {
        if (response.data['data'] != null) {
          return Category.fromJson(response.data['data']);
        }
        return Category.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('[CategoryService] Error getting category by id: $e');
      throw Exception(
          'Une erreur est survenue lors de la récupération de la catégorie');
    }
  }

  static Future<List<Category>> searchCategories(String query) async {
    try {
      // Implémentation côté client puisque le backend n'a pas d'endpoint de recherche
      final categories = await getAllCategories();
      if (query.isEmpty) return categories;

      final normalizedQuery = query.toLowerCase().trim();
      return categories
          .where((category) =>
              category.name.toLowerCase().contains(normalizedQuery) ||
              (category.description?.toLowerCase() ?? '')
                  .contains(normalizedQuery))
          .toList();
    } catch (e) {
      print('[CategoryService] Error searching categories: $e');
      throw 'Erreur lors de la recherche de catégories';
    }
  }

  static Future<bool> validateCategory(CategoryCreateDTO dto) async {
    if (dto.name.isEmpty) {
      throw 'Le nom de la catégorie est requis';
    }
    return true;
  }
}
