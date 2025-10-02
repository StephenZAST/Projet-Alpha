import 'package:flutter/material.dart';
import '../constants.dart';
import '../core/services/api_service.dart';
import '../core/models/order.dart';

/// 📦 Provider Commandes - Alpha Client App
///
/// Provider pour la gestion de l'historique des commandes avec filtres,
/// pagination et suivi des statuts

class OrdersProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // État des commandes
  List<Order> _orders = [];
  bool _isLoadingOrders = false;
  String? _ordersError;
  int _currentPage = 1;
  bool _hasMoreOrders = true;

  // Filtres
  OrderStatus? _statusFilter;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  String? _searchQuery;

  // Commande sélectionnée
  Order? _selectedOrder;
  bool _isLoadingOrderDetails = false;
  String? _orderDetailsError;

  // Getters
  List<Order> get orders => _orders;
  bool get isLoadingOrders => _isLoadingOrders;
  String? get ordersError => _ordersError;
  bool get hasMoreOrders => _hasMoreOrders;

  OrderStatus? get statusFilter => _statusFilter;
  DateTime? get startDateFilter => _startDateFilter;
  DateTime? get endDateFilter => _endDateFilter;
  String? get searchQuery => _searchQuery;

  Order? get selectedOrder => _selectedOrder;
  bool get isLoadingOrderDetails => _isLoadingOrderDetails;
  String? get orderDetailsError => _orderDetailsError;

  // Getters calculés
  int get totalOrders => _orders.length;

  List<Order> get activeOrders => _orders
      .where((order) =>
          order.status != OrderStatus.delivered &&
          order.status != OrderStatus.cancelled)
      .toList();

  List<Order> get completedOrders =>
      _orders.where((order) => order.status == OrderStatus.delivered).toList();

  List<Order> get cancelledOrders =>
      _orders.where((order) => order.status == OrderStatus.cancelled).toList();

  Map<OrderStatus, int> get ordersByStatus {
    final Map<OrderStatus, int> statusCount = {};
    for (final order in _orders) {
      statusCount[order.status] = (statusCount[order.status] ?? 0) + 1;
    }
    return statusCount;
  }

  /// 🚀 Initialiser le provider
  Future<void> initialize() async {
    await loadOrders(refresh: true);
  }

  /// 📦 Charger les commandes
  Future<void> loadOrders({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _orders.clear();
      _hasMoreOrders = true;
    }

    if (!_hasMoreOrders && !refresh) return;

    _isLoadingOrders = true;
    _ordersError = null;
    notifyListeners();

    try {
      final queryParameters = <String, dynamic>{
        'page': _currentPage,
        'limit': 20,
      };

      // Ajouter les filtres
      if (_statusFilter != null) {
        queryParameters['status'] = _statusFilter!.name.toUpperCase();
      }
      if (_startDateFilter != null) {
        queryParameters['startDate'] = _startDateFilter!.toIso8601String();
      }
      if (_endDateFilter != null) {
        queryParameters['endDate'] = _endDateFilter!.toIso8601String();
      }
      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        queryParameters['query'] = _searchQuery;
      }

      final response = await _apiService.get(
        '/orders/my-orders',
        queryParameters: queryParameters,
      );

      if (response['success'] == true && response['data'] != null) {
        final ordersData = response['data'] as List;
        final newOrders =
            ordersData.map((json) => Order.fromJson(json)).toList();

        if (refresh) {
          _orders = newOrders;
        } else {
          _orders.addAll(newOrders);
        }

        // Vérifier s'il y a plus de pages
        final pagination = response['pagination'];
        if (pagination != null) {
          final currentPage = pagination['currentPage'] as int;
          final totalPages = pagination['totalPages'] as int;
          _hasMoreOrders = currentPage < totalPages;
          if (_hasMoreOrders) {
            _currentPage++;
          }
        } else {
          _hasMoreOrders = newOrders.length >= 20;
          if (_hasMoreOrders) {
            _currentPage++;
          }
        }

        _ordersError = null;
      } else {
        _ordersError = 'Erreur lors du chargement des commandes';
      }
    } catch (e) {
      _ordersError = 'Erreur de connexion: $e';
      print('Erreur loadOrders: $e');
    }

    _isLoadingOrders = false;
    notifyListeners();
  }

  /// 📋 Charger les détails d'une commande
  Future<void> loadOrderDetails(String orderId) async {
    _isLoadingOrderDetails = true;
    _orderDetailsError = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/orders/by-id/$orderId');

      if (response['success'] == true && response['data'] != null) {
        _selectedOrder = Order.fromJson(response['data']);
        _orderDetailsError = null;
      } else {
        _orderDetailsError = 'Erreur lors du chargement des détails';
      }
    } catch (e) {
      _orderDetailsError = 'Erreur de connexion: $e';
      print('Erreur loadOrderDetails: $e');
    }

    _isLoadingOrderDetails = false;
    notifyListeners();
  }

  /// ❌ Annuler une commande (si autorisé)
  Future<bool> cancelOrder(String orderId, String reason) async {
    try {
      final response = await _apiService.patch('/orders/$orderId', data: {
        'status': 'CANCELLED',
        'cancellationReason': reason,
      });

      if (response['success'] == true) {
        // Mettre à jour la commande localement
        final orderIndex = _orders.indexWhere((o) => o.id == orderId);
        if (orderIndex != -1) {
          _orders[orderIndex] = _orders[orderIndex].copyWith(
            status: OrderStatus.cancelled,
          );
        }

        // Mettre à jour la commande sélectionnée si c'est la même
        if (_selectedOrder?.id == orderId) {
          _selectedOrder = _selectedOrder!.copyWith(
            status: OrderStatus.cancelled,
          );
        }

        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Erreur cancelOrder: $e');
    }
    return false;
  }

  /// 🔍 Appliquer les filtres
  void applyFilters({
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? query,
  }) {
    _statusFilter = status;
    _startDateFilter = startDate;
    _endDateFilter = endDate;
    _searchQuery = query;

    loadOrders(refresh: true);
  }

  /// 🧹 Nettoyer les filtres
  void clearFilters() {
    _statusFilter = null;
    _startDateFilter = null;
    _endDateFilter = null;
    _searchQuery = null;

    loadOrders(refresh: true);
  }

  /// 🔄 Actualiser les commandes
  Future<void> refreshOrders() async {
    await loadOrders(refresh: true);
  }

  /// 🧹 Nettoyer les erreurs
  void clearErrors() {
    _ordersError = null;
    _orderDetailsError = null;
    notifyListeners();
  }

  /// 📊 Statistiques pour l'affichage
  Map<String, dynamic> get ordersStats {
    return {
      'totalOrders': totalOrders,
      'activeOrders': activeOrders.length,
      'completedOrders': completedOrders.length,
      'cancelledOrders': cancelledOrders.length,
      'ordersByStatus': ordersByStatus,
      'recentOrders': _orders.take(5).toList(),
    };
  }

  /// 📅 Obtenir les commandes par période
  List<Order> getOrdersByPeriod(DateTime startDate, DateTime endDate) {
    return _orders.where((order) {
      return order.createdAt.isAfter(startDate) &&
          order.createdAt.isBefore(endDate);
    }).toList();
  }

  /// 💰 Calculer le total dépensé
  double get totalSpent {
    return _orders
        .where((order) => order.status == OrderStatus.delivered)
        .fold(0.0, (sum, order) => sum + order.totalAmount);
  }

  /// 📈 Obtenir les commandes récentes (30 derniers jours)
  List<Order> get recentOrders {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return _orders
        .where((order) => order.createdAt.isAfter(thirtyDaysAgo))
        .toList();
  }

  /// 🔍 Rechercher des commandes
  List<Order> searchOrders(String query) {
    if (query.isEmpty) return _orders;

    final lowerQuery = query.toLowerCase();
    return _orders.where((order) {
      return order.id.toLowerCase().contains(lowerQuery) ||
          order.items.any((item) =>
              item.articleName.toLowerCase().contains(lowerQuery) ||
              item.serviceName.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// 🎯 Obtenir une commande par ID
  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  /// 📊 Obtenir les commandes par service
  Map<String, List<Order>> get ordersByService {
    final Map<String, List<Order>> serviceOrders = {};

    for (final order in _orders) {
      for (final item in order.items) {
        final serviceName = item.serviceName;
        if (!serviceOrders.containsKey(serviceName)) {
          serviceOrders[serviceName] = [];
        }
        if (!serviceOrders[serviceName]!.contains(order)) {
          serviceOrders[serviceName]!.add(order);
        }
      }
    }

    return serviceOrders;
  }

  /// 🏆 Obtenir le service le plus utilisé
  String? get mostUsedService {
    final serviceCount = <String, int>{};

    for (final order in _orders) {
      for (final item in order.items) {
        final serviceName = item.serviceName;
        serviceCount[serviceName] = (serviceCount[serviceName] ?? 0) + 1;
      }
    }

    if (serviceCount.isEmpty) return null;

    return serviceCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}
