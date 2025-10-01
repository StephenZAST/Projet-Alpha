/// 🏷️ Modèle ServiceType - Alpha Client App
///
/// Représente un type de service (Express, Standard, etc.)
/// avec ses caractéristiques de tarification.
class ServiceType {
  final String id;
  final String name;
  final String description;
  final String pricingType; // FIXED, WEIGHT_BASED
  final bool requiresWeight;
  final bool supportsPremium;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceType({
    required this.id,
    required this.name,
    required this.description,
    required this.pricingType,
    this.requiresWeight = false,
    this.supportsPremium = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 📊 Conversion depuis JSON
  factory ServiceType.fromJson(Map<String, dynamic> json) {
    return ServiceType(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      pricingType: json['pricing_type'] ?? 'FIXED',
      requiresWeight: json['requires_weight'] ?? false,
      supportsPremium: json['supports_premium'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  /// 📤 Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pricing_type': pricingType,
      'requires_weight': requiresWeight,
      'supports_premium': supportsPremium,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 🏷️ Type de tarification
  PricingTypeEnum get pricingTypeEnum {
    switch (pricingType) {
      case 'FIXED':
        return PricingTypeEnum.fixed;
      case 'WEIGHT_BASED':
        return PricingTypeEnum.weightBased;
      default:
        return PricingTypeEnum.fixed;
    }
  }

  /// 🔄 Copie avec modifications
  ServiceType copyWith({
    String? id,
    String? name,
    String? description,
    String? pricingType,
    bool? requiresWeight,
    bool? supportsPremium,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceType(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      pricingType: pricingType ?? this.pricingType,
      requiresWeight: requiresWeight ?? this.requiresWeight,
      supportsPremium: supportsPremium ?? this.supportsPremium,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceType && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ServiceType(id: $id, name: $name, pricingType: $pricingType)';
  }
}

/// 🏷️ Énumération des types de tarification
enum PricingTypeEnum {
  fixed('FIXED', 'Prix fixe', 'Prix fixe par article'),
  weightBased('WEIGHT_BASED', 'Basé sur le poids', 'Prix calculé selon le poids');

  const PricingTypeEnum(this.value, this.displayName, this.description);
  final String value;
  final String displayName;
  final String description;

  static PricingTypeEnum fromString(String value) {
    return PricingTypeEnum.values.firstWhere(
      (type) => type.value == value,
      orElse: () => PricingTypeEnum.fixed,
    );
  }
}