class Category {
  final String id;
  final String name;
  final String? description;
  final String? iconName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.iconName,
    DateTime? createdAt,
    this.updatedAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconName: json['iconName'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class CategoryCreateDTO {
  final String name;
  final String? description;
  final String? iconName;

  CategoryCreateDTO({
    required this.name,
    this.description,
    this.iconName,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'iconName': iconName,
    };
  }
}

class CategoryUpdateDTO {
  final String? name;
  final String? description;
  final String? iconName;
  final bool? isActive;

  CategoryUpdateDTO({
    this.name,
    this.description,
    this.iconName,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (iconName != null) 'iconName': iconName,
      if (isActive != null) 'isActive': isActive,
    };
  }
}
