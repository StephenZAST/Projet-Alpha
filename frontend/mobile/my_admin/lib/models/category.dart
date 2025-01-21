class Category {
  final String id;
  final String name;
  final String? description;
  final int articlesCount;
  final bool isActive;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.articlesCount = 0,
    this.isActive = true,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      articlesCount: json['articlesCount'] ?? 0,
      isActive: json['isActive'],
    );
  }
}
