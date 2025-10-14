/// 💰 Modèle de Prix Article-Service - Alpha Client App
///
/// Représente le prix d'un couple article-service-serviceType
/// Référence: backend/docs/REFERENCE_ARTICLE_SERVICE.md
class ArticleServicePrice {
  final String id;
  final String articleId;
  final String serviceTypeId;
  final String serviceId;
  final double basePrice;
  final double premiumPrice;
  final bool isAvailable;
  final double? pricePerKg;

  ArticleServicePrice({
    required this.id,
    required this.articleId,
    required this.serviceTypeId,
    required this.serviceId,
    required this.basePrice,
    required this.premiumPrice,
    required this.isAvailable,
    this.pricePerKg,
  });

  factory ArticleServicePrice.fromJson(Map<String, dynamic> json) {
    return ArticleServicePrice(
      id: json['id'] as String,
      articleId: json['article_id'] as String,
      serviceTypeId: json['service_type_id'] as String,
      serviceId: json['service_id'] as String,
      basePrice: _parseDouble(json['base_price']),
      premiumPrice: _parseDouble(json['premium_price']),
      isAvailable: json['is_available'] ?? true,
      pricePerKg: json['price_per_kg'] != null 
          ? _parseDouble(json['price_per_kg'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'article_id': articleId,
      'service_type_id': serviceTypeId,
      'service_id': serviceId,
      'base_price': basePrice,
      'premium_price': premiumPrice,
      'is_available': isAvailable,
      if (pricePerKg != null) 'price_per_kg': pricePerKg,
    };
  }

  /// Helper pour parser les nombres en double
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Obtenir le prix selon le mode (premium ou standard)
  double getPrice(bool isPremium) {
    return isPremium ? premiumPrice : basePrice;
  }

  @override
  String toString() {
    return 'ArticleServicePrice(id: $id, articleId: $articleId, basePrice: $basePrice, premiumPrice: $premiumPrice)';
  }
}
