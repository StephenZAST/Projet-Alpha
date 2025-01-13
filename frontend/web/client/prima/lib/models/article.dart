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
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'basePrice': basePrice,
      'premiumPrice': premiumPrice,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
