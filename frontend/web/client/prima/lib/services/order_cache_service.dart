import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/order.dart';

class OrderCacheService {
  final SharedPreferences _prefs;
  static const String _cacheKey = 'cached_orders';

  OrderCacheService(this._prefs);

  Future<void> cacheOrders(List<Order> orders) async {
    try {
      final ordersJson =
          orders.map((order) => jsonEncode(order.toJson())).toList();
      await _prefs.setStringList(_cacheKey, ordersJson);
    } catch (e) {
      print('Error caching orders: $e');
    }
  }

  List<Order>? getCachedOrders() {
    try {
      final ordersJson = _prefs.getStringList(_cacheKey);
      if (ordersJson == null) return null;

      return ordersJson
          .map((json) => Order.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error getting cached orders: $e');
      return null;
    }
  }

  Future<void> clearCache() async {
    try {
      await _prefs.remove(_cacheKey);
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
