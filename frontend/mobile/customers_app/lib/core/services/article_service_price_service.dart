import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_service_price.dart';
import '../models/service_type.dart';
import '../models/service.dart';
import '../models/article.dart';
import '../utils/storage_service.dart';
import '../../constants.dart';

/// 🔗 Service Article-Service-Price - Alpha Client App
///
/// Gère les couples article-service avec leurs prix selon le workflow :
/// ServiceType → Service → ArticleServicePrice (avec prix basic/premium)
/// Référence: backend/docs/REFERENCE_ARTICLE_SERVICE.md
class ArticleServicePriceService {
  static const String _baseUrl = ApiConfig.baseUrl;

  /// 📋 Récupérer tous les types de service actifs
  /// Endpoint: GET /api/service-types
  Future<List<ServiceType>> getServiceTypes() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/service-types'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final serviceTypes = (data['data'] as List? ?? data as List)
            .map((json) => ServiceType.fromJson(json))
            .where((st) => st.isActive) // Filtrer seulement les actifs
            .toList();
        
        return serviceTypes;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Erreur lors de la récupération des types de service');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  /// 🛠️ Récupérer les services par type de service
  /// Endpoint: GET /api/services/all (filtré côté client)
  Future<List<Service>> getServicesByType(String serviceTypeId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/services/all'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final services = (data['data'] as List? ?? data as List)
            .map((json) => Service.fromJson(json))
            .where((service) => 
                service.serviceTypeId == serviceTypeId && 
                service.isActive) // Filtrer par type et actifs seulement
            .toList();
        
        return services;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Erreur lors de la récupération des services');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  /// 🔗 Récupérer les couples article-service-price
  /// Endpoint: GET /api/article-services/couples
  Future<List<ArticleServicePrice>> getArticleServiceCouples({
    String? serviceTypeId,
    String? serviceId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (serviceTypeId != null) queryParams['serviceTypeId'] = serviceTypeId;
      if (serviceId != null) queryParams['serviceId'] = serviceId;

      final uri = Uri.parse('$_baseUrl/api/article-services/couples').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final couples = (data['data'] as List? ?? data as List)
            .map((json) => ArticleServicePrice.fromJson(json))
            .where((couple) => couple.isAvailable) // Seulement les disponibles
            .toList();
        
        return couples;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Erreur lors de la récupération des couples');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  /// 💰 Calculer le prix d'un couple
  /// Endpoint: GET /api/article-services/prices (filtré par article et service)
  Future<ArticleServicePrice?> getSpecificPrice({
    required String articleId,
    required String serviceId,
    required String serviceTypeId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/article-services/prices'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prices = (data['data'] as List? ?? data as List)
            .map((json) => ArticleServicePrice.fromJson(json))
            .where((price) => 
                price.articleId == articleId &&
                price.serviceId == serviceId &&
                price.serviceTypeId == serviceTypeId &&
                price.isAvailable)
            .toList();
        
        return prices.isNotEmpty ? prices.first : null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// 📊 Récupérer les prix d'un article spécifique
  /// Endpoint: GET /api/article-services/:articleId/prices
  Future<List<ArticleServicePrice>> getArticlePrices(String articleId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/article-services/$articleId/prices'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prices = (data['data'] as List? ?? data as List)
            .map((json) => ArticleServicePrice.fromJson(json))
            .where((price) => price.isAvailable)
            .toList();
        
        return prices;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Erreur lors de la récupération des prix');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  /// 🧮 Calculer le prix total d'une commande
  /// Endpoint: POST /api/services/calculate-price
  Future<double> calculateOrderPrice({
    required List<OrderItem> items,
    bool isPremium = false,
  }) async {
    try {
      final token = await StorageService.getToken();
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/services/calculate-price'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'items': items.map((item) => item.toJson()).toList(),
          'isPremium': isPremium,
        }),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Erreur lors du calcul du prix');
      }
    } catch (e) {
      throw Exception('Erreur de calcul: ${e.toString()}');
    }
  }

  /// 📋 Récupérer tous les articles disponibles
  /// Endpoint: GET /api/articles
  Future<List<Article>> getArticles() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/articles'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final articles = (data['data'] as List? ?? data as List)
            .map((json) => Article.fromJson(json))
            .where((article) => article.isActive) // Seulement les actifs
            .toList();
        
        return articles;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Erreur lors de la récupération des articles');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }
}

/// 📦 Item de commande pour le calcul de prix
class OrderItem {
  final String articleId;
  final String serviceId;
  final String serviceTypeId;
  final int quantity;
  final double? weight;
  final bool isPremium;

  OrderItem({
    required this.articleId,
    required this.serviceId,
    required this.serviceTypeId,
    required this.quantity,
    this.weight,
    this.isPremium = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'articleId': articleId,
      'serviceId': serviceId,
      'serviceTypeId': serviceTypeId,
      'quantity': quantity,
      'weight': weight,
      'isPremium': isPremium,
    };
  }
}