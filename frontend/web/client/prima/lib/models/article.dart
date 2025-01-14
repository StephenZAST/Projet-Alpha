import 'article_category.dart';

class Article {
  final String id;
  final String name;
  final double basePrice;
  final double premiumPrice;
  final String? description;
  final String categoryId;
  final ArticleCategory? category;
  final DateTime createdAt;

  Article({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.premiumPrice,
    this.description,
    required this.categoryId,
    this.category,
    required this.createdAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    try {
      return Article(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        basePrice: (json['base_price'] ?? 0.0).toDouble(),
        premiumPrice: (json['premium_price'] ?? 0.0).toDouble(),
        description: json['description'],
        categoryId: json['category_id'] ?? '',
        category: json['category'] != null
            ? ArticleCategory.fromJson(json['category'])
            : null,
        createdAt: DateTime.parse(json['created_at']),
      );
    } catch (e) {
      print('Error parsing Article: $e');
      rethrow;
    }
  }
}
