import 'api_service.dart';
import '../models/order.dart';

/// 📦 Service de Gestion des Commandes - Alpha Client App
///
/// Gère toutes les interactions avec l'API backend pour les commandes
/// Routes : /api/orders/*
class OrderService {
  final ApiService _api = ApiService();

  // ==================== GET METHODS ====================

  /// 📋 Récupérer les commandes de l'utilisateur connecté (avec enrichissement)
  /// GET /api/orders/client/my-orders
  /// ✅ Utilise l'endpoint dédié au client avec itemsCount
  Future<List<Order>> getMyOrders({
    int page = 1,
    int limit = 20,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? sortBy = 'createdAt',
    String? sortOrder = 'desc',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      if (status != null) {
        queryParams['status'] = status.name.toUpperCase();
      }
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await _api.get(
        '/orders/client/my-orders',  // ✅ Nouveau endpoint enrichi
        queryParameters: queryParams,
      );

      if (response['success'] == true || response['data'] != null) {
        final ordersData = response['data'] ?? [];
        
        // 🔍 DEBUG: Log des données reçues
        if ((ordersData as List).isNotEmpty) {
          final firstOrder = (ordersData as List).first;
          print('[OrderService] 📦 First order from API: ${firstOrder.toString().substring(0, 200)}...');
          print('[OrderService] 🔑 Keys in first order: ${(firstOrder as Map).keys.toList()}');
          print('[OrderService] 💰 manualPrice: ${(firstOrder as Map)['manualPrice']}');
          print('[OrderService] 💳 isPaid: ${(firstOrder as Map)['isPaid']}');
        }
        
        return (ordersData as List)
            .map((json) => Order.fromJson(json))
            .toList();
      }

      throw Exception(response['error'] ?? 'Erreur lors de la récupération des commandes');
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  /// 🔍 Récupérer une commande par son ID (avec enrichissement)
  /// GET /api/orders/client/by-id/:orderId
  /// ✅ Utilise l'endpoint enrichi avec les informations de service
  Future<Order> getOrderById(String orderId) async {
    try {
      print('[OrderService] 🔍 getOrderById called with enriched endpoint');
      final response = await _api.get('/orders/client/by-id/$orderId');

      if (response['success'] == true && response['data'] != null) {
        return Order.fromJson(response['data']);
      }

      throw Exception(response['error'] ?? 'Commande non trouvée');
    } catch (e) {
      throw Exception('Erreur de récupération: ${e.toString()}');
    }
  }

  /// 📊 Récupérer les commandes récentes
  /// GET /api/orders/recent?limit=5
  Future<List<Order>> getRecentOrders({int limit = 5}) async {
    try {
      final response = await _api.get(
        '/orders/recent',
        queryParameters: {'limit': limit},
      );

      if (response['success'] == true && response['data'] != null) {
        final ordersData = response['data'] as List;
        return ordersData.map((json) => Order.fromJson(json)).toList();
      }

      throw Exception(response['error'] ?? 'Erreur lors de la récupération');
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  /// 📈 Récupérer les statistiques des commandes par statut
  /// GET /api/orders/by-status
  Future<Map<String, int>> getOrdersByStatus() async {
    try {
      final response = await _api.get('/orders/by-status');

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return data.map((key, value) => MapEntry(key, value as int));
      }

      return {};
    } catch (e) {
      print('[OrderService] Erreur getOrdersByStatus: $e');
      return {};
    }
  }

  /// 📄 Récupérer les détails complets d'une commande
  /// GET /api/orders/:orderId
  Future<Order> getOrderDetails(String orderId) async {
    try {
      final response = await _api.get('/orders/$orderId');

      if (response['data'] != null) {
        return Order.fromJson(response['data']);
      }

      throw Exception('Détails de commande non disponibles');
    } catch (e) {
      throw Exception('Erreur de récupération: ${e.toString()}');
    }
  }

  // ==================== POST METHODS ====================

  /// ➕ Créer une nouvelle commande normale
  /// POST /api/orders
  Future<Order> createOrder(CreateOrderRequest request) async {
    try {
      final response = await _api.post(
        '/orders',
        data: request.toJson(),
      );

      // Le backend retourne {data: {order: {...}, pricing: {...}, rewards: {...}}}
      if (response['data'] != null) {
        final data = response['data'];
        
        // Si data contient 'order', c'est le nouveau format
        if (data['order'] != null) {
          return Order.fromJson(data['order']);
        }
        
        // Sinon, c'est l'ancien format (rétrocompatibilité)
        return Order.fromJson(data);
      }

      throw Exception(response['error'] ?? 'Erreur lors de la création');
    } catch (e) {
      throw Exception('Erreur de création: ${e.toString()}');
    }
  }

  /// ⚡ Créer une commande flash (draft)
  /// POST /api/orders/flash
  Future<Order> createFlashOrder(CreateFlashOrderRequest request) async {
    try {
      final response = await _api.post(
        '/orders/flash',
        data: request.toJson(),
      );

      if (response['success'] == true && response['data'] != null) {
        return Order.fromJson(response['data']);
      }

      throw Exception(response['error'] ?? 'Erreur lors de la création flash');
    } catch (e) {
      throw Exception('Erreur de création flash: ${e.toString()}');
    }
  }

  /// 💰 Calculer le total d'une commande avant création
  /// POST /api/orders/calculate-total
  Future<OrderCalculation> calculateTotal(CalculateTotalRequest request) async {
    try {
      final response = await _api.post(
        '/orders/calculate-total',
        data: request.toJson(),
      );

      if (response['success'] == true && response['data'] != null) {
        return OrderCalculation.fromJson(response['data']);
      }

      throw Exception(response['error'] ?? 'Erreur de calcul');
    } catch (e) {
      throw Exception('Erreur de calcul: ${e.toString()}');
    }
  }

  // ==================== PATCH METHODS ====================

  /// 🔄 Mettre à jour une commande
  /// PATCH /api/orders/:orderId
  Future<Order> updateOrder(String orderId, UpdateOrderRequest request) async {
    try {
      final response = await _api.patch(
        '/orders/$orderId',
        data: request.toJson(),
      );

      if (response['success'] == true && response['data'] != null) {
        return Order.fromJson(response['data']);
      }

      throw Exception(response['error'] ?? 'Erreur de mise à jour');
    } catch (e) {
      throw Exception('Erreur de mise à jour: ${e.toString()}');
    }
  }

  /// 🚫 Annuler une commande
  /// PATCH /api/orders/:orderId/status
  Future<Order> cancelOrder(String orderId) async {
    try {
      final response = await _api.patch(
        '/orders/$orderId/status',
        data: {'status': 'CANCELLED'},
      );

      if (response['success'] == true && response['data'] != null) {
        return Order.fromJson(response['data']);
      }

      throw Exception(response['error'] ?? 'Erreur d\'annulation');
    } catch (e) {
      throw Exception('Erreur d\'annulation: ${e.toString()}');
    }
  }

  /// 📍 Mettre à jour l'adresse d'une commande
  /// PATCH /api/orders/:orderId/address
  Future<Order> updateOrderAddress(String orderId, String addressId) async {
    try {
      final response = await _api.patch(
        '/orders/$orderId/address',
        data: {'addressId': addressId},
      );

      if (response['success'] == true && response['data'] != null) {
        return Order.fromJson(response['data']);
      }

      throw Exception(response['error'] ?? 'Erreur de mise à jour adresse');
    } catch (e) {
      throw Exception('Erreur de mise à jour adresse: ${e.toString()}');
    }
  }

  // ==================== HELPER METHODS ====================

  /// 🔍 Rechercher des commandes (utilise l'endpoint enrichi pour le client)
  Future<OrderSearchResult> searchOrders({
    String? query,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    bool? isFlashOrder,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // 🔍 DEBUG: Log de l'appel
      print('[OrderService] 🔍 searchOrders called - using enriched endpoint');
      
      // ✅ Utiliser getMyOrders qui utilise déjà l'endpoint enrichi
      // Pour la recherche simple, on utilise getMyOrders avec les paramètres
      final orders = await getMyOrders(
        page: page,
        limit: limit,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );

      // Pour l'instant, on retourne tous les résultats
      // TODO: Implémenter la pagination côté serveur pour l'endpoint enrichi
      return OrderSearchResult(
        orders: orders,
        total: orders.length,
        currentPage: page,
        totalPages: 1,
      );
    } catch (e) {
      throw Exception('Erreur de recherche: ${e.toString()}');
    }
  }
}

// ==================== REQUEST MODELS ====================

/// 📝 Requête de création de commande normale
class CreateOrderRequest {
  final String serviceTypeId;
  final String? serviceId;
  final String addressId;
  final List<OrderItemRequest> items;
  final String? note;
  final String paymentMethod;
  final DateTime? collectionDate;
  final DateTime? deliveryDate;
  final String? affiliateCode;
  final bool isRecurring;
  final String? recurrenceType;

  CreateOrderRequest({
    required this.serviceTypeId,
    this.serviceId,
    required this.addressId,
    required this.items,
    this.note,
    required this.paymentMethod,
    this.collectionDate,
    this.deliveryDate,
    this.affiliateCode,
    this.isRecurring = false,
    this.recurrenceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceTypeId': serviceTypeId,
      if (serviceId != null) 'serviceId': serviceId,
      'addressId': addressId,
      'items': items.map((item) => item.toJson()).toList(),
      if (note != null) 'note': note,
      'paymentMethod': paymentMethod,
      if (collectionDate != null)
        'collectionDate': collectionDate!.toIso8601String(),
      if (deliveryDate != null)
        'deliveryDate': deliveryDate!.toIso8601String(),
      if (affiliateCode != null) 'affiliateCode': affiliateCode,
      'isRecurring': isRecurring,
      if (recurrenceType != null) 'recurrenceType': recurrenceType,
    };
  }
}

/// ⚡ Requête de création de commande flash
class CreateFlashOrderRequest {
  final String? addressId; // Optionnel, utilise l'adresse par défaut si null
  final String? note;

  CreateFlashOrderRequest({
    this.addressId,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      if (addressId != null) 'addressId': addressId,
      if (note != null) 'note': note,
    };
  }
}

/// 🛍️ Item de commande pour la requête
class OrderItemRequest {
  final String articleId;
  final String serviceId;
  final String serviceTypeId;
  final int quantity;
  final bool isPremium;
  final double? weight;

  OrderItemRequest({
    required this.articleId,
    required this.serviceId,
    required this.serviceTypeId,
    required this.quantity,
    this.isPremium = false,
    this.weight,
  });

  Map<String, dynamic> toJson() {
    return {
      'articleId': articleId,
      'serviceId': serviceId,
      'serviceTypeId': serviceTypeId,
      'quantity': quantity,
      'isPremium': isPremium,
      if (weight != null) 'weight': weight,
    };
  }
}

/// 🔄 Requête de mise à jour de commande
class UpdateOrderRequest {
  final String? paymentMethod;
  final DateTime? collectionDate;
  final DateTime? deliveryDate;
  final String? affiliateCode;
  final String? note;

  UpdateOrderRequest({
    this.paymentMethod,
    this.collectionDate,
    this.deliveryDate,
    this.affiliateCode,
    this.note,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (paymentMethod != null) map['paymentMethod'] = paymentMethod;
    if (collectionDate != null) {
      map['collectionDate'] = collectionDate!.toIso8601String();
    }
    if (deliveryDate != null) {
      map['deliveryDate'] = deliveryDate!.toIso8601String();
    }
    if (affiliateCode != null) map['affiliateCode'] = affiliateCode;
    if (note != null) map['note'] = note;
    return map;
  }
}

/// 💰 Requête de calcul de total
class CalculateTotalRequest {
  final List<OrderItemRequest> items;
  final String? affiliateCode;
  final bool isPremium;

  CalculateTotalRequest({
    required this.items,
    this.affiliateCode,
    this.isPremium = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      if (affiliateCode != null) 'affiliateCode': affiliateCode,
      'isPremium': isPremium,
    };
  }
}

// ==================== RESPONSE MODELS ====================

/// 💰 Résultat de calcul de total
class OrderCalculation {
  final double subtotal;
  final double discountAmount;
  final double deliveryFee;
  final double taxAmount;
  final double totalAmount;

  OrderCalculation({
    required this.subtotal,
    required this.discountAmount,
    required this.deliveryFee,
    required this.taxAmount,
    required this.totalAmount,
  });

  factory OrderCalculation.fromJson(Map<String, dynamic> json) {
    return OrderCalculation(
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? json['discount'] ?? 0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? json['tax'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? json['total'] ?? 0).toDouble(),
    );
  }
}

/// 🔍 Résultat de recherche de commandes
class OrderSearchResult {
  final List<Order> orders;
  final int total;
  final int currentPage;
  final int totalPages;

  OrderSearchResult({
    required this.orders,
    required this.total,
    required this.currentPage,
    required this.totalPages,
  });

  bool get hasMore => currentPage < totalPages;
}
