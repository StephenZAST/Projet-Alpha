import 'package:flutter/material.dart';
import '../core/models/order.dart';
import '../core/services/order_service.dart';

/// 📦 Provider de Gestion des Commandes - Alpha Client App
///
/// Gère l'état global des commandes avec système de cache optimisé
class OrdersProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  // État des commandes
  List<Order> _orders = [];
  Order? _selectedOrder;
  Map<String, int> _ordersByStatus = {};

  // États de chargement
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isRefreshing = false;
  String? _error;

  // 🔥 Cache Management
  DateTime? _lastFetch;
  bool _isInitialized = false;
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Filtres
  OrderStatus? _filterStatus;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  String? _searchQuery;

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalOrders = 0;
  bool _hasMore = true;
  static const int _pageSize = 20;

  // Getters
  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  Map<String, int> get ordersByStatus => _ordersByStatus;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  bool get hasOrders => _orders.isNotEmpty;
  int get totalOrders => _totalOrders;
  bool get hasMore => _hasMore;
  
  // Alias pour compatibilité avec anciens fichiers
  bool get isLoadingOrders => _isLoading;
  bool get isLoadingOrderDetails => _isLoading;
  bool get hasMoreOrders => _hasMore;
  Map<String, dynamic> get ordersStats => statistics;

  // Filtres getters
  OrderStatus? get filterStatus => _filterStatus;
  DateTime? get filterStartDate => _filterStartDate;
  DateTime? get filterEndDate => _filterEndDate;
  String? get searchQuery => _searchQuery;

  // 🔥 Cache Getters
  bool get isInitialized => _isInitialized;
  DateTime? get lastFetch => _lastFetch;

  bool get _shouldRefresh {
    if (_lastFetch == null) return true;
    final difference = DateTime.now().difference(_lastFetch!);
    return difference > _cacheDuration;
  }

  String get cacheStatus {
    if (_lastFetch == null) return 'Aucune donnee';
    final difference = DateTime.now().difference(_lastFetch!);
    final minutes = difference.inMinutes;
    if (minutes < 1) return 'A l\'instant';
    if (minutes == 1) return 'Il y a 1 minute';
    return 'Il y a $minutes minutes';
  }

  // Getters calculés
  List<Order> get pendingOrders =>
      _orders.where((o) => o.status == OrderStatus.pending).toList();

  List<Order> get activeOrders => _orders
      .where((o) =>
          o.status != OrderStatus.delivered &&
          o.status != OrderStatus.cancelled)
      .toList();

  List<Order> get completedOrders =>
      _orders.where((o) => o.status == OrderStatus.delivered).toList();

  List<Order> get cancelledOrders =>
      _orders.where((o) => o.status == OrderStatus.cancelled).toList();

  int get activeOrdersCount => activeOrders.length;
  int get completedOrdersCount => completedOrders.length;

  /// 🚀 Initialiser le provider avec système de cache
  Future<void> initialize({bool forceRefresh = false}) async {
    // 🔥 Vérifier le cache avant de charger
    if (_isInitialized && !forceRefresh && !_shouldRefresh && hasOrders) {
      debugPrint('OK [OrdersProvider] Cache valide - Pas de rechargement');
      debugPrint('INFO [OrdersProvider] Derniere mise a jour: $cacheStatus');
      debugPrint('INFO [OrdersProvider] $_totalOrders commande(s)');
      return;
    }

    if (forceRefresh) {
      debugPrint('REFRESH [OrdersProvider] Rechargement force');
    } else if (_shouldRefresh) {
      debugPrint('EXPIRED [OrdersProvider] Cache expire - Rechargement');
    } else {
      debugPrint('INIT [OrdersProvider] Premiere initialisation');
    }

    _setLoading(true);
    _clearError();

    try {
      final startTime = DateTime.now();

      // Charger les commandes et les stats en parallèle
      await Future.wait([
        loadOrders(refresh: true),
        loadOrdersByStatus(),
      ]);

      // Marquer comme initialise
      _isInitialized = true;
      _lastFetch = DateTime.now();

      final duration = DateTime.now().difference(startTime);
      debugPrint('OK [OrdersProvider] Chargement termine en ${duration.inMilliseconds}ms');
      debugPrint('INFO [OrdersProvider] $_totalOrders commande(s), ${_ordersByStatus.length} statuts');
    } catch (e) {
      debugPrint('ERROR [OrdersProvider] Erreur: $e');
      _setError('Erreur d\'initialisation: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 📋 Charger les commandes
  Future<void> loadOrders({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _orders.clear();
    }

    if (!_hasMore && !refresh) return;

    if (refresh) {
      _isRefreshing = true;
    } else if (_currentPage > 1) {
      _isLoadingMore = true;
    } else {
      _setLoading(true);
    }

    _clearError();
    notifyListeners();

    try {
      final startTime = DateTime.now();

      final result = await _orderService.searchOrders(
        query: _searchQuery,
        status: _filterStatus,
        startDate: _filterStartDate,
        endDate: _filterEndDate,
        page: _currentPage,
        limit: _pageSize,
      );

      // 🔍 DEBUG: Vérifier les données reçues
      debugPrint('[OrdersProvider] 📦 Received ${result.orders.length} orders');
      if (result.orders.isNotEmpty) {
        final firstOrder = result.orders.first;
        debugPrint('[OrdersProvider] 📊 First order items: ${firstOrder.items.length}');
        debugPrint('[OrdersProvider] 📋 First order ID: ${firstOrder.id}');
      }

      if (refresh) {
        _orders = result.orders;
      } else {
        _orders.addAll(result.orders);
      }

      _totalOrders = result.total;
      _totalPages = result.totalPages;
      _hasMore = result.hasMore;

      if (_hasMore) {
        _currentPage++;
      }

      final duration = DateTime.now().difference(startTime);
      debugPrint('OK [Orders] ${result.orders.length} commande(s) chargee(s) en ${duration.inMilliseconds}ms');

      _clearError();
    } catch (e) {
      debugPrint('ERROR [Orders] Erreur: $e');
      _setError('Erreur de chargement: ${e.toString()}');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// 📊 Charger les statistiques par statut
  Future<void> loadOrdersByStatus() async {
    try {
      final startTime = DateTime.now();
      _ordersByStatus = await _orderService.getOrdersByStatus();
      final duration = DateTime.now().difference(startTime);
      debugPrint('OK [OrdersStats] Stats chargees en ${duration.inMilliseconds}ms');
    } catch (e) {
      debugPrint('ERROR [OrdersStats] Erreur: $e');
    }
  }

  /// 🔍 Charger une commande par ID
  Future<void> loadOrderById(String orderId) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedOrder = await _orderService.getOrderById(orderId);
      debugPrint('OK [OrderDetails] Commande $orderId chargee');

      // Mettre à jour dans la liste si elle existe
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _selectedOrder!;
      }

      _clearError();
    } catch (e) {
      debugPrint('ERROR [OrderDetails] Erreur: $e');
      _setError('Erreur de chargement: ${e.toString()}');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// ➕ Créer une commande normale
  Future<Order?> createOrder(CreateOrderRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      final order = await _orderService.createOrder(request);
      debugPrint('OK [CreateOrder] Commande ${order.id} creee');

      // Ajouter au début de la liste
      _orders.insert(0, order);
      _totalOrders++;

      // Invalider le cache pour forcer un rechargement
      invalidateCache();

      _clearError();
      notifyListeners();
      return order;
    } catch (e) {
      debugPrint('ERROR [CreateOrder] Erreur: $e');
      _setError('Erreur de creation: ${e.toString()}');
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// ⚡ Créer une commande flash
  Future<Order?> createFlashOrder(CreateFlashOrderRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      final order = await _orderService.createFlashOrder(request);
      debugPrint('OK [CreateFlashOrder] Commande flash ${order.id} creee');

      // Ajouter au début de la liste
      _orders.insert(0, order);
      _totalOrders++;

      // Invalider le cache
      invalidateCache();

      _clearError();
      notifyListeners();
      return order;
    } catch (e) {
      debugPrint('ERROR [CreateFlashOrder] Erreur: $e');
      _setError('Erreur de creation flash: ${e.toString()}');
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// 🚫 Annuler une commande
  Future<bool> cancelOrder(String orderId) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedOrder = await _orderService.cancelOrder(orderId);
      debugPrint('OK [CancelOrder] Commande $orderId annulee');

      // Mettre à jour dans la liste
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = updatedOrder;
      }

      // Mettre à jour la commande sélectionnée
      if (_selectedOrder?.id == orderId) {
        _selectedOrder = updatedOrder;
      }

      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('ERROR [CancelOrder] Erreur: $e');
      _setError('Erreur d\'annulation: ${e.toString()}');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 🔄 Actualiser les commandes (force le rechargement)
  Future<void> refresh() async {
    debugPrint('REFRESH [OrdersProvider] Rafraichissement manuel');
    await initialize(forceRefresh: true);
  }

  /// 🗑️ Invalider le cache
  void invalidateCache() {
    debugPrint('CACHE [OrdersProvider] Cache invalide');
    _isInitialized = false;
    _lastFetch = null;
  }

  /// 🔍 Appliquer des filtres
  void applyFilters({
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? query,
  }) {
    _filterStatus = status;
    _filterStartDate = startDate;
    _filterEndDate = endDate;
    _searchQuery = query;

    debugPrint('FILTER [OrdersProvider] Filtres appliques');
    loadOrders(refresh: true);
  }

  /// 🧹 Effacer les filtres
  void clearFilters() {
    _filterStatus = null;
    _filterStartDate = null;
    _filterEndDate = null;
    _searchQuery = null;

    debugPrint('FILTER [OrdersProvider] Filtres effaces');
    loadOrders(refresh: true);
  }

  /// 🎯 Sélectionner une commande
  void selectOrder(Order order) {
    _selectedOrder = order;
    notifyListeners();
  }

  /// 🎯 Désélectionner la commande
  void clearSelection() {
    _selectedOrder = null;
    notifyListeners();
  }

  /// 📊 Obtenir les statistiques
  Map<String, dynamic> get statistics {
    return {
      'total': _totalOrders,
      'active': activeOrdersCount,
      'completed': completedOrdersCount,
      'pending': pendingOrders.length,
      'cancelled': cancelledOrders.length,
      'byStatus': _ordersByStatus,
    };
  }

  // Méthodes privées
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
