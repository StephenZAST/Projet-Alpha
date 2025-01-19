import '../models/article.dart';

class ArticleService {
  static Future<List<Article>> getArticles() async {
    // TODO: Implement API call
    return [
      Article(
        id: '1',
        name: 'Article 1',
        description: 'Description of Article 1',
        price: 10.0,
        categoryId: '1',
        imageUrl: 'https://via.placeholder.com/150',
      ),
      // ...other articles...
    ];
  }

  static Future<void> createArticle(Article article) async {
    // TODO: Implement API call
  }
}
