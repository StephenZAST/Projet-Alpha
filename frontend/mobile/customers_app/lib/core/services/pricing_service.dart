import 'api_service.dart';

/// 💰 Service de Tarification - Alpha Client App
///
/// Gère les prix des couples article-service avec le backend
/// Routes : GET /api/article-services/prices (nécessite authentification)
class PricingService {
  final ApiService _api = ApiService();

  /// 📋 Récupérer tous les prix
  Future<List<ArticleServicePrice>> getAllPrices() async {
    try {
      final response = await _api.get('/article-services/prices');
      
      if (response['success'] == true || response['prices'] != null) {
        final pricesData = response['prices'] ?? response['data'] ?? [];
        return (pricesData as List)
            .map((json) => ArticleServicePrice.fromJson(json))
            .toList();
      }
      
      throw Exception(response['error'] ?? 'Erreur lors de la récupération des prix');
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  /// 🔍 Récupérer les prix d'un article spécifique
  Future<List<ArticleServicePrice>> getArticlePrices(String articleId) async {
    try {
      final response = await _api.get('/article-services/$articleId/prices');
      
      if (response['success'] == true || response['prices'] != null) {
        final pricesData = response['prices'] ?? response['data'] ?? [];
        return (pricesData as List)
            .map((json) => ArticleServicePrice.fromJson(json))
            .toList();
      }
      
      throw Exception(response['error'] ?? 'Erreur lors de la récupération des prix');
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  /// 🎯 Récupérer les couples pour un type de service
  Future<List<ArticleServiceCouple>> getCouplesForServiceType(String serviceTypeId) async {
    try {
      final response = await _api.get('/article-services/couples', 
        queryParameters: {'serviceTypeId': serviceTypeId});
      
      if (response['success'] == true || response['couples'] != null) {
        final couplesData = response['couples'] ?? response['data'] ?? [];
        return (couplesData as List)
            .map((json) => ArticleServiceCouple.fromJson(json))
            .toList();
      }
      
      throw Exception(response['error'] ?? 'Erreur lors de la récupération des couples');
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  /// 💵 Calculer le prix pour un article/service/serviceType
  Future<double> calculatePrice({
    required String articleId,
    required String serviceId,
    required String serviceTypeId,
    bool isPremium = false,
    double? weight,
  }) async {
    try {
      // Récupérer tous les prix
      final prices = await getAllPrices();
      
      // Trouver le prix correspondant au trio article/service/serviceType
      final matchingPrice = prices.firstWhere(
        (price) =>
            price.articleId == articleId &&
            price.serviceId == serviceId &&
            price.serviceTypeId == serviceTypeId &&
            price.isAvailable,
        orElse: () => throw Exception('Prix non trouvé pour ce couple article-service'),
      );

      // Calculer le prix selon le type
      if (weight != null && matchingPrice.pricePerKg != null) {
        // Tarification au poids
        return matchingPrice.pricePerKg! * weight;
      } else {
        // Tarification fixe
        return matchingPrice.getPrice(isPremium: isPremium);
      }
    } catch (e) {
      throw Exception('Erreur de calcul du prix: ${e.toString()}');
    }
  }
}

/// 💰 Modèle Prix Article-Service
class ArticleServicePrice {
  final String id;
  final String articleId;
  final String serviceId;
  final String serviceTypeId;
  final String? articleName;
  final String? serviceName;
  final String? serviceTypeName;
  final double basePrice;
  final double? premiumPrice;
  final double? pricePerKg;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  ArticleServicePrice({
    required this.id,
    required this.articleId,
    required this.serviceId,
    required this.serviceTypeId,
    this.articleName,
    this.serviceName,
    this.serviceTypeName,
    required this.basePrice,
    this.premiumPrice,
    this.pricePerKg,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ArticleServicePrice.fromJson(Map<String, dynamic> json) {
    return ArticleServicePrice(
      id: json['id']?.toString() ?? '',
      articleId: json['article_id']?.toString() ?? json['articleId']?.toString() ?? '',
      serviceId: json['service_id']?.toString() ?? json['serviceId']?.toString() ?? '',
      serviceTypeId: json['service_type_id']?.toString() ?? json['serviceTypeId']?.toString() ?? '',
      // Noms - support de plusieurs formats
      articleName: json['article_name'] ?? json['articleName'] ?? json['article']?['name'],
      serviceName: json['service_name'] ?? json['serviceName'] ?? json['services']?['name'] ?? json['service']?['name'],
      serviceTypeName: json['service_type_name'] ?? json['serviceTypeName'] ?? json['service_types']?['name'] ?? json['serviceType']?['name'],
      basePrice: _parseDouble(json['base_price'] ?? json['basePrice'] ?? 0),
      premiumPrice: json['premium_price'] != null 
          ? _parseDouble(json['premium_price'])
          : (json['premiumPrice'] != null ? _parseDouble(json['premiumPrice']) : null),
      pricePerKg: json['price_per_kg'] != null 
          ? _parseDouble(json['price_per_kg'])
          : (json['pricePerKg'] != null ? _parseDouble(json['pricePerKg']) : null),
      isAvailable: json['is_available'] ?? json['isAvailable'] ?? true,
      createdAt: DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// Helper pour parser les valeurs en double (gère String et num)
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'article_id': articleId,
      'service_id': serviceId,
      'service_type_id': serviceTypeId,
      'article_name': articleName,
      'service_name': serviceName,
      'service_type_name': serviceTypeName,
      'base_price': basePrice,
      'premium_price': premiumPrice,
      'price_per_kg': pricePerKg,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Obtenir le prix selon le type (premium ou standard)
  double getPrice({bool isPremium = false}) {
    if (isPremium && premiumPrice != null) {
      return premiumPrice!;
    }
    return basePrice;
  }

  @override
  String toString() => 
      'ArticleServicePrice(article: $articleName, service: $serviceName, price: $basePrice)';
}

/// 🔗 Modèle Couple Article-Service
class ArticleServiceCouple {
  final String articleId;
  final String serviceId;
  final String serviceTypeId;
  final String articleName;
  final String serviceName;
  final String serviceTypeName;
  final double basePrice;
  final double? premiumPrice;
  final double? pricePerKg;
  final bool isAvailable;

  ArticleServiceCouple({
    required this.articleId,
    required this.serviceId,
    required this.serviceTypeId,
    required this.articleName,
    required this.serviceName,
    required this.serviceTypeName,
    required this.basePrice,
    this.premiumPrice,
    this.pricePerKg,
    required this.isAvailable,
  });

  factory ArticleServiceCouple.fromJson(Map<String, dynamic> json) {
    return ArticleServiceCouple(
      articleId: json['article_id']?.toString() ?? json['articleId']?.toString() ?? '',
      serviceId: json['service_id']?.toString() ?? json['serviceId']?.toString() ?? '',
      serviceTypeId: json['service_type_id']?.toString() ?? json['serviceTypeId']?.toString() ?? '',
      articleName: json['article_name'] ?? json['articleName'] ?? '',
      serviceName: json['service_name'] ?? json['serviceName'] ?? '',
      serviceTypeName: json['service_type_name'] ?? json['serviceTypeName'] ?? '',
      basePrice: ArticleServicePrice._parseDouble(json['base_price'] ?? json['basePrice'] ?? 0),
      premiumPrice: json['premium_price'] != null 
          ? ArticleServicePrice._parseDouble(json['premium_price'])
          : (json['premiumPrice'] != null ? ArticleServicePrice._parseDouble(json['premiumPrice']) : null),
      pricePerKg: json['price_per_kg'] != null 
          ? ArticleServicePrice._parseDouble(json['price_per_kg'])
          : (json['pricePerKg'] != null ? ArticleServicePrice._parseDouble(json['pricePerKg']) : null),
      isAvailable: json['is_available'] ?? json['isAvailable'] ?? true,
    );
  }

  @override
  String toString() => 
      'ArticleServiceCouple(article: $articleName, service: $serviceName, type: $serviceTypeName)';
}
