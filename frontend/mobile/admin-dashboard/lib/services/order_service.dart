import '../models/order.dart';
import 'api_service.dart';

class OrderService {
  static Future<List<Order>> getOrders({String? status}) async {
    final queryParams = {
      if (status != null) 'status': status,
    };

    final response =
        await ApiService.get('orders?${Uri(queryParameters: queryParams)}');
    return (response['data'] as List)
        .map((item) => Order.fromJson(item))
        .toList();
  }

  static Future<Order> getOrderDetails(String orderId) async {
    final response = await ApiService.get('orders/$orderId');
    return Order.fromJson(response['data']);
  }

  static Future<void> updateOrderStatus(String orderId, String status) async {
    await ApiService.post('orders/$orderId/status', {'status': status});
  }

  static Future<List<Map<String, dynamic>>> getRecentOrders() async {
    final response = await ApiService.get('orders/recent');
    return List<Map<String, dynamic>>.from(response['data']);
  }

  static Future<Map<String, int>> getOrdersByStatus() async {
    final response = await ApiService.get('orders/by-status');
    return Map<String, int>.from(response['data']);
  }

  static int getOrderCountByStatus(String status, List<Order> orders) {
    return orders.where((order) => order.status == status).length;
  }

  static double getOrderPercentageByStatus(String status, List<Order> orders) {
    if (orders.isEmpty) return 0;
    return (getOrderCountByStatus(status, orders) / orders.length) * 100;
  }
}
