import 'package:admin/models/flash_order_update.dart';

import '../models/order.dart';
import '../models/orders_page_data.dart';
import 'api_service.dart';

class OrderService {
  static final _api = ApiService();
  static const String _adminBasePath = '/api/admin/orders';
  static const String _ordersBasePath =
      '/api/orders'; // Pour les routes standard d'orders

  /// Récupère toutes les commandes (méthode existante pour compatibilité)
  static Future<List<Order>> getOrders() async {
    try {
      final result =
          await loadOrdersPage(limit: 1000); // Charge toutes les commandes
      return result.orders;
    } catch (e) {
      print('[OrderService] Error getting all orders: $e');
      throw 'Erreur lors du chargement des commandes';
    }
  }

  /// Charge une page de commandes avec pagination et filtres
  /// @param page Le numéro de la page à récupérer (commence à 1)
  /// @param limit Le nombre maximum de commandes par page
  /// @param status Filtre optionnel sur le statut des commandes
  /// @param startDate Filtre optionnel sur la date de début
  /// @param endDate Filtre optionnel sur la date de fin
  static Future<OrdersPageData> loadOrdersPage({
    int page = 1,
    int limit = 50,
    String? status,
    String sortField = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    try {
      print('[OrderService] Loading orders page...');

      // Construction des paramètres de requête
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
        'sort': '$sortField:$sortOrder',
      };

      // Ajouter le status seulement s'il est défini
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _api.get(
        _adminBasePath,
        queryParameters: queryParams,
      );

      print('[OrderService] Raw API response: ${response.data}');

      // Vérification et normalisation de la réponse
      if (!response.data['success'] || response.data['data'] == null) {
        print('[OrderService] Invalid response format');
        return OrdersPageData.empty();
      }

      final List<Order> orders = [];
      final List rawOrders = response.data['data'] as List;
      final pagination = response.data['pagination'];

      // Traitement des commandes
      for (var item in rawOrders) {
        try {
          final normalizedData = _normalizeOrderData(item);
          final order = Order.fromJson(normalizedData);
          orders.add(order);
        } catch (e) {
          print('[OrderService] Error parsing order: $e');
          continue;
        }
      }

      return OrdersPageData(
        orders: orders,
        total: pagination['total'] ?? 0,
        currentPage: pagination['page'] ?? page,
        limit: pagination['limit'] ?? limit,
        totalPages: pagination['totalPages'] ?? 1,
      );
    } catch (e) {
      print('[OrderService] Error loading orders: $e');
      return OrdersPageData.empty();
    }
  }

  // Ajouter cette méthode helper
  static Map<String, dynamic> _normalizeOrderData(dynamic rawData) {
    final data = Map<String, dynamic>.from(rawData);

    // Normaliser les données utilisateur
    if (data['user'] != null) {
      final userData = Map<String, dynamic>.from(data['user']);
      data['user'] = {
        ...userData,
        'firstName': userData['first_name'] ?? userData['firstName'] ?? '',
        'lastName': userData['last_name'] ?? userData['lastName'] ?? '',
        'email': userData['email'] ?? '',
        'phone': userData['phone'] ?? '',
        'role': userData['role'] ?? 'CLIENT',
        'createdAt': userData['created_at'] ??
            userData['createdAt'] ??
            DateTime.now().toIso8601String(),
        'updatedAt': userData['updated_at'] ?? userData['updatedAt'],
      };
    }

    // Normaliser les champs numériques pour gérer les null
    return {
      ...data,
      'serviceId': data['service_id'] ?? data['serviceId'],
      'addressId': data['address_id'] ?? data['addressId'],
      'userId': data['user_id'] ?? data['userId'],
      'paymentMethod': data['paymentMethod'] ?? 'CASH',
      'paymentStatus': data['paymentStatus'] ?? 'PENDING',
      'totalAmount': data['totalAmount']?.toDouble() ?? 0.0,
      'isRecurring': data['isRecurring'] ?? false,
      'status': data['status'] ?? 'PENDING',
      // Gérer les coordonnées GPS null
      'gps_latitude': data['gps_latitude']?.toDouble() ?? 0.0,
      'gps_longitude': data['gps_longitude']?.toDouble() ?? 0.0,
    };
  }

  static Future<Order> getOrderById(String id) async {
    try {
      print('[OrderService] Fetching order details for ID: $id');
      // Correction de l'endpoint
      final response = await _api.get('$_ordersBasePath/$id');

      if (response.data != null && response.data['data'] != null) {
        final normalizedData = _normalizeOrderData(response.data['data']);
        return Order.fromJson(normalizedData);
      }
      throw 'Commande non trouvée';
    } catch (e) {
      print('[OrderService] Error getting order by id: $e');
      throw 'Erreur lors du chargement de la commande';
    }
  }

