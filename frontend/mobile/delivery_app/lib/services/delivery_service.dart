import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants.dart';
import '../models/delivery_order.dart';
import '../models/user.dart';
import 'api_service.dart';

/// 🚚 Service de Livraison - Alpha Delivery App
///
/// Gère toutes les communications avec les endpoints delivery du backend.
/// Optimisé pour les besoins spécifiques des livreurs mobiles.
class DeliveryService extends GetxService {
  // ==========================================================================
  // 📦 PROPRIÉTÉS
  // ==========================================================================

  late final ApiService _apiService;

  // ==========================================================================
  // 🚀 INITIALISATION
  // ==========================================================================

  @override
  Future<void> onInit() async {
    super.onInit();
    debugPrint('🚚 Initialisation DeliveryService...');

    _apiService = Get.find<ApiService>();

    debugPrint('✅ DeliveryService initialisé');
  }

  // ==========================================================================
  // 📊 DASHBOARD & STATISTIQUES
  // ==========================================================================

  /// Récupère les statistiques du dashboard en calculant depuis les endpoints existants
  Future<DeliveryStats> getDashboardStats() async {
    try {
      debugPrint('📊 Calcul des statistiques dashboard...');

      // Récupère toutes les commandes par statut en parallèle
      final futures = await Future.wait([
        getAssignedOrders(page: 1, limit: 1000),
        getPendingOrders(page: 1, limit: 1000),
        getCollectedOrders(page: 1, limit: 1000),
        getReadyOrders(page: 1, limit: 1000),
        getDeliveringOrders(page: 1, limit: 1000),
        getDeliveredOrders(page: 1, limit: 1000),
      ]);

      final assignedOrders = futures[0].orders;
      final pendingOrders = futures[1].orders;
      final collectedOrders = futures[2].orders;
      final readyOrders = futures[3].orders;
      final deliveringOrders = futures[4].orders;
      final deliveredOrders = futures[5].orders;

      // Combine toutes les commandes pour les statistiques globales
      final allOrders = <DeliveryOrder>[];
      allOrders.addAll(assignedOrders);
      allOrders.addAll(pendingOrders);
      allOrders.addAll(collectedOrders);
      allOrders.addAll(readyOrders);
      allOrders.addAll(deliveringOrders);
      allOrders.addAll(deliveredOrders);

      debugPrint('📊 Total commandes trouvées: ${allOrders.length}');
      debugPrint(
          '📊 Détail: Assigned=${assignedOrders.length}, Pending=${pendingOrders.length}, Collected=${collectedOrders.length}, Ready=${readyOrders.length}, Delivering=${deliveringOrders.length}, Delivered=${deliveredOrders.length}');

      // Calcule les statistiques
      final totalDeliveries =
          allOrders.length; // Toutes les commandes, pas seulement livrées
      final completedDeliveries = deliveredOrders.length;
      final cancelledDeliveries =
          0; // TODO: Ajouter endpoint pour commandes annulées

      // Fonction helper pour vérifier si une date est aujourd'hui
      bool isSameDay(DateTime date1, DateTime date2) {
        return date1.year == date2.year &&
            date1.month == date2.month &&
            date1.day == date2.day;
      }

      // Fonction helper pour vérifier si une date est dans la semaine courante
      bool isThisWeek(DateTime date, DateTime weekStart) {
        return date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            date.isBefore(weekStart.add(const Duration(days: 7)));
      }

      // Fonction helper pour vérifier si une date est dans le mois courant
      bool isThisMonth(DateTime date, DateTime monthStart) {
        return date.year == monthStart.year && date.month == monthStart.month;
      }

      // Calcule les livraisons par période
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final thisWeekStart = today.subtract(Duration(days: now.weekday - 1));
      final thisMonthStart = DateTime(now.year, now.month, 1);

      // Compte les commandes d'aujourd'hui (toutes les commandes actives)
      final deliveriesToday = allOrders.where((order) {
        // Vérifie si la commande a été créée aujourd'hui
        final createdToday = isSameDay(order.createdAt, now);
        // Ou si elle a une date de collecte/livraison aujourd'hui
        final collectionToday = order.collectionDate != null &&
            isSameDay(order.collectionDate!, now);
        final deliveryToday =
            order.deliveryDate != null && isSameDay(order.deliveryDate!, now);

        return createdToday || collectionToday || deliveryToday;
      }).length;

      // Compte les commandes de cette semaine
      final deliveriesThisWeek = allOrders.where((order) {
        final createdThisWeek = isThisWeek(order.createdAt, thisWeekStart);
        final collectionThisWeek = order.collectionDate != null &&
            isThisWeek(order.collectionDate!, thisWeekStart);
        final deliveryThisWeek = order.deliveryDate != null &&
            isThisWeek(order.deliveryDate!, thisWeekStart);

        return createdThisWeek || collectionThisWeek || deliveryThisWeek;
      }).length;

      // Compte les commandes de ce mois
      final deliveriesThisMonth = allOrders.where((order) {
        final createdThisMonth = isThisMonth(order.createdAt, thisMonthStart);
        final collectionThisMonth = order.collectionDate != null &&
            isThisMonth(order.collectionDate!, thisMonthStart);
        final deliveryThisMonth = order.deliveryDate != null &&
            isThisMonth(order.deliveryDate!, thisMonthStart);

        return createdThisMonth || collectionThisMonth || deliveryThisMonth;
      }).length;

      debugPrint(
          '📊 Statistiques calculées: Aujourd\'hui=$deliveriesToday, Semaine=$deliveriesThisWeek, Mois=$deliveriesThisMonth');

      // Calcule les gains (basé sur toutes les commandes avec montant)
      final totalEarnings = allOrders.fold<double>(
          0.0, (sum, order) => sum + (order.totalAmount ?? 0.0));

      final dailyEarnings = allOrders.where((order) {
        final createdToday = isSameDay(order.createdAt, now);
        final collectionToday = order.collectionDate != null &&
            isSameDay(order.collectionDate!, now);
        final deliveryToday =
            order.deliveryDate != null && isSameDay(order.deliveryDate!, now);
        return createdToday || collectionToday || deliveryToday;
      }).fold<double>(0.0, (sum, order) => sum + (order.totalAmount ?? 0.0));

      final weeklyEarnings = allOrders.where((order) {
        final createdThisWeek = isThisWeek(order.createdAt, thisWeekStart);
        final collectionThisWeek = order.collectionDate != null &&
            isThisWeek(order.collectionDate!, thisWeekStart);
        final deliveryThisWeek = order.deliveryDate != null &&
            isThisWeek(order.deliveryDate!, thisWeekStart);
        return createdThisWeek || collectionThisWeek || deliveryThisWeek;
      }).fold<double>(0.0, (sum, order) => sum + (order.totalAmount ?? 0.0));

      final monthlyEarnings = allOrders.where((order) {
        final createdThisMonth = isThisMonth(order.createdAt, thisMonthStart);
        final collectionThisMonth = order.collectionDate != null &&
            isThisMonth(order.collectionDate!, thisMonthStart);
        final deliveryThisMonth = order.deliveryDate != null &&
            isThisMonth(order.deliveryDate!, thisMonthStart);
        return createdThisMonth || collectionThisMonth || deliveryThisMonth;
      }).fold<double>(0.0, (sum, order) => sum + (order.totalAmount ?? 0.0));

      debugPrint(
          '📊 Gains calculés: Jour=${dailyEarnings.toStringAsFixed(0)}, Semaine=${weeklyEarnings.toStringAsFixed(0)}, Mois=${monthlyEarnings.toStringAsFixed(0)}');

      // Calcule le taux de réussite
      final totalOrders = totalDeliveries + cancelledDeliveries;
      final successRate =
          totalOrders > 0 ? (completedDeliveries / totalOrders) : 0.0;

      // Crée l'objet DeliveryStats
      return DeliveryStats(
        totalDeliveries: totalDeliveries,
        completedDeliveries: completedDeliveries,
        cancelledDeliveries: cancelledDeliveries,
        averageRating: 4.5, // Valeur par défaut, à remplacer par vraie donnée
        successRate: successRate,
        averageDeliveryTime: const Duration(minutes: 30), // Valeur par défaut
        totalEarnings: totalEarnings,
        monthlyEarnings: monthlyEarnings,
        weeklyEarnings: weeklyEarnings,
        dailyEarnings: dailyEarnings,
        deliveriesToday: deliveriesToday,
        deliveriesThisWeek: deliveriesThisWeek,
        deliveriesThisMonth: deliveriesThisMonth,
      );
    } catch (e) {
      debugPrint('❌ Erreur getDashboardStats: $e');
      rethrow;
    }
  }

