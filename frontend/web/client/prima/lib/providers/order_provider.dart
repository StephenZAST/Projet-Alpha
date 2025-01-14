import 'package:flutter/material.dart';
import 'package:prima/models/order.dart';
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

      _currentOrder = await _orderService.createOrder(
        serviceId: serviceId,
        addressId: addressId,
        collectionDate: collectionDate,
        deliveryDate: deliveryDate,
        items: items,
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

  Future<double> calculateTotal({
    required String serviceId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      return await _orderService.calculateTotal(
        serviceId: serviceId,
        items: items,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
