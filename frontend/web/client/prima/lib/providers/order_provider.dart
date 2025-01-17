import 'package:flutter/material.dart';
import 'package:prima/models/order.dart';
import 'package:prima/models/order_status.dart';
import 'package:prima/providers/loyalty_provider.dart';
import 'package:prima/services/order_service.dart';
import 'package:prima/managers/order_status_manager.dart';
import 'dart:async';
import 'package:prima/models/payment.dart';

import 'package:prima/services/websocket_service.dart';
import 'package:prima/widgets/order/recurrence_selection.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService;
  final WebSocketService _webSocketService;

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  OrderStatus? _selectedFilter;
  int _currentPage = 1;
  static const int _perPage = 10;
  bool _hasMore = true;
  bool _isFirstLoad = true;
  StreamSubscription? _orderUpdateSubscription;

  OrderProvider(this._orderService, this._webSocketService) {
    _initializeWebSocket();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  OrderStatus? get selectedFilter => _selectedFilter;
  List<OrderStatus> get availableStatuses => OrderStatus.values;

  Map<OrderStatus, List<Order>> get ordersByStatus {
    final map = <OrderStatus, List<Order>>{};
    for (final status in OrderStatus.values) {
      map[status] = _orders
          .where((order) =>
              OrderStatus.values.firstWhere((e) => e.name == order.status) ==
              status)
          .toList();
    }
    return map;
  }

  List<Order> get filteredOrders {
    if (_selectedFilter == null) return _orders;
    return _orders
        .where((order) =>
            OrderStatus.values.firstWhere((e) => e.name == order.status) ==
            _selectedFilter)
        .toList();
  }

  List<Order> get recentOrders {
    final sorted = List<Order>.from(_orders)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(3).toList();
  }

  bool get hasMore => _hasMore;
  bool get isFirstLoad => _isFirstLoad;

  Future<void> loadOrders({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _orders.clear();
    }

    if (!_hasMore || _isLoading) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newOrders = await _orderService.getOrders(
        page: _currentPage,
        perPage: _perPage,
        status: _selectedFilter,
      );

      if (refresh) {
        _orders = newOrders;
      } else {
        _orders.addAll(newOrders);
      }

      _hasMore = newOrders.length >= _perPage;
      _currentPage++;
      _isFirstLoad = false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshOrders() async {
    return loadOrders(refresh: true);
  }

  void setStatusFilter(OrderStatus? status) {
    if (_selectedFilter == status) return;
    _selectedFilter = status;
    loadOrders(refresh: true);
  }

  void _initializeWebSocket() {
    _orderUpdateSubscription = _webSocketService.orderUpdates.listen((data) {
      if (data['type'] == 'ORDER_UPDATE') {
        _handleOrderUpdate(data['order']);
      }
    });
  }

  void _handleOrderUpdate(Map<String, dynamic> orderData) {
    final updatedOrder = Order.fromJson(orderData);
    final index = _orders.indexWhere((order) => order.id == updatedOrder.id);

    if (index != -1) {
      _orders[index] = updatedOrder;
      notifyListeners();
    }
  }

  Future<void> completeOrder(String orderId) async {
    try {
      final order = await _orderService.completeOrder(orderId);
      // Mettre à jour les points via LoyaltyProvider
      if (order.status == 'DELIVERED') {
        final points = (order.totalAmount * 10).floor(); // 1 point pour 0.1€
        await context.read<LoyaltyProvider>().earnPoints(
              points,
              'ORDER',
              orderId,
            );
      }
      notifyListeners();
    } catch (e) {
      print('Error completing order: $e');
      rethrow;
    }
  }

  Future<Order> createOrder({
    required String serviceId,
    required String addressId,
    required DateTime collectionDate,
    required DateTime deliveryDate,
    required List<Map<String, dynamic>> items,
    TimeOfDay? collectionTime,
    TimeOfDay? deliveryTime,
    required bool isRecurring,
    required RecurrenceType recurrenceType,
    required PaymentMethod paymentMethod,
  }) async {
    try {
      final order = await _orderService.createOrder(
        serviceId: serviceId,
        addressId: addressId,
        collectionDate: collectionDate,
        deliveryDate: deliveryDate,
        items: items,
        collectionTime: collectionTime,
        deliveryTime: deliveryTime,
        isRecurring: isRecurring,
        recurrenceType: recurrenceType,
        paymentMethod: paymentMethod,
      );

      await loadOrders(refresh: true);
      return order;
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _orderUpdateSubscription?.cancel();
    super.dispose();
  }
}
