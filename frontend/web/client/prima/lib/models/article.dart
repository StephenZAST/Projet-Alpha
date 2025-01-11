class Article {
  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final double basePrice;
  final double premiumPrice;
  final DateTime createdAt;
  final DateTime updatedAt;

  Article({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.basePrice,
    required this.premiumPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? '',
      categoryId: json['categoryId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      premiumPrice: (json['premiumPrice'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
}
