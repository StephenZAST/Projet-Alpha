import 'api_service.dart';

/// Service pour la gestion des prix manuels et du paiement des commandes
/// Endpoints: GET/PATCH /orders/:orderId/pricing, DELETE/POST mark-paid/mark-unpaid
class OrderPricingService {
  static final _api = ApiService();
  static const String _baseUrl = '/orders';

  /// Normalise un nombre depuis n'importe quel type
  static double _normalizeNumber(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Normalise la réponse pricing du backend
  static Map<String, dynamic> _normalizePricingResponse(
    dynamic rawData,
    String orderId,
  ) {
    if (rawData == null) return {};

    final data = Map<String, dynamic>.from(rawData);

    return {
      'orderId': data['orderId'] ?? data['order_id'] ?? orderId,
      'originalPrice':
          _normalizeNumber(data['originalPrice'] ?? data['original_price']),
      'manualPrice': data['manualPrice'] != null
          ? _normalizeNumber(data['manualPrice'])
          : null,
      'displayPrice':
          _normalizeNumber(data['displayPrice'] ?? data['display_price']),
      'discount': data['discount'] != null ? _normalizeNumber(data['discount']) : null,
      'discountPercentage': data['discountPercentage'] != null
          ? _normalizeNumber(data['discountPercentage'])
          : null,
      'isPaid': data['isPaid'] == true || data['is_paid'] == true,
      'paidAt': data['paidAt'] ?? data['paid_at'],
      'reason': data['reason'],
      'updatedAt': data['updatedAt'] ?? data['updated_at'],
    };
  }

  /// GET /orders/:orderId/pricing
  /// Récupère les informations de prix et paiement d'une commande
  static Future<Map<String, dynamic>> getOrderPricing(String orderId) async {
    try {
      print('[OrderPricingService] Fetching pricing for order: $orderId');
      final response = await _api.get('$_baseUrl/$orderId/pricing');

      if (response.data == null) {
        throw 'Réponse invalide du serveur';
      }

      // Le backend peut renvoyer les données au niveau racine ou dans data
      final data = response.data['data'] ?? response.data;
      if (data == null) throw 'Données pricing manquantes';

      final pricing = _normalizePricingResponse(data, orderId);
      print('[OrderPricingService] Pricing fetched: $pricing');
      return pricing;
    } catch (e) {
      print('[OrderPricingService] Error getOrderPricing: $e');
      rethrow;
    }
  }

  /// PATCH /orders/:orderId/pricing
  /// Met à jour le prix manuel et/ou le statut de paiement
  static Future<Map<String, dynamic>> updateOrderPricing(
    String orderId, {
    double? manualPrice,
    bool? isPaid,
    String? reason,
  }) async {
    try {
      print('[OrderPricingService] Updating pricing for order: $orderId');
      final payload = <String, dynamic>{};

      if (manualPrice != null) {
        payload['manual_price'] = manualPrice;
      }
      if (isPaid != null) {
        payload['is_paid'] = isPaid;
      }
      if (reason != null && reason.isNotEmpty) {
        payload['reason'] = reason;
      }

      print('[OrderPricingService] Pricing update payload: $payload');
      final response =
          await _api.patch('$_baseUrl/$orderId/pricing', data: payload);

      if (response.data == null) {
        throw 'Réponse invalide du serveur';
      }

      final data = response.data['data'] ?? response.data;
      if (data == null) throw 'Données pricing manquantes après mise à jour';

      final updatedPricing = _normalizePricingResponse(data, orderId);
      print('[OrderPricingService] Pricing updated: $updatedPricing');
      return updatedPricing;
    } catch (e) {
      print('[OrderPricingService] Error updateOrderPricing: $e');
      rethrow;
    }
  }

  /// DELETE /orders/:orderId/pricing/manual-price
  /// Réinitialise le prix manuel (revient au prix original)
  static Future<void> resetManualPrice(String orderId) async {
    try {
      print('[OrderPricingService] Resetting manual price for order: $orderId');
      final response =
          await _api.delete('$_baseUrl/$orderId/pricing/manual-price');

      if ((response.statusCode ?? 200) >= 400) {
        throw response.data?['error'] ??
            'Erreur lors de la réinitialisation du prix manuel';
      }

      print('[OrderPricingService] Manual price reset successfully');
    } catch (e) {
      print('[OrderPricingService] Error resetManualPrice: $e');
      rethrow;
    }
  }

  /// POST /orders/:orderId/pricing/mark-paid
  /// Marque une commande comme payée
  static Future<void> markOrderPaid(String orderId, {String? reason}) async {
    try {
      print('[OrderPricingService] Marking order as paid: $orderId');
      final payload = <String, dynamic>{};

      if (reason != null && reason.isNotEmpty) {
        payload['reason'] = reason;
      }

      final response = await _api.post('$_baseUrl/$orderId/pricing/mark-paid',
          data: payload);

      if ((response.statusCode ?? 200) >= 400) {
        throw response.data?['error'] ?? 'Erreur lors du marquage payé';
      }

      print('[OrderPricingService] Order marked as paid successfully');
    } catch (e) {
      print('[OrderPricingService] Error markOrderPaid: $e');
      rethrow;
    }
  }

  /// POST /orders/:orderId/pricing/mark-unpaid
  /// Marque une commande comme non payée
  static Future<void> markOrderUnpaid(String orderId, {String? reason}) async {
    try {
      print('[OrderPricingService] Marking order as unpaid: $orderId');
      final payload = <String, dynamic>{};

      if (reason != null && reason.isNotEmpty) {
        payload['reason'] = reason;
      }

      final response = await _api.post('$_baseUrl/$orderId/pricing/mark-unpaid',
          data: payload);

      if ((response.statusCode ?? 200) >= 400) {
        throw response.data?['error'] ?? 'Erreur lors du marquage non payé';
      }

      print('[OrderPricingService] Order marked as unpaid successfully');
    } catch (e) {
      print('[OrderPricingService] Error markOrderUnpaid: $e');
      rethrow;
    }
  }
}
