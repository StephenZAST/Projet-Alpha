import '../models/delivery_order.dart';
import './api_service.dart';

/// 🔍 Service de recherche de commandes par ID
/// 
/// Permet aux livreurs de rechercher rapidement une commande
/// en utilisant un extrait de son ID UUID
class DeliverySearchService {
  static final _api = ApiService();
  static const _baseUrl = '/orders';

  /// Recherche des commandes par extrait d'ID
  /// Minimum 4 caractères requis
  /// Exemples: "2c8e", "4033", "aeb3", "8acb98fe1d1c", "06657ef1"
  static Future<List<DeliveryOrder>> searchOrdersByIdFragment(
    String idFragment, {
    int limit = 10,
  }) async {
    try {
      // Valider l'extrait
      final fragment = idFragment.trim();
      if (fragment.length < 4) {
        return [];
      }

      print('[DeliverySearchService] Searching for order ID fragment: $fragment');

      final response = await _api.get(
        '$_baseUrl/search-by-id',
        queryParameters: {
          'idFragment': fragment,
          'limit': limit.toString(),
        },
      );

      print('[DeliverySearchService] Response status: ${response.statusCode}');
      print('[DeliverySearchService] Response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<DeliveryOrder> orders = (response.data['data'] as List)
            .map((json) => DeliveryOrder.fromJson(json))
            .toList();

        print('[DeliverySearchService] Found ${orders.length} orders');
        return orders;
      }

      print('[DeliverySearchService] No orders found or error in response');
      return [];
    } catch (e) {
      print('[DeliverySearchService] Error searching by ID fragment: $e');
      return [];
    }
  }
}
