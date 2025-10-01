/// 🔗 Modèle Article-Service-Price - Alpha Client App
///
/// Représente un couple article-service avec ses prix basic/premium
/// selon la logique backend de tarification centralisée.
class ArticleServicePrice {
  final String id;
  final String articleId;
  final String serviceId;
  final String serviceTypeId;
  final double basePrice;
  final double premiumPrice;
  final double? pricePerKg;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Informations enrichies (jointures)
  final String? articleName;
  final String? articleDescription;
  final String? serviceName;
  final String? serviceDescription;
  final String? serviceTypeName;
  final String? serviceTypePricingType;
  final bool? serviceTypeRequiresWeight;
  final bool? serviceTypeSupportsPremium;

  ArticleServicePrice({
    required this.id,
    required this.articleId,
    required this.serviceId,
    required this.serviceTypeId,
    required this.basePrice,
    required this.premiumPrice,
    this.pricePerKg,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
    this.articleName,
    this.articleDescription,
    this.serviceName,
    this.serviceDescription,
    this.serviceTypeName,
    this.serviceTypePricingType,
    this.serviceTypeRequiresWeight,
    this.serviceTypeSupportsPremium,
  });

  /// 📊 Conversion depuis JSON
  factory ArticleServicePrice.fromJson(Map<String, dynamic> json) {
    return ArticleServicePrice(
      id: json['id']?.toString() ?? '',
      articleId: json['article_id']?.toString() ?? '',
      serviceId: json['service_id']?.toString() ?? '',
      serviceTypeId: json['service_type_id']?.toString() ?? '',
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      premiumPrice: (json['premium_price'] as num?)?.toDouble() ?? 0.0,
      pricePerKg: (json['price_per_kg'] as num?)?.toDouble(),
      isAvailable: json['is_available'] ?? true,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      // Informations enrichies
      articleName: json['article_name'],
      articleDescription: json['article_description'],
      serviceName: json['service_name'],
      serviceDescription: json['service_description'],
      serviceTypeName: json['service_type_name'],
      serviceTypePricingType: json['service_type_pricing_type'],
      serviceTypeRequiresWeight: json['service_type_requires_weight'],
      serviceTypeSupportsPremium: json['service_type_supports_premium'],
    );
  }

  /// 📤 Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'article_id': articleId,
      'service_id': serviceId,
      'service_type_id': serviceTypeId,
      'base_price': basePrice,
      'premium_price': premiumPrice,
      'price_per_kg': pricePerKg,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 💰 Obtenir le prix selon le type (basic/premium)
  double getPrice({bool isPremium = false, double? weight}) {
    if (serviceTypePricingType == 'WEIGHT_BASED' && weight != null && pricePerKg != null) {
      return weight * pricePerKg!;
    }
    
    return isPremium ? premiumPrice : basePrice;
  }

  /// 💎 Vérifier si le service supporte le premium
  bool get supportsPremium => serviceTypeSupportsPremium ?? false;

  /// ⚖️ Vérifier si le service nécessite un poids
  bool get requiresWeight => serviceTypeRequiresWeight ?? false;

  /// 🏷️ Type de tarification
  PricingType get pricingType {
    switch (serviceTypePricingType) {
      case 'FIXED':
        return PricingType.fixed;
      case 'WEIGHT_BASED':
        return PricingType.weightBased;
      default:
        return PricingType.fixed;
    }
  }

  /// 💰 Économie en passant au premium (si applicable)
  double? get premiumSavings {
    if (!supportsPremium) return null;
    return premiumPrice - basePrice;
  }

  /// 📊 Pourcentage d'augmentation premium
  double? get premiumPercentage {
    if (!supportsPremium || basePrice == 0) return null;
    return ((premiumPrice - basePrice) / basePrice) * 100;
  }

  /// 🔄 Copie avec modifications
  ArticleServicePrice copyWith({
    String? id,
    String? articleId,
    String? serviceId,
    String? serviceTypeId,
    double? basePrice,
    double? premiumPrice,
    double? pricePerKg,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? articleName,
    String? articleDescription,
    String? serviceName,
    String? serviceDescription,
    String? serviceTypeName,
    String? serviceTypePricingType,
    bool? serviceTypeRequiresWeight,
    bool? serviceTypeSupportsPremium,
  }) {
    return ArticleServicePrice(
      id: id ?? this.id,
      articleId: articleId ?? this.articleId,
      serviceId: serviceId ?? this.serviceId,
      serviceTypeId: serviceTypeId ?? this.serviceTypeId,
      basePrice: basePrice ?? this.basePrice,
      premiumPrice: premiumPrice ?? this.premiumPrice,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      articleName: articleName ?? this.articleName,
      articleDescription: articleDescription ?? this.articleDescription,
      serviceName: serviceName ?? this.serviceName,
      serviceDescription: serviceDescription ?? this.serviceDescription,
      serviceTypeName: serviceTypeName ?? this.serviceTypeName,
      serviceTypePricingType: serviceTypePricingType ?? this.serviceTypePricingType,
      serviceTypeRequiresWeight: serviceTypeRequiresWeight ?? this.serviceTypeRequiresWeight,
      serviceTypeSupportsPremium: serviceTypeSupportsPremium ?? this.serviceTypeSupportsPremium,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ArticleServicePrice && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ArticleServicePrice(id: $id, article: $articleName, service: $serviceName, basePrice: $basePrice, premiumPrice: $premiumPrice)';
  }
}

/// 🏷️ Types de tarification
enum PricingType {
  fixed('FIXED', 'Prix fixe'),
  weightBased('WEIGHT_BASED', 'Basé sur le poids');

  const PricingType(this.value, this.displayName);
  final String value;
  final String displayName;

  static PricingType fromString(String value) {
    return PricingType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => PricingType.fixed,
    );
  }
}