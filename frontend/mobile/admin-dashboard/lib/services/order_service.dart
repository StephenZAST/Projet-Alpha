import '../models/order.dart';
import '../models/orders_page_data.dart';
import 'api_service.dart';

class OrderService {
  static final _api = ApiService();
  static const String _basePath = '/orders';

  /// Récupère toutes les commandes (méthode existante pour compatibilité)
  static Future<List<Order>> getOrders() async {
    try {
      final result =
          await loadOrdersPage(limit: 1000); // Charge toutes les commandes
      return result.orders;
    } catch (e) {
      print('[OrderService] Error getting all orders: $e');
      throw 'Erreur lors du chargement des commandes';
    }
  }

  /// Charge une page de commandes avec pagination et filtres
  /// @param page Le numéro de la page à récupérer (commence à 1)
  /// @param limit Le nombre maximum de commandes par page
  /// @param status Filtre optionnel sur le statut des commandes
  /// @param startDate Filtre optionnel sur la date de début
  /// @param endDate Filtre optionnel sur la date de fin
  static Future<OrdersPageData> loadOrdersPage({
    int page = 1,
    int limit = 50,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print(
          '[OrderService] Fetching orders with params: page=$page, limit=$limit, status=$status');
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (status != null) {
        queryParams['status'] = status;
      }
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response =
          await _api.get('/admin/orders', queryParameters: queryParams);
      print('[OrderService] Response received: ${response.data}');

      if (response.data != null) {
        return OrdersPageData(
          orders: (response.data['data'] as List)
              .map((json) => Order.fromJson(json))
              .toList(),
          total: response.data['pagination']['total'] as int,
          currentPage: page,
          limit: limit,
          totalPages: response.data['pagination']['totalPages'] as int,
        );
      }

      print('[OrderService] No orders data found');
      return OrdersPageData.empty();
    } catch (e) {
      print('[OrderService] Error getting orders: $e');
      throw 'Erreur lors du chargement des commandes. Détails : $e';
    }
  }

  static Future<Order> getOrderById(String id) async {
    try {
      print('[OrderService] Fetching order details for ID: $id');
      final response = await _api.get('$_basePath/$id');
      if (response.data != null && response.data['data'] != null) {
        return Order.fromJson(response.data['data']);
      }
      throw 'Commande non trouvée';
    } catch (e) {
      print('[OrderService] Error getting order by id: $e');
      throw 'Erreur lors du chargement de la commande';
    }
  }

