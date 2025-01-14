import 'package:dio/dio.dart';
import '../models/order.dart';

class OrderService {
  final Dio _dio;

  OrderService(this._dio);

  Future<Order> createOrder({
    required String serviceId,
    required String addressId,
    required DateTime collectionDate,
    required DateTime deliveryDate,
    required List<Map<String, dynamic>> items,
    String? affiliateCode,
  }) async {
    try {
      final response = await _dio.post('/api/orders', data: {
        'serviceId': serviceId,
        'addressId': addressId,
        'collectionDate': collectionDate.toIso8601String(),
        'deliveryDate': deliveryDate.toIso8601String(),
        'items': items,
        'affiliateCode': affiliateCode,
      });

      if (response.statusCode == 201) {
        return Order.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to create order');
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  Future<double> calculateTotal({
    required String serviceId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await _dio.post('/api/orders/calculate', data: {
        'serviceId': serviceId,
        'items': items,
      });

      if (response.statusCode == 200) {
        return (response.data['data']['total'] as num).toDouble();
      }

      throw Exception(response.data['message'] ?? 'Failed to calculate total');
    } catch (e) {
      throw Exception('Error calculating total: $e');
    }
  }
}
