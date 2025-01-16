import 'package:shared_preferences.dart';
import 'dart:convert';
import 'package:prima/models/order.dart';

class OrderCacheService {
  final SharedPreferences _prefs;
  static const String _cacheKey = 'cached_orders';

  OrderCacheService(this._prefs);

  Future<void> cacheOrders(List<Order> orders) async {
    final ordersJson =
        orders.map((order) => jsonEncode(order.toJson())).toList();
    await _prefs.setStringList(_cacheKey, ordersJson);
  }

  List<Order> getCachedOrders() {
    final ordersJson = _prefs.getStringList(_cacheKey) ?? [];
    return ordersJson.map((json) => Order.fromJson(jsonDecode(json))).toList();
  }

  Future<void> clearCache() async {
    await _prefs.remove(_cacheKey);
  }
}