  static Future<List<Order>> getRecentOrders({int limit = 5}) async {
    try {
      print('[OrderService] Fetching recent orders with limit: $limit');
      final response = await _api.get(
        '$_basePath/recent',
        queryParameters: {'limit': limit},
      );
      print('[OrderService] Recent orders response: ${response.data}');

      if (response.data != null && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Order.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('[OrderService] Error getting recent orders: $e');
      throw 'Erreur lors du chargement des commandes récentes';
    }
  }

  static Future<Map<String, int>> getOrdersByStatus() async {
    try {
      print('[OrderService] Fetching orders by status');
      final response = await _api.get('$_basePath/by-status');
      print('[OrderService] Orders by status response: ${response.data}');

      if (response.data != null && response.data['data'] != null) {
        final Map<String, dynamic> data = response.data['data'];
        return data.map((key, value) => MapEntry(key, (value as num).toInt()));
      }
      return {};
    } catch (e) {
      print('[OrderService] Error getting orders by status: $e');
      throw 'Erreur lors du chargement des statistiques';
    }
  }

  // Map des transitions de statut valides
  static final Map<String, List<String>> validTransitions = {
    'PENDING': ['COLLECTING'],
    'COLLECTING': ['COLLECTED'],
    'COLLECTED': ['PROCESSING'],
    'PROCESSING': ['READY'],
    'READY': ['DELIVERING'],
    'DELIVERING': ['DELIVERED'],
    'DELIVERED': [],
    'CANCELLED': []
  };

  // Vérifier si une transition est valide
  static bool isValidTransition(String currentStatus, String newStatus) {
    final validNextStatuses = validTransitions[currentStatus] ?? [];
    return validNextStatuses.contains(newStatus);
  }

  static Future<void> updateOrderStatus(
      String orderId, String newStatus) async {
    try {
      print('[OrderService] Updating order status: $orderId to $newStatus');

      // Obtenir d'abord les détails de la commande pour vérifier le statut actuel
      final order = await getOrderById(orderId);

      // Vérifier si la transition est valide
      if (!isValidTransition(order.status, newStatus)) {
        throw 'Transition de statut invalide : ${order.status} -> $newStatus n\'est pas autorisé';
      }

      final response = await _api.patch(
        '$_basePath/$orderId/status',
        data: {'status': newStatus},
      );

      if (response.statusCode == 401) {
        print('[OrderService] Authorization error updating status');
        throw 'Session expirée. Veuillez vous reconnecter.';
      }

      if (response.statusCode == 403) {
        print('[OrderService] Permission denied updating status');
        throw 'Vous n\'avez pas les permissions nécessaires pour cette action.';
      }

      if (response.statusCode! >= 400) {
        print('[OrderService] Error response: ${response.data}');
        final message = response.data?['error'] ??
            response.data?['message'] ??
            'Erreur lors de la mise à jour du statut';
        throw message;
      }

      print('[OrderService] Order status updated successfully');
    } catch (e) {
      print('[OrderService] Error updating order status: $e');
      if (e is String) {
        throw e; // Propager les messages d'erreur personnalisés
      }
      throw 'Erreur lors de la mise à jour du statut : ${e.toString()}';
    }
  }

  static Future<Order> createOrder(Map<String, dynamic> orderData) async {
    try {
      print('[OrderService] Creating new order with data: $orderData');
      final response = await _api.post(
        '$_basePath/create-order',
        data: orderData,
      );
      print('[OrderService] Create order response: ${response.data}');

      if (response.data != null && response.data['data'] != null) {
        return Order.fromJson(response.data['data']);
      }
      throw 'Erreur lors de la création de la commande';
    } catch (e) {
      print('[OrderService] Error creating order: $e');
      throw 'Erreur lors de la création de la commande';
    }
  }

  static Future<void> updateOrder(
      String orderId, Map<String, dynamic> orderData) async {
    try {
      print('[OrderService] Updating order: $orderId with data: $orderData');
      final response = await _api.put(
        '$_basePath/$orderId',
        data: orderData,
      );

      if (response.statusCode == 401) {
        throw 'Session expirée. Veuillez vous reconnecter.';
      }

      if (response.statusCode == 403) {
        throw 'Vous n\'avez pas les permissions nécessaires pour cette action.';
      }

      if (response.statusCode! >= 400) {
        final message = response.data?['error'] ??
            response.data?['message'] ??
            'Erreur lors de la mise à jour de la commande';
        throw message;
      }

      print('[OrderService] Order updated successfully');
    } catch (e) {
      print('[OrderService] Error updating order: $e');
      if (e is String) {
        throw e;
      }
      throw 'Erreur lors de la mise à jour de la commande : ${e.toString()}';
    }
  }

  static Future<void> deleteOrder(String orderId) async {
    try {
      print('[OrderService] Deleting order: $orderId');
      await _api.delete('$_basePath/$orderId');
      print('[OrderService] Order deleted successfully');
    } catch (e) {
      print('[OrderService] Error deleting order: $e');
      throw 'Erreur lors de la suppression de la commande';
    }
  }

  static Future<List<Order>> searchOrders(String query) async {
    try {
      print('[OrderService] Searching orders with query: $query');
      final allOrders = await getOrders();
      if (query.isEmpty) return allOrders;

      return allOrders.where((order) {
        final searchStr = query.toLowerCase();
        final id = order.id.toLowerCase();
        final status = order.status.toLowerCase();
        final customerName = order.customerName?.toLowerCase() ?? '';

        return id.contains(searchStr) ||
            status.contains(searchStr) ||
            customerName.contains(searchStr);
      }).toList();
    } catch (e) {
      print('[OrderService] Error searching orders: $e');
      throw 'Erreur lors de la recherche';
    }
  }

  static Future<Map<String, dynamic>> getOrderStatistics() async {
    try {
      print('[OrderService] Fetching order statistics');
      final statusData = await getOrdersByStatus();
      final total = statusData.values.fold<int>(0, (sum, count) => sum + count);

      final result = {
        'byStatus': statusData,
        'total': total,
        'percentages': statusData.map((status, count) => MapEntry(status,
            total > 0 ? (count / total * 100).toStringAsFixed(1) : '0')),
      };

      print('[OrderService] Order statistics: $result');
      return result;
    } catch (e) {
      print('[OrderService] Error getting order statistics: $e');
      throw 'Erreur lors du chargement des statistiques';
    }
  }
}
