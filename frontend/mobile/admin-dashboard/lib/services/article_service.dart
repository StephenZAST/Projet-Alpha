import '../models/article.dart';
import 'api_service.dart';

class ArticleService {
  static Future<List<Article>> getArticles() async {
    final response = await ApiService.get('articles');
    return (response['data'] as List)
        .map((json) => Article.fromJson(json))
        .toList();
  }

  static Future<Article> createArticle(Map<String, dynamic> data) async {
    final response = await ApiService.post('articles', data);
    return Article.fromJson(response['data']);
  }

  static Future<void> updateArticle(
      String id, Map<String, dynamic> data) async {
    await ApiService.put('articles/$id', data);
  }

  static Future<void> deleteArticle(String id) async {
    await ApiService.delete('articles/$id');
  }
}
