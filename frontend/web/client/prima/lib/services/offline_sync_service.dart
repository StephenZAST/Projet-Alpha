import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:prima/services/order_cache_service.dart';
import 'package:prima/services/order_service.dart';

class OfflineSyncService {
  final OrderService _orderService;
  final OrderCacheService _cacheService;
  bool _isSyncing = false;

  OfflineSyncService(this._orderService, this._cacheService) {
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        syncOrders();
      }
    });
  }

  Future<void> syncOrders() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      // Synchroniser les données locales avec le serveur
      final orders = await _orderService.getUserOrders();
      await _cacheService.cacheOrders(orders);
    } finally {
      _isSyncing = false;
    }
  }
}
