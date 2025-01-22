import '../models/category.dart';
import './api_service.dart';

class CategoryService {
  static final _api = ApiService();
  static const _baseUrl = '/api/article-categories';

  static Future<List<Category>> getAllCategories() async {
    try {
      final response = await _api.get(_baseUrl);
      // Le contrôleur backend renvoie {success, data, message} pour getAllCategories
      if (response.data != null && response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((json) => Category.fromJson(json))
            .toList();
      }
      if (response.data?['error'] != null) {
        throw response.data['error'];
      }
      return [];
    } catch (e) {
      print('[CategoryService] Error getting categories: $e');
      throw 'Erreur lors du chargement des catégories';
    }
  }

  static Future<Category> createCategory(CategoryCreateDTO dto) async {
    try {
      final response = await _api.post(
        _baseUrl,
        data: dto.toJson(),
      );
      // Les autres endpoints utilisent simplement {data}
      if (response.data != null && response.data['data'] != null) {
        return Category.fromJson(response.data['data']);
      }
      if (response.data?['error'] != null) {
        throw response.data['error'];
      }
      throw 'Erreur lors de la création de la catégorie';
    } catch (e) {
      print('[CategoryService] Error creating category: $e');
      throw 'Erreur lors de la création de la catégorie';
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

  static Future<Category> getCategoryById(String id) async {
    try {
      final response = await _api.get('$_baseUrl/$id');
      if (response.data != null && response.data['data'] != null) {
        return Category.fromJson(response.data['data']);
      }
      if (response.data?['error'] != null) {
        throw response.data['error'];
      }
      throw 'Catégorie non trouvée';
    } catch (e) {
      print('[CategoryService] Error getting category by id: $e');
      // Le backend envoie 404 si non trouvé
      if (e.toString().contains('404')) {
        throw 'Catégorie non trouvée';
      }
      throw 'Erreur lors du chargement de la catégorie';
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
}