  /// Méthode spécifique pour obtenir les commandes récentes
  static Future<List<Order>> getRecentOrders({int limit = 5}) async {
    return loadOrdersPage(
            page: 1, limit: limit, sortField: 'createdAt', sortOrder: 'desc')
        .then((result) => result.orders);
  }

  static Future<Map<String, int>> getOrdersByStatus() async {
    try {
      final response = await _api.get('$_adminBasePath/by-status');

      if (response.data != null && response.data['data'] != null) {
        final Map<String, dynamic> raw = response.data['data'];
        return raw.map(
            (key, value) => MapEntry(key, int.tryParse(value.toString()) ?? 0));
      }
      return {};
    } catch (e) {
      print('[OrderService] Error getting orders by status: $e');
      return {};
    }
  }

  // Map des transitions de statut valides
  static final Map<String, List<String>> validTransitions = {
    'DRAFT': ['PENDING'], // Ajouter la transition depuis DRAFT
    'PENDING': ['COLLECTING'],
    'COLLECTING': ['COLLECTED'],
    'COLLECTED': ['PROCESSING'],
    'PROCESSING': ['READY'],
    'READY': ['DELIVERING'],
    'DELIVERING': ['DELIVERED'],
    'DELIVERED': [],
    'CANCELLED': []
  };

  // Vérifier si une transition est valide
  static bool isValidTransition(String currentStatus, String newStatus) {
    final validNextStatuses = validTransitions[currentStatus] ?? [];
    return validNextStatuses.contains(newStatus);
  }

  static Future<void> updateOrderStatus(
      String orderId, String newStatus) async {
    try {
      print('[OrderService] Updating order status: $orderId to $newStatus');

      // Obtenir d'abord les détails de la commande pour vérifier le statut actuel
      final order = await getOrderById(orderId);

      // Vérifier si la transition est valide
      if (!isValidTransition(order.status, newStatus)) {
        throw 'Transition de statut invalide : ${order.status} -> $newStatus n\'est pas autorisé';
      }

      final response = await _api.patch(
        '$_adminBasePath/$orderId/status',
        data: {'status': newStatus},
      );

      if (response.statusCode == 401) {
        print('[OrderService] Authorization error updating status');
        throw 'Session expirée. Veuillez vous reconnecter.';
      }

      if (response.statusCode == 403) {
        print('[OrderService] Permission denied updating status');
        throw 'Vous n\'avez pas les permissions nécessaires pour cette action.';
      }

      if (response.statusCode! >= 400) {
        print('[OrderService] Error response: ${response.data}');
        final message = response.data?['error'] ??
            response.data?['message'] ??
            'Erreur lors de la mise à jour du statut';
        throw message;
      }

      print('[OrderService] Order status updated successfully');
    } catch (e) {
      print('[OrderService] Error updating order status: $e');
      if (e is String) {
        throw e; // Propager les messages d'erreur personnalisés
      }
      throw 'Erreur lors de la mise à jour du statut : ${e.toString()}';
    }
  }

  static Future<Order> createOrder(Map<String, dynamic> orderData) async {
    try {
      print('[OrderService] Creating new order with data: $orderData');
      final response = await _api.post(
        '$_adminBasePath/create-order',
        data: orderData,
      );
      print('[OrderService] Create order response: ${response.data}');

      if (response.data != null && response.data['data'] != null) {
        return Order.fromJson(response.data['data']);
      }
      throw 'Erreur lors de la création de la commande';
    } catch (e) {
      print('[OrderService] Error creating order: $e');
      throw 'Erreur lors de la création de la commande';
    }
  }

  static Future<void> updateOrder(
      String orderId, Map<String, dynamic> orderData) async {
    try {
      print('[OrderService] Updating order: $orderId with data: $orderData');
      final response = await _api.put(
        '$_adminBasePath/$orderId',
        data: orderData,
      );

      if (response.statusCode == 401) {
        throw 'Session expirée. Veuillez vous reconnecter.';
      }

      if (response.statusCode == 403) {
        throw 'Vous n\'avez pas les permissions nécessaires pour cette action.';
      }

      if (response.statusCode! >= 400) {
        final message = response.data?['error'] ??
            response.data?['message'] ??
            'Erreur lors de la mise à jour de la commande';
        throw message;
      }

      print('[OrderService] Order updated successfully');
    } catch (e) {
      print('[OrderService] Error updating order: $e');
      if (e is String) {
        throw e;
      }
      throw 'Erreur lors de la mise à jour de la commande : ${e.toString()}';
    }
  }

