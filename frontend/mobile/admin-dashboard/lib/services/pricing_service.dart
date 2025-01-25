import '../models/article.dart';
import './api_service.dart';

class PricingService {
  static final _api = ApiService();
  static const _basePath = '/pricing';

  /// Récupère tous les articles avec leurs prix
  static Future<List<Article>> getAllArticles() async {
    try {
      final response = await _api.get('/articles');
      if (response.data != null && response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((json) => Article.fromJson(json))
            .toList();
      }
      throw response.data?['message'] ??
          'Erreur lors du chargement des articles';
    } catch (e) {
      print('[PricingService] Error getting articles: $e');
      throw 'Erreur lors du chargement des articles';
    }
  }

  /// Calcule le total d'une commande avec réductions
  static Future<Map<String, dynamic>> calculateOrderTotal({
    required List<Map<String, dynamic>> items,
    required String userId,
    List<String>? appliedOfferIds,
  }) async {
    try {
      final response = await _api.post(
        '$_basePath/calculate',
        data: {
          'items': items
              .map((item) => {
                    'articleId': item['articleId'],
                    'quantity': item['quantity'],
                    'isPremium': item['isPremium'] ?? false,
                  })
              .toList(),
          'userId': userId,
          if (appliedOfferIds != null) 'appliedOfferIds': appliedOfferIds,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        return {
          'subtotal': (response.data['subtotal'] as num).toDouble(),
          'discounts': (response.data['discounts'] as List)
              .map((d) => {
                    'offerId': d['offerId'],
                    'amount': (d['amount'] as num).toDouble(),
                  })
              .toList(),
          'total': (response.data['total'] as num).toDouble(),
        };
      }
      throw response.data?['message'] ?? 'Erreur lors du calcul du total';
    } catch (e) {
      print('[PricingService] Error calculating total: $e');
      throw 'Erreur lors du calcul du total';
    }
  }

  /// Met à jour les prix d'un article
  static Future<void> updateArticlePrice(
    String articleId,
    double basePrice,
    double premiumPrice,
  ) async {
    try {
      final response = await _api.put(
        '$_basePath/articles/$articleId/price',
        data: {
          'basePrice': basePrice,
          'premiumPrice': premiumPrice,
        },
      );

      if (response.data != null && !response.data['success']) {
        throw response.data?['message'] ??
            'Erreur lors de la mise à jour du prix';
      }
    } catch (e) {
      print('[PricingService] Error updating article price: $e');
      throw 'Erreur lors de la mise à jour du prix';
    }
  }

  /// Récupère l'historique des prix d'un article
  static Future<List<Map<String, dynamic>>> getArticlePriceHistory(
    String articleId,
  ) async {
    try {
      final response = await _api.get('$_basePath/articles/$articleId/history');

      if (response.data != null && response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((h) => {
                  'basePrice': (h['base_price'] as num).toDouble(),
                  'premiumPrice': (h['premium_price'] as num).toDouble(),
                  'validFrom': DateTime.parse(h['valid_from']),
                  'validTo': h['valid_to'] != null
                      ? DateTime.parse(h['valid_to'])
                      : null,
                })
            .toList();
      }
      throw response.data?['message'] ??
          'Erreur lors du chargement de l\'historique';
    } catch (e) {
      print('[PricingService] Error getting price history: $e');
      throw 'Erreur lors du chargement de l\'historique';
    }
  }
}
