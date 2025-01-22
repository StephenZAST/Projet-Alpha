class Article {
  final String id;
  final String name;
  final String categoryId;
  final String? description;
  final double basePrice;
  final double premiumPrice;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final List<String>? serviceIds;

  Article({
    required this.id,
    required this.name,
    required this.categoryId,
    this.description,
    required this.basePrice,
    required this.premiumPrice,
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.serviceIds,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      name: json['name'],
      categoryId: json['categoryId'],
      description: json['description'],
      basePrice: (json['basePrice'] as num).toDouble(),
      premiumPrice: (json['premiumPrice'] as num).toDouble(),
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isActive: json['isActive'] ?? true,
      serviceIds: json['serviceIds'] != null
          ? List<String>.from(json['serviceIds'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'description': description,
      'basePrice': basePrice,
      'premiumPrice': premiumPrice,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'serviceIds': serviceIds,
    };
  }

  Article copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? description,
    double? basePrice,
    double? premiumPrice,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    List<String>? serviceIds,
  }) {
    return Article(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      premiumPrice: premiumPrice ?? this.premiumPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      serviceIds: serviceIds ?? this.serviceIds,
    );
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