  static Future<void> deleteOrder(String orderId) async {
    try {
      print('[OrderService] Deleting order: $orderId');
      await _api.delete('$_adminBasePath/$orderId');
      print('[OrderService] Order deleted successfully');
    } catch (e) {
      print('[OrderService] Error deleting order: $e');
      throw 'Erreur lors de la suppression de la commande';
    }
  }

  static Future<List<Order>> searchOrders(String query) async {
    try {
      print('[OrderService] Searching orders with query: $query');
      final allOrders = await getOrders();
      if (query.isEmpty) return allOrders;

      return allOrders.where((order) {
        final searchStr = query.toLowerCase();
        final id = order.id.toLowerCase();
        final status = order.status.toLowerCase();
        final customerName = order.customerName?.toLowerCase() ?? '';

        return id.contains(searchStr) ||
            status.contains(searchStr) ||
            customerName.contains(searchStr);
      }).toList();
    } catch (e) {
      print('[OrderService] Error searching orders: $e');
      throw 'Erreur lors de la recherche';
    }
  }

  static Future<Map<String, dynamic>> getOrderStatistics() async {
    try {
      print('[OrderService] Fetching order statistics');
      final statusData = await getOrdersByStatus();
      final total = statusData.values.fold<int>(0, (sum, count) => sum + count);

      final result = {
        'byStatus': statusData,
        'total': total,
        'percentages': statusData.map((status, count) => MapEntry(status,
            total > 0 ? (count / total * 100).toStringAsFixed(1) : '0')),
      };

      print('[OrderService] Order statistics: $result');
      return result;
    } catch (e) {
      print('[OrderService] Error getting order statistics: $e');
      throw 'Erreur lors du chargement des statistiques';
    }
  }

  static Future<List<Order>> getDraftOrders() async {
    try {
      print('[OrderService] Fetching draft flash orders');
      // Correction de l'URL pour utiliser _adminBasePath
      final response = await _api.get('$_adminBasePath/flash/draft');

      // Corriger l'appel print en utilisant string interpolation
      print('[OrderService] Draft orders response: ${response.data}');

      if (response.data != null && response.data['data'] != null) {
        final orders = (response.data['data'] as List)
            .map((json) => Order.fromJson(json))
            .toList();
        print('[OrderService] Parsed ${orders.length} draft orders');
        return orders;
      }
      return [];
    } catch (e) {
      print('[OrderService] Error getting draft orders: $e');
      return [];
    }
  }

  static Future<Order> createFlashOrder({
    required String addressId,
    String? notes,
  }) async {
    try {
      print('[OrderService] Creating flash order');
      final response = await _api.post(
        '$_adminBasePath/flash',
        data: {
          'addressId': addressId,
          'notes': notes,
        },
      );

      if (response.data != null && response.data['data'] != null) {
        return Order.fromJson(response.data['data']);
      }
      throw 'Erreur lors de la création de la commande flash';
    } catch (e) {
      print('[OrderService] Error creating flash order: $e');
      throw 'Erreur lors de la création de la commande flash';
    }
  }

  static Future<Order> completeFlashOrder(
      String orderId, FlashOrderUpdate updateData) async {
    try {
      print('[OrderService] Completing flash order: $orderId');
      print('[OrderService] Update data: ${updateData.toJson()}');

      final response = await _api.patch(
        '$_adminBasePath/flash/$orderId/complete',
        data: updateData.toJson(),
      );

      if (response.data != null && response.data['data'] != null) {
        return Order.fromJson(response.data['data']['order']);
      }

      throw 'Réponse invalide du serveur';
    } catch (e) {
      print('[OrderService] Error completing flash order: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getRevenueStatistics() async {
    try {
      print('[OrderService] Fetching revenue statistics');
      final response = await _api.get('$_adminBasePath/revenue/stats');
      // Corriger l'appel print en utilisant string interpolation
      print('[OrderService] Revenue stats response: ${response.data}');

      if (response.data != null && response.data['data'] != null) {
        final List<dynamic> rawData = response.data['data'];
        return rawData
            .map((item) => {
                  'date': item['date'],
                  'amount': (item['amount'] as num).toDouble(),
                  'count': item['count'] as int,
                })
            .toList();
      }
      return [];
    } catch (e) {
      print('[OrderService] Error getting revenue statistics: $e');
      return [];
    }
  }
}
