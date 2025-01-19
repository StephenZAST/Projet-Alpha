import '../models/article_category.dart';

class CategoryService {
  static Future<List<ArticleCategory>> getCategories() async {
    // TODO: Implement API call
    return [
      ArticleCategory(
        id: '1',
        name: 'Category 1',
        description: 'Description of Category 1',
      ),
      // ...other categories...
    ];
  }

  static Future<void> createCategory(String name, String? description) async {
    // TODO: Implement API call
  }
}
