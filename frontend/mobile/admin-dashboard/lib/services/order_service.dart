import '../models/order.dart';
import 'api_service.dart';

class OrderService {
  static final _api = ApiService();
  static const String _basePath = '/orders';

  static Future<List<Order>> getOrders() async {
    try {
      // Route spécifique pour les admins, protégée par authorizeRoles(['ADMIN'])
      final response = await _api.get('$_basePath/all-orders');
      if (response.data != null && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Order.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('[OrderService] Error getting orders: $e');
      throw 'Erreur lors du chargement des commandes';
    }
  }

  static Future<Order> getOrderById(String id) async {
    try {
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
      final response = await _api.get(
        '$_basePath/recent',
        queryParameters: {'limit': limit},
      );
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
      final response = await _api.get('$_basePath/by-status');
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

  static Future<void> updateOrderStatus(
      String orderId, String newStatus) async {
    try {
      await _api.patch(
        '$_basePath/$orderId/status',
        data: {'status': newStatus},
      );
    } catch (e) {
      print('[OrderService] Error updating order status: $e');
      throw 'Erreur lors de la mise à jour du statut';
    }
  }

  static Future<Order> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _api.post(
        '$_basePath/create-order',
        data: orderData,
      );
      if (response.data != null && response.data['data'] != null) {
        return Order.fromJson(response.data['data']);
      }
      throw 'Erreur lors de la création de la commande';
    } catch (e) {
      print('[OrderService] Error creating order: $e');
      throw 'Erreur lors de la création de la commande';
    }
  }

  static Future<void> deleteOrder(String orderId) async {
    try {
      await _api.delete('$_basePath/$orderId');
    } catch (e) {
      print('[OrderService] Error deleting order: $e');
      throw 'Erreur lors de la suppression de la commande';
    }
  }

  static Future<List<Order>> searchOrders(String query) async {
    try {
      // En attendant l'implémentation backend, on filtre les commandes côté client
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
      final statusData = await getOrdersByStatus();
      final total = statusData.values.fold<int>(0, (sum, count) => sum + count);

      return {
        'byStatus': statusData,
        'total': total,
        'percentages': statusData.map((status, count) => MapEntry(status,
            total > 0 ? (count / total * 100).toStringAsFixed(1) : '0')),
      };
    } catch (e) {
      print('[OrderService] Error getting order statistics: $e');
      throw 'Erreur lors du chargement des statistiques';
    }
  }
}
