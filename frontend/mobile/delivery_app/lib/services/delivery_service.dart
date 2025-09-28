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

      // Calcule les statistiques
      final totalDeliveries = deliveredOrders.length;
      final completedDeliveries = deliveredOrders.length;
      final cancelledDeliveries = 0; // TODO: Ajouter endpoint pour commandes annulées
      
      // Calcule les livraisons par période
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final thisWeekStart = today.subtract(Duration(days: now.weekday - 1));
      final thisMonthStart = DateTime(now.year, now.month, 1);

      final deliveriesToday = deliveredOrders.where((order) {
        final deliveryDate = order.deliveryDate ?? order.updatedAt;
        return deliveryDate.isAfter(today);
      }).length;

      final deliveriesThisWeek = deliveredOrders.where((order) {
        final deliveryDate = order.deliveryDate ?? order.updatedAt;
        return deliveryDate.isAfter(thisWeekStart);
      }).length;

      final deliveriesThisMonth = deliveredOrders.where((order) {
        final deliveryDate = order.deliveryDate ?? order.updatedAt;
        return deliveryDate.isAfter(thisMonthStart);
      }).length;

      // Calcule les gains (basé sur le montant total des commandes livrées)
      final totalEarnings = deliveredOrders.fold<double>(0.0, (sum, order) => sum + (order.totalAmount ?? 0.0));
      
      final dailyEarnings = deliveredOrders.where((order) {
        final deliveryDate = order.deliveryDate ?? order.updatedAt;
        return deliveryDate.isAfter(today);
      }).fold<double>(0.0, (sum, order) => sum + (order.totalAmount ?? 0.0));

      final weeklyEarnings = deliveredOrders.where((order) {
        final deliveryDate = order.deliveryDate ?? order.updatedAt;
        return deliveryDate.isAfter(thisWeekStart);
      }).fold<double>(0.0, (sum, order) => sum + (order.totalAmount ?? 0.0));

      final monthlyEarnings = deliveredOrders.where((order) {
        final deliveryDate = order.deliveryDate ?? order.updatedAt;
        return deliveryDate.isAfter(thisMonthStart);
      }).fold<double>(0.0, (sum, order) => sum + (order.totalAmount ?? 0.0));

      // Calcule le taux de réussite
      final totalOrders = totalDeliveries + cancelledDeliveries;
      final successRate = totalOrders > 0 ? (completedDeliveries / totalOrders) : 1.0;

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

      if (response.data['success'] == true) {
        return DeliveryOrdersResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['error'] ??
            'Erreur lors de la récupération des commandes');
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

      if (response.data['success'] == true) {
        return DeliveryOrdersResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['error'] ??
            'Erreur lors de la récupération des commandes');
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

      if (response.data['success'] == true) {
        return DeliveryOrdersResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['error'] ??
            'Erreur lors de la récupération des commandes');
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

      if (response.data['success'] == true) {
        return DeliveryOrdersResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['error'] ??
            'Erreur lors de la récupération des commandes');
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

      if (response.data['success'] == true) {
        return DeliveryOrdersResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['error'] ??
            'Erreur lors de la récupération des commandes');
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

      if (response.data['success'] == true) {
        return DeliveryOrdersResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['error'] ??
            'Erreur lors de la récupération des commandes');
      }
    } catch (e) {
      debugPrint('❌ Erreur getDeliveredOrders: $e');
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

      if (response.data['success'] == true) {
        return DeliveryOrder.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['error'] ??
            'Erreur lors de la mise à jour du statut');
      }
    } catch (e) {
      debugPrint('❌ Erreur updateOrderStatus: $e');
      rethrow;
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

      if (query != null && query.isNotEmpty) queryParams['q'] = query;
      if (status != null) queryParams['status'] = status.name;
      if (startDate != null)
        queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await _apiService.get(
        '/delivery/orders/search',
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

  /// Récupère les commandes du jour en filtrant depuis les endpoints existants
  Future<List<DeliveryOrder>> getTodayOrders() async {
    try {
      debugPrint('📅 Calcul des commandes du jour...');

      // Récupère toutes les commandes actives
      final futures = await Future.wait([
        getAssignedOrders(page: 1, limit: 1000),
        getCollectedOrders(page: 1, limit: 1000),
        getReadyOrders(page: 1, limit: 1000),
        getDeliveringOrders(page: 1, limit: 1000),
      ]);

      // Combine toutes les commandes
      final allOrders = <DeliveryOrder>[];
      for (final response in futures) {
        allOrders.addAll(response.orders);
      }

      // Filtre les commandes du jour
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final todayOrders = allOrders.where((order) {
        // Vérifie si la commande a été créée aujourd'hui ou a une date de collecte/livraison aujourd'hui
        final createdToday = order.createdAt.isAfter(today);
        final collectionToday = order.collectionDate?.isAfter(today) ?? false;
        final deliveryToday = order.deliveryDate?.isAfter(today) ?? false;
        
        return createdToday || collectionToday || deliveryToday;
      }).toList();

      debugPrint('✅ ${todayOrders.length} commandes du jour trouvées');
      return todayOrders;

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