  /// Récupère le profil complet du livreur via l'endpoint auth
  Future<DeliveryUser> getDeliveryProfile() async {
    try {
      debugPrint('👤 Récupération du profil livreur...');

      final response = await _apiService.get('/auth/me');

      if (response.data['success'] == true) {
        return DeliveryUser.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['error'] ??
            'Erreur lors de la récupération du profil');
      }
    } catch (e) {
      debugPrint('❌ Erreur getDeliveryProfile: $e');
      rethrow;
    }
  }

  /// Met à jour le profil du livreur via l'endpoint auth
  Future<DeliveryUser> updateDeliveryProfile(
      Map<String, dynamic> profileData) async {
    try {
      debugPrint('👤 Mise à jour du profil livreur...');

      final response =
          await _apiService.patch('/auth/update-profile', data: profileData);

      if (response.data['success'] == true) {
        return DeliveryUser.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['error'] ??
            'Erreur lors de la mise à jour du profil');
      }
    } catch (e) {
      debugPrint('❌ Erreur updateDeliveryProfile: $e');
      rethrow;
    }
  }

  // ==========================================================================
  // 📦 GESTION DES COMMANDES PAR STATUT
  // ==========================================================================

  /// Récupère les commandes en attente
  Future<DeliveryOrdersResponse> getPendingOrders(
      {int page = 1, int limit = 20}) async {
    try {
      debugPrint('📦 Récupération des commandes en attente...');

      final response = await _apiService.get(
        '/delivery/pending-orders',
        queryParameters: {'page': page, 'limit': limit},
      );

      // Gère les réponses avec ou sans wrapper "success"
      if (response.data is Map<String, dynamic>) {
        if (response.data.containsKey('success') &&
            response.data['success'] == true) {
          return DeliveryOrdersResponse.fromJson(response.data);
        } else if (response.data.containsKey('data')) {
          // Réponse directe avec data
          return DeliveryOrdersResponse.fromJson(response.data);
        } else {
          throw Exception(
              response.data['error'] ?? 'Format de réponse invalide');
        }
      } else {
        throw Exception('Format de réponse invalide');
      }
    } catch (e) {
      debugPrint('❌ Erreur getPendingOrders: $e');
      rethrow;
    }
  }

  /// Récupère les commandes assignées (à collecter)
  Future<DeliveryOrdersResponse> getAssignedOrders(
      {int page = 1, int limit = 20}) async {
    try {
      debugPrint('📦 Récupération des commandes assignées...');

      final response = await _apiService.get(
        '/delivery/assigned-orders',
        queryParameters: {'page': page, 'limit': limit},
      );

      // Gère les réponses avec ou sans wrapper "success"
      if (response.data is Map<String, dynamic>) {
        if (response.data.containsKey('success') &&
            response.data['success'] == true) {
          return DeliveryOrdersResponse.fromJson(response.data);
        } else if (response.data.containsKey('data')) {
          // Réponse directe avec data
          return DeliveryOrdersResponse.fromJson(response.data);
        } else {
          throw Exception(
              response.data['error'] ?? 'Format de réponse invalide');
        }
      } else {
        throw Exception('Format de réponse invalide');
      }
    } catch (e) {
      debugPrint('❌ Erreur getAssignedOrders: $e');
      rethrow;
    }
  }

  /// Récupère les commandes collectées
  Future<DeliveryOrdersResponse> getCollectedOrders(
      {int page = 1, int limit = 20}) async {
    try {
      final response = await _apiService.get(
        '/delivery/collected-orders',
        queryParameters: {'page': page, 'limit': limit},
      );

      // Gère les réponses avec ou sans wrapper "success"
      if (response.data is Map<String, dynamic>) {
        if (response.data.containsKey('success') &&
            response.data['success'] == true) {
          return DeliveryOrdersResponse.fromJson(response.data);
        } else if (response.data.containsKey('data')) {
          // Réponse directe avec data
          return DeliveryOrdersResponse.fromJson(response.data);
        } else {
          throw Exception(
              response.data['error'] ?? 'Format de réponse invalide');
        }
      } else {
        throw Exception('Format de réponse invalide');
      }
    } catch (e) {
      debugPrint('❌ Erreur getCollectedOrders: $e');
      rethrow;
    }
  }

  /// Récupère les commandes prêtes pour livraison
  Future<DeliveryOrdersResponse> getReadyOrders(
      {int page = 1, int limit = 20}) async {
    try {
      final response = await _apiService.get(
        '/delivery/ready-orders',
        queryParameters: {'page': page, 'limit': limit},
      );

      // Gère les réponses avec ou sans wrapper "success"
      if (response.data is Map<String, dynamic>) {
        if (response.data.containsKey('success') &&
            response.data['success'] == true) {
          return DeliveryOrdersResponse.fromJson(response.data);
        } else if (response.data.containsKey('data')) {
          // Réponse directe avec data
          return DeliveryOrdersResponse.fromJson(response.data);
        } else {
          throw Exception(
              response.data['error'] ?? 'Format de réponse invalide');
        }
      } else {
        throw Exception('Format de réponse invalide');
      }
    } catch (e) {
      debugPrint('❌ Erreur getReadyOrders: $e');
      rethrow;
    }
  }

  /// Récupère les commandes en cours de livraison
  Future<DeliveryOrdersResponse> getDeliveringOrders(
      {int page = 1, int limit = 20}) async {
    try {
      final response = await _apiService.get(
        '/delivery/delivering-orders',
        queryParameters: {'page': page, 'limit': limit},
      );

      // Gère les réponses avec ou sans wrapper "success"
      if (response.data is Map<String, dynamic>) {
        if (response.data.containsKey('success') &&
            response.data['success'] == true) {
          return DeliveryOrdersResponse.fromJson(response.data);
        } else if (response.data.containsKey('data')) {
          // Réponse directe avec data
          return DeliveryOrdersResponse.fromJson(response.data);
        } else {
          throw Exception(
              response.data['error'] ?? 'Format de réponse invalide');
        }
      } else {
        throw Exception('Format de réponse invalide');
      }
    } catch (e) {
      debugPrint('❌ Erreur getDeliveringOrders: $e');
      rethrow;
    }
  }

  /// Récupère les commandes livrées
  Future<DeliveryOrdersResponse> getDeliveredOrders(
      {int page = 1, int limit = 20}) async {
    try {
      final response = await _apiService.get(
        '/delivery/delivered-orders',
        queryParameters: {'page': page, 'limit': limit},
      );

      // Gère les réponses avec ou sans wrapper "success"
      if (response.data is Map<String, dynamic>) {
        if (response.data.containsKey('success') &&
            response.data['success'] == true) {
          return DeliveryOrdersResponse.fromJson(response.data);
        } else if (response.data.containsKey('data')) {
          // Réponse directe avec data
          return DeliveryOrdersResponse.fromJson(response.data);
        } else {
          throw Exception(
              response.data['error'] ?? 'Format de réponse invalide');
        }
      } else {
        throw Exception('Format de réponse invalide');
      }
    } catch (e) {
      debugPrint('❌ Erreur getDeliveredOrders: $e');
      rethrow;
    }
  }

  /// Récupère les commandes brouillon (DRAFT)
  Future<DeliveryOrdersResponse> getDraftOrders(
      {int page = 1, int limit = 20}) async {
    try {
      debugPrint('📦 Récupération des commandes brouillon...');

      final response = await _apiService.get(
        '/delivery/draft-orders',
        queryParameters: {'page': page, 'limit': limit},
      );

      // Gère les réponses avec ou sans wrapper "success"
      if (response.data is Map<String, dynamic>) {
        if (response.data.containsKey('success') &&
            response.data['success'] == true) {
          return DeliveryOrdersResponse.fromJson(response.data);
        } else if (response.data.containsKey('data')) {
          // Réponse directe avec data
          return DeliveryOrdersResponse.fromJson(response.data);
        } else {
          throw Exception(
              response.data['error'] ?? 'Format de réponse invalide');
        }
      } else {
        throw Exception('Format de réponse invalide');
      }
    } catch (e) {
      debugPrint('❌ Erreur getDraftOrders: $e');
      rethrow;
    }
  }

  // ==========================================================================
  // 🔄 ACTIONS SUR LES COMMANDES
  // ==========================================================================

  /// Met à jour le statut d'une commande
  Future<DeliveryOrder> updateOrderStatus(String orderId, OrderStatus status,
      {String? notes}) async {
    try {
      debugPrint('🔄 Mise à jour statut commande $orderId -> $status');

      final response = await _apiService.patch(
        '/delivery/$orderId/status',
        data: {
          'status': status.name,
          if (notes != null) 'notes': notes,
        },
      );

      debugPrint('📤 Réponse updateOrderStatus: ${response.data}');

      // Gère les différents formats de réponse
      if (response.data is Map<String, dynamic>) {
        // Format avec success wrapper
        if (response.data.containsKey('success') &&
            response.data['success'] == true) {
          return DeliveryOrder.fromJson(response.data['data']);
        }
        // Format direct avec data
        else if (response.data.containsKey('data')) {
          return DeliveryOrder.fromJson(response.data['data']);
        }
        // Format direct sans wrapper
        else if (response.data.containsKey('id')) {
          return DeliveryOrder.fromJson(response.data);
        } else {
          throw Exception(
              response.data['error'] ?? 'Format de réponse invalide');
        }
      } else {
        throw Exception('Format de réponse invalide');
      }
    } catch (e) {
      debugPrint('❌ Erreur updateOrderStatus: $e');
      throw Exception('Erreur lors de la mise à jour du statut');
    }
  }

  /// Récupère les détails complets d'une commande via l'endpoint général
  Future<DeliveryOrder> getOrderDetails(String orderId) async {
    try {
      debugPrint('📋 Récupération détails commande $orderId...');

      final response = await _apiService.get('/orders/$orderId');

      if (response.data['success'] == true) {
        return DeliveryOrder.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['error'] ??
            'Erreur lors de la récupération des détails');
      }
    } catch (e) {
      debugPrint('❌ Erreur getOrderDetails: $e');
      rethrow;
    }
  }

  /// Recherche avancée de commandes
  Future<DeliveryOrdersResponse> searchOrders({
    String? query,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      debugPrint('🔍 Recherche de commandes...');

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (query != null && query.isNotEmpty) queryParams['query'] = query;
      if (status != null) queryParams['status'] = status.name;
      if (startDate != null)
        queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await _apiService.get(
        '/orders',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        return DeliveryOrdersResponse.fromJson(response.data);
      } else {
        throw Exception(
            response.data['error'] ?? 'Erreur lors de la recherche');
      }
    } catch (e) {
      debugPrint('❌ Erreur searchOrders: $e');
      rethrow;
    }
  }

  /// Récupère les commandes par statut spécifique
  Future<DeliveryOrdersResponse> getOrdersByStatus(
    OrderStatus status, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      debugPrint('📦 Récupération commandes par statut: $status');

      switch (status) {
        case OrderStatus.PENDING:
          return await getPendingOrders(page: page, limit: limit);
        case OrderStatus.COLLECTING:
          return await getAssignedOrders(page: page, limit: limit);
        case OrderStatus.COLLECTED:
          return await getCollectedOrders(page: page, limit: limit);
        case OrderStatus.READY:
          return await getReadyOrders(page: page, limit: limit);
        case OrderStatus.DELIVERING:
          return await getDeliveringOrders(page: page, limit: limit);
        case OrderStatus.DELIVERED:
          return await getDeliveredOrders(page: page, limit: limit);
        default:
          // Pour les autres statuts, utiliser l'endpoint général avec filtre
          return await searchOrders(status: status, page: page, limit: limit);
      }
    } catch (e) {
      debugPrint('❌ Erreur getOrdersByStatus: $e');
      rethrow;
    }
  }

  /// Récupère toutes les commandes du livreur (tous statuts)
  Future<DeliveryOrdersResponse> getAllDeliveryOrders({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      debugPrint('📦 Récupération de toutes les commandes de livraison...');

      // Agrège depuis tous les endpoints de statut delivery pour obtenir uniquement les commandes pertinentes
      final futures = await Future.wait([
        getDraftOrders(
            page: 1, limit: 1000), // ✅ AJOUTÉ : Commandes DRAFT
        getPendingOrders(
            page: 1, limit: 1000), // Large limit pour récupérer tout
        getAssignedOrders(page: 1, limit: 1000),
        getCollectedOrders(page: 1, limit: 1000),
        getReadyOrders(page: 1, limit: 1000),
        getDeliveringOrders(page: 1, limit: 1000),
        getDeliveredOrders(page: 1, limit: 1000),
      ]);

      // Combine toutes les commandes
      final allOrders = <DeliveryOrder>[];
      var totalCount = 0;
      for (final response in futures) {
        allOrders.addAll(response.orders);
        totalCount += response.pagination?.total ?? response.orders.length;
      }
      
      debugPrint('📊 Statuts présents dans getAllDeliveryOrders:');
      final statusCounts = <String, int>{};
      for (final order in allOrders) {
        final statusName = order.status.toString().split('.').last;
        statusCounts[statusName] = (statusCounts[statusName] ?? 0) + 1;
      }
      statusCounts.forEach((status, count) {
        debugPrint('   - $status: $count');
      });

      // Trie par date de création décroissante
      allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Applique la pagination côté client
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      final paginatedOrders = allOrders.length > startIndex
          ? allOrders.sublist(startIndex, endIndex.clamp(0, allOrders.length))
          : <DeliveryOrder>[];

      // Calcule la pagination
      final totalPages = (totalCount / limit).ceil();
      final pagination = DeliveryPagination(
        page: page,
        limit: limit,
        total: totalCount,
        totalPages: totalPages,
      );

      debugPrint(
          '✅ ${paginatedOrders.length} commandes récupérées (page $page/$totalPages)');

      return DeliveryOrdersResponse(
        orders: paginatedOrders,
        pagination: pagination,
      );
    } catch (e) {
      debugPrint('❌ Erreur getAllDeliveryOrders: $e');
      rethrow;
    }
  }

  // ==========================================================================
  // 🗺️ FONCTIONNALITÉS CARTOGRAPHIQUES
  // ==========================================================================

  /// Récupère les commandes dans une zone géographique
  Future<List<DeliveryOrder>> getOrdersByLocation({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
    OrderStatus? status,
  }) async {
    try {
      debugPrint('🗺️ Récupération commandes par localisation...');

      final bounds = '$lat1,$lng1,$lat2,$lng2';
      final queryParams = <String, dynamic>{'bounds': bounds};

      if (status != null) queryParams['status'] = status.name;

      final response = await _apiService.get(
        '/delivery/orders/by-location',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final List<dynamic> ordersData = response.data['data'];
        return ordersData.map((json) => DeliveryOrder.fromJson(json)).toList();
      } else {
        throw Exception(response.data['error'] ??
            'Erreur lors de la récupération par localisation');
      }
    } catch (e) {
      debugPrint('❌ Erreur getOrdersByLocation: $e');
      rethrow;
    }
  }

  /// Met à jour la position du livreur
  Future<void> updateDelivererLocation(
      double latitude, double longitude) async {
    try {
      debugPrint('📍 Mise à jour position livreur...');

      final response = await _apiService.patch(
        '/delivery/location',
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ??
            'Erreur lors de la mise à jour de position');
      }
    } catch (e) {
      debugPrint('❌ Erreur updateDelivererLocation: $e');
      rethrow;
    }
  }

  // ==========================================================================
  // 📱 FONCTIONNALITÉS MOBILE SPÉCIFIQUES
  // ==========================================================================

  /// Récupère les commandes récentes triées par date (plus flexible que "du jour")
  Future<List<DeliveryOrder>> getTodayOrders({int limit = 10}) async {
    try {
      debugPrint('📅 Récupération des commandes récentes (limit: $limit)...');

      // Récupère toutes les commandes actives
      final futures = await Future.wait([
        getAssignedOrders(page: 1, limit: 1000),
        getPendingOrders(page: 1, limit: 1000),
        getCollectedOrders(page: 1, limit: 1000),
        getReadyOrders(page: 1, limit: 1000),
        getDeliveringOrders(page: 1, limit: 1000),
      ]);

      // Combine toutes les commandes
      final allOrders = <DeliveryOrder>[];
      for (final response in futures) {
        allOrders.addAll(response.orders);
      }

      debugPrint('📅 Total commandes actives: ${allOrders.length}');

      if (allOrders.isEmpty) {
        debugPrint('📅 Aucune commande active trouvée');
        return [];
      }

      // Trie les commandes par date la plus récente (création, collecte ou livraison)
      allOrders.sort((a, b) {
        // Obtient la date la plus récente pour chaque commande
        DateTime getRecentDate(DeliveryOrder order) {
          final dates = <DateTime>[order.createdAt];
          if (order.collectionDate != null) dates.add(order.collectionDate!);
          if (order.deliveryDate != null) dates.add(order.deliveryDate!);
          dates.add(order.updatedAt);

          // Retourne la date la plus récente
          dates.sort((d1, d2) => d2.compareTo(d1));
          return dates.first;
        }

        final dateA = getRecentDate(a);
        final dateB = getRecentDate(b);

        // Tri décroissant (plus récent en premier)
        return dateB.compareTo(dateA);
      });

      // Retourne les commandes les plus récentes selon la limite
      final recentOrders = allOrders.take(limit).toList();

      debugPrint('✅ ${recentOrders.length} commandes récentes trouvées');

      // Log des dates pour debug
      for (int i = 0; i < recentOrders.length && i < 3; i++) {
        final order = recentOrders[i];
        debugPrint(
            '📅 Commande ${i + 1}: Créée=${order.createdAt.toLocal()}, Collecte=${order.collectionDate?.toLocal()}, Livraison=${order.deliveryDate?.toLocal()}');
      }

      return recentOrders;
    } catch (e) {
      debugPrint('❌ Erreur getTodayOrders: $e');
      rethrow;
    }
  }

  /// Récupère l'historique des livraisons
  Future<DeliveryOrdersResponse> getDeliveryHistory({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      debugPrint('📚 Récupération historique livraisons...');

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (startDate != null)
        queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await _apiService.get(
        '/delivery/delivery-history',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        return DeliveryOrdersResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['error'] ??
            'Erreur lors de la récupération de l\'historique');
      }
    } catch (e) {
      debugPrint('❌ Erreur getDeliveryHistory: $e');
      rethrow;
    }
  }

  /// Met à jour le statut de disponibilité
  Future<void> updateAvailability(bool isAvailable) async {
    try {
      debugPrint('🟢 Mise à jour disponibilité: $isAvailable');

      final response = await _apiService.patch(
        '/delivery/availability',
        data: {'isAvailable': isAvailable},
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ??
            'Erreur lors de la mise à jour de disponibilité');
      }
    } catch (e) {
      debugPrint('❌ Erreur updateAvailability: $e');
      rethrow;
    }
  }

  // ==========================================================================
  // 👤 GESTION DU PROFIL
  // ==========================================================================

  /// Met à jour le profil du livreur
  Future<DeliveryUser> updateProfile(Map<String, dynamic> profileData) async {
    try {
      debugPrint('👤 Mise à jour du profil...');

      final response = await _apiService.patch(
        '/delivery/profile',
        data: profileData,
      );

      if (response.data['success'] == true) {
        return DeliveryUser.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['error'] ??
            'Erreur lors de la mise à jour du profil');
      }
    } catch (e) {
      debugPrint('❌ Erreur updateProfile: $e');
      rethrow;
    }
  }

  /// Change le mot de passe
  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    try {
      debugPrint('🔐 Changement de mot de passe...');

      final response = await _apiService.patch(
        '/delivery/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      if (response.data['success'] == true) {
        debugPrint('✅ Mot de passe changé avec succès');
        return true;
      } else {
        throw Exception(response.data['error'] ??
            'Erreur lors du changement de mot de passe');
      }
    } catch (e) {
      debugPrint('❌ Erreur changePassword: $e');
      rethrow;
    }
  }

  // ==========================================================================
  // 📝 GESTION DES NOTES
  // ==========================================================================

  /// Ajoute une note à une commande
  Future<bool> addOrderNote(String orderId, String note) async {
    try {
      debugPrint('📝 Ajout de note à la commande $orderId...');

      final response = await _apiService.post(
        '/delivery/$orderId/notes',
        data: {'note': note},
      );

      if (response.data['success'] == true) {
        debugPrint('✅ Note ajoutée avec succès');
        return true;
      } else {
        throw Exception(
            response.data['error'] ?? 'Erreur lors de l\'ajout de la note');
      }
    } catch (e) {
      debugPrint('❌ Erreur addOrderNote: $e');
      rethrow;
    }
  }
}
