/// 📦 Modèle Article - Alpha Client App
///
/// Représente un article (Chemise, Pantalon, etc.)
/// avec ses caractéristiques et catégorie.
class Article {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Informations enrichies de la catégorie
  final String? categoryName;
  final String? categoryDescription;

  Article({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
    this.categoryDescription,
  });

  /// 📊 Conversion depuis JSON
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      // Informations enrichies
      categoryName: json['category_name'],
      categoryDescription: json['category_description'],
    );
  }

  /// 📤 Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 🔄 Copie avec modifications
  Article copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? categoryName,
    String? categoryDescription,
  }) {
    return Article(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryName: categoryName ?? this.categoryName,
      categoryDescription: categoryDescription ?? this.categoryDescription,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Article && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Article(id: $id, name: $name, category: $categoryName)';
  }
}