class ArticleCategory {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;

  ArticleCategory({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  factory ArticleCategory.fromJson(Map<String, dynamic> json) {
    try {
      return ArticleCategory(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : DateTime.now(),
      );
    } catch (e) {
      print('Error parsing ArticleCategory: $e');
      print('JSON data: $json');
      throw e;
    }
  }
}
