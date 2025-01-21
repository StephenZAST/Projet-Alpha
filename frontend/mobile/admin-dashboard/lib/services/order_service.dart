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
}
