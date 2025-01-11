import 'package:dio/dio.dart';
import 'package:prima/models/order.dart';

class OrderService {
  final Dio _dio;

  OrderService(this._dio);

  Future<Order> createOrder({
    required String serviceId,
    required String addressId,
    required DateTime collectionDate,
    required DateTime deliveryDate,
    required List<OrderItem> items,
    String? affiliateCode,
  }) async {
    try {
      final response = await _dio.post('/api/orders', data: {
        'serviceId': serviceId,
        'addressId': addressId,
        'collectionDate': collectionDate.toIso8601String(),
        'deliveryDate': deliveryDate.toIso8601String(),
        'items': items
            .map((item) => ({
                  'articleId': item.articleId,
                  'quantity': item.quantity,
                }))
            .toList(),
        'affiliateCode': affiliateCode,
      });

      if (response.statusCode == 200) {
        final orderData = response.data['data'];
        return Order.fromJson(orderData);
      }

      throw Exception('Failed to create order: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  Future<double> calculateTotal({
    required String serviceId,
    required List<OrderItem> items,
  }) async {
    try {
      final response = await _dio.post('/api/orders/calculate-total', data: {
        'serviceId': serviceId,
        'items': items
            .map((item) => ({
                  'articleId': item.articleId,
                  'quantity': item.quantity,
                }))
            .toList(),
      });

      if (response.statusCode == 200) {
        return (response.data['data']['total'] as num).toDouble();
      }

      throw Exception('Failed to calculate total');
    } catch (e) {
      throw Exception('Error calculating total: $e');
    }
  }
}
