class Article {
  final String id;
  final String name;
  final String? description;
  final double basePrice;
  final double? premiumPrice;
  final String? categoryId;
  final String? category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final DateTime? deletedAt;

  Article({
    required this.id,
    required this.name,
    this.description,
    required this.basePrice,
    this.premiumPrice,
    this.categoryId,
    this.category,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.deletedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      premiumPrice: json['premiumPrice']?.toDouble(),
      categoryId: json['categoryId'],
      category:
          json['category'] is Map ? json['category']['name'] : json['category'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isDeleted: json['isDeleted'] ?? false,
      deletedAt:
          json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'basePrice': basePrice,
      'premiumPrice': premiumPrice,
      'categoryId': categoryId,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}

class ArticleUpdateDTO {
  final String? name;
  final String? categoryId;
  final String? description;
  final double? basePrice;
  final double? premiumPrice;
  final bool? isActive;

  ArticleUpdateDTO({
    this.name,
    this.categoryId,
    this.description,
    this.basePrice,
    this.premiumPrice,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (categoryId != null) 'categoryId': categoryId,
      if (description != null) 'description': description,
      if (basePrice != null) 'basePrice': basePrice,
      if (premiumPrice != null) 'premiumPrice': premiumPrice,
      if (isActive != null) 'isActive': isActive,
    };
  }
}

class ArticleCreateDTO {
  final String name;
  final String categoryId;
  final String? description;
  final double basePrice;
  final double premiumPrice;

  ArticleCreateDTO({
    required this.name,
    required this.categoryId,
    this.description,
    required this.basePrice,
    required this.premiumPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'categoryId': categoryId,
      'description': description,
      'basePrice': basePrice,
      'premiumPrice': premiumPrice,
    };
  }
}
