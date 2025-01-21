import '../models/category.dart';
import 'api_service.dart';

class CategoryService {
  static Future<List<Category>> getCategories() async {
    final response = await ApiService.get('article-categories');
    return (response['data'] as List)
        .map((json) => Category.fromJson(json))
        .toList();
  }

  static Future<Category> createCategory(Map<String, dynamic> data) async {
    final response = await ApiService.post('article-categories', data);
    return Category.fromJson(response['data']);
  }
}
