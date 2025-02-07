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
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
        'sort': '$sortField:$sortOrder',
      };

      // Normaliser le status avant l'envoi
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status.toUpperCase();
      }

      final response = await _api.get(
        '$_adminBasePath',
        queryParameters: queryParams,
      );

      print('[OrderService] Query params: $queryParams');
      print('[OrderService] Response: ${response.data}');

      if (!response.data['success']) {
        throw 'Invalid response from server';
      }

      final List<Order> orders = [];
      if (response.data['data'] != null) {
        final List rawOrders = response.data['data'] as List;

        for (var item in rawOrders) {
          try {
            final normalizedData = _normalizeOrderData(item);
            final order = Order.fromJson(normalizedData);
            orders.add(order);
          } catch (e) {
            print('[OrderService] Error parsing order: $e');
            // Continue avec la commande suivante
            continue;
          }
        }
      }

      final pagination = response.data['pagination'] ?? {};
      return OrdersPageData(
        orders: orders,
        total: pagination['total'] ?? 0,
        currentPage: pagination['page'] ?? page,
        limit: pagination['limit'] ?? limit,
        totalPages: pagination['totalPages'] ?? 1,
      );
    } catch (e) {
      print('[OrderService] Error loading orders page: $e');
      return OrdersPageData.empty();
    }
  }

  // Ajouter cette méthode helper
  static Map<String, dynamic> _normalizeOrderData(dynamic rawData) {
    if (rawData == null) return {};

    final data = Map<String, dynamic>.from(rawData);

    // Normaliser les données de base avec des valeurs par défaut
    final normalizedData = {
      ...data,
      'id': data['id']?.toString(),
      'userId': data['user_id'] ?? data['userId'] ?? '',
      'serviceId': data['service_id'] ?? data['serviceId'],
      'addressId': data['address_id'] ?? data['addressId'] ?? '',
      'status': (data['status'] as String?)?.toUpperCase() ?? 'PENDING',
      'totalAmount': _normalizeNumber(data['totalAmount']),
      'isRecurring': data['isRecurring'] == true,
      'paymentMethod':
          (data['paymentMethod'] as String?)?.toUpperCase() ?? 'CASH',
      'paymentStatus':
          (data['paymentStatus'] as String?)?.toUpperCase() ?? 'PENDING',
      'createdAt': data['created_at'] ??
          data['createdAt'] ??
          DateTime.now().toIso8601String(),
      'service': data['service'] != null
          ? _normalizeServiceData(data['service'])
          : null,
      'items': _normalizeItems(data['items']),
    };

    // Normaliser les relations
    if (data['user'] != null) {
      normalizedData['user'] = _normalizeUserData(data['user']);
    }

    if (data['items'] != null) {
      normalizedData['items'] = _normalizeItems(data['items']);
    }

    return normalizedData;
  }

  // Ajouter cette nouvelle méthode pour normaliser les items
  static List<Map<String, dynamic>> _normalizeItems(dynamic items) {
    if (items == null) return [];
    if (items is! List) return [];

    return items.map((item) {
      if (item == null) return <String, dynamic>{};

      final normalizedItem = Map<String, dynamic>.from(item);
      return {
        ...normalizedItem,
        'id': normalizedItem['id']?.toString() ?? '',
        'orderId': normalizedItem['orderId']?.toString() ??
            normalizedItem['order_id']?.toString() ??
            '',
        'articleId': normalizedItem['articleId']?.toString() ??
            normalizedItem['article_id']?.toString() ??
            '',
        'serviceId': normalizedItem['serviceId']?.toString() ??
            normalizedItem['service_id']?.toString() ??
            '',
        'quantity': _normalizeNumber(normalizedItem['quantity']).toInt(),
        'unitPrice': _normalizeNumber(normalizedItem['unitPrice']),
        'createdAt': normalizedItem['createdAt'] ??
            normalizedItem['created_at'] ??
            DateTime.now().toIso8601String(),
        'updatedAt':
            normalizedItem['updatedAt'] ?? normalizedItem['updated_at'],
        'article': normalizedItem['article'] != null
            ? _normalizeArticleData(normalizedItem['article'])
            : null,
      };
    }).toList();
  }

  // Ajouter cette méthode helper pour normaliser les données d'article
  static Map<String, dynamic> _normalizeArticleData(dynamic articleData) {
    if (articleData == null) return {};

    final data = Map<String, dynamic>.from(articleData);
    return {
      'id': data['id']?.toString() ?? '',
      'name': data['name']?.toString() ?? '',
      'description': data['description']?.toString(),
      'basePrice': _normalizeNumber(data['basePrice']),
      'premiumPrice': _normalizeNumber(data['premiumPrice']),
      'categoryId': data['categoryId']?.toString(),
      'createdAt': data['createdAt'] ??
          data['created_at'] ??
          DateTime.now().toIso8601String(),
      'updatedAt': data['updatedAt'] ?? data['updated_at'],
    };
  }

  static Map<String, dynamic> _normalizeUserData(
      Map<String, dynamic> userData) {
    return {
      ...userData,
      'firstName': userData['first_name'] ?? userData['firstName'] ?? '',
      'lastName': userData['last_name'] ?? userData['lastName'] ?? '',
      'email': userData['email'] ?? '',
      'phone': userData['phone'] ?? '',
      'role': userData['role']?.toString()?.toUpperCase() ?? 'CLIENT',
      'createdAt': userData['created_at'] ?? userData['createdAt'],
      'updatedAt': userData['updated_at'] ?? userData['updatedAt'],
    };
  }

  static double _normalizeNumber(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static Future<Order> getOrderById(String id) async {
    try {
      // Correction de l'endpoint - Utiliser l'endpoint standard
      final response = await _api.get('$_ordersBasePath/$id');

      if (response.data?['data'] == null) {
        throw 'Commande non trouvée';
      }

      return Order.fromJson(_normalizeOrderData(response.data['data']));
    } catch (e) {
      throw 'Erreur lors de la récupération de la commande: ${e.toString()}';
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
      final response = await _api.get('$_ordersBasePath/by-status');

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
        '$_ordersBasePath/$orderId/status',
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
        '$_adminBasePath/create-for-customer',
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
        '$_ordersBasePath/$orderId',
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
      await _api.delete('$_ordersBasePath/$orderId');
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
      final response = await _api.get('$_ordersBasePath/flash/draft');
      print('[OrderService] Draft orders response: ${response.data}');

      if (response.data == null || response.data['data'] == null) {
        return [];
      }

      final List<Order> orders = [];
      for (var item in response.data['data'] as List) {
        try {
          final normalizedData = _normalizeOrderData(item);
          final order = Order.fromJson(normalizedData);
          orders.add(order);
        } catch (e) {
          print('[OrderService] Error parsing draft order: $e');
          continue;
        }
      }

      print('[OrderService] Parsed ${orders.length} draft orders');
      return orders;
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
        '$_ordersBasePath/flash',
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
        '$_ordersBasePath/flash/$orderId/complete',
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

  // Ajouter cette méthode pour supporter les commandes flash
  static Future<bool> isFlashOrder(String orderId) async {
    try {
      final order = await getOrderById(orderId);
      return order.isFlashOrder;
    } catch (e) {
      return false;
    }
  }

  static Map<String, dynamic>? _normalizeServiceData(dynamic serviceData) {
    if (serviceData == null) return null;

    if (serviceData is! Map) return null;

    final data = Map<String, dynamic>.from(serviceData);
    return {
      'id': data['id']?.toString() ?? '',
      'name': data['name']?.toString() ?? '',
      'description': data['description']?.toString(),
      'price': _normalizeNumber(data['price']),
      'typeId': data['typeId']?.toString() ?? data['type_id']?.toString(),
      'createdAt': data['createdAt'] ??
          data['created_at'] ??
          DateTime.now().toIso8601String(),
      'updatedAt': data['updatedAt'] ?? data['updated_at']
    };
  }
}
