import '../models/category.dart';
import 'api_service.dart';

class CategoryService {
  static Future<List<Category>> getCategories() async {
    try {
      final response = await ApiService.get('categories');
      return (response['data'] as List)
          .map((json) => Category.fromJson(json))
          .toList();
    } catch (e) {
      throw 'Failed to fetch categories: $e';
    }
  }

  static Future<Category> createCategory(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.post('categories', data);
      return Category.fromJson(response['data']);
    } catch (e) {
      throw 'Failed to create category: $e';
    }
  }
}
