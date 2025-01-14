import 'article_category.dart';

class Article {
  final String id;
  final String name;
  final double basePrice;
  final double premiumPrice;
  final String? description;
  final String categoryId;
  final Map<String, dynamic>? category; // Add this field
  final DateTime createdAt;
  final DateTime updatedAt;

  Article({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.premiumPrice,
    this.description,
    required this.categoryId,
    this.category, // Add this parameter
    required this.createdAt,
    required this.updatedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    try {
      return Article(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        basePrice: (json['basePrice'] ?? 0.0).toDouble(),
        premiumPrice: (json['premiumPrice'] ?? 0.0).toDouble(),
        description: json['description'],
        categoryId: json['categoryId'] ?? '',
        category: json['category'] as Map<String, dynamic>?, // Add this line
        createdAt: DateTime.parse(
            json['createdAt'] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(
            json['updatedAt'] ?? DateTime.now().toIso8601String()),
      );
    } catch (e) {
      print('Error parsing Article: $e');
      print('JSON data: $json');
      rethrow;
    }
  }
}
