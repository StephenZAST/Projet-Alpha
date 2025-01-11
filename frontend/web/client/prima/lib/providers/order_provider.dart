import 'package:flutter/material.dart';
import 'package:prima/models/order.dart'
    hide OrderItem; // Cacher OrderItem de order.dart
import 'package:prima/models/order_item.dart'
    as order_item; // Utiliser un préfixe pour order_item.dart
import 'package:prima/services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService;
  bool _isLoading = false;
  String? _error;
  Order? _currentOrder;

  OrderProvider(this._orderService);

  bool get isLoading => _isLoading;
  String? get error => _error;
  Order? get currentOrder => _currentOrder;

  Future<void> createOrder({
    required String serviceId,
    required String addressId,
    required DateTime collectionDate,
    required DateTime deliveryDate,
    required List<Map<String, dynamic>> items,
    String? affiliateCode,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Convertir les Map en OrderItem avec le préfixe
      final orderItems = items
          .map((item) => order_item.OrderItem(
                id: '',
                orderId: '',
                articleId: item['articleId'] as String,
                serviceId: item['serviceId'] as String,
                quantity: item['quantity'] as int,
                unitPrice: (item['unitPrice'] as num).toDouble(),
              ))
          .toList();

      _currentOrder = await _orderService.createOrder(
        serviceId: serviceId,
        addressId: addressId,
        collectionDate: collectionDate,
        deliveryDate: deliveryDate,
        items: orderItems,
        affiliateCode: affiliateCode,
      );

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
