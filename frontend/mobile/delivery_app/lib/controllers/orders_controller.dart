import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/delivery_order.dart';
import '../services/delivery_service.dart';
import '../services/auth_service.dart';
import '../constants.dart';

/// 📦 Contrôleur Commandes - Alpha Delivery App
///
/// Gère la logique métier des commandes pour les livreurs.
/// Optimisé pour les opérations mobiles : récupération, mise à jour statut,
/// filtrage et recherche.
class OrdersController extends GetxController {
  // ==========================================================================
  // 📦 PROPRIÉTÉS RÉACTIVES
  // ==========================================================================

  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final orders = <DeliveryOrder>[].obs;
  final filteredOrders = <DeliveryOrder>[].obs;

  final selectedOrder = Rxn<DeliveryOrder>();
  final currentFilter = OrderStatusFilter.all.obs;

  // Pagination
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalOrders = 0.obs;
  final hasMorePages = false.obs;
  final isLoadingMore = false.obs;
  final limit = 20; // Nombre d'éléments par page

  // ==========================================================================
  // 🚀 INITIALISATION
  // ==========================================================================

  @override
  void onInit() {
    super.onInit();
    debugPrint('📦 Initialisation OrdersController...');

    // Écouter les changements de filtre et recharger les données
    ever(currentFilter, (_) => fetchOrders());

    // Attendre l'authentification avant de charger (évite 401 après hot reload)
    final auth = Get.find<AuthService>();
    if (auth.isAuthenticated) {
      fetchOrders();
    } else {
      // Une seule fois, dès que connecté, on charge
      ever<bool>(auth.isAuthenticatedRx, (isAuth) {
        if (isAuth) {
          fetchOrders();
        }
      });
    }
  }

  // ==========================================================================
  // 📊 CHARGEMENT DES COMMANDES
  // ==========================================================================

  /// Récupère les commandes selon le filtre actuel avec pagination
  Future<void> fetchOrders({bool reset = true}) async {
    try {
      if (reset) {
        isLoading.value = true;
        currentPage.value = 1;
        orders.clear();
      } else {
        isLoadingMore.value = true;
      }

      hasError.value = false;
      errorMessage.value = '';

      debugPrint(
          '📦 Récupération des commandes (filtre: ${currentFilter.value}, page: ${currentPage.value})...');

      final deliveryService = Get.find<DeliveryService>();
      DeliveryOrdersResponse fetchedOrders;

      // Utiliser l'endpoint principal avec pagination
      fetchedOrders = await deliveryService.getAllDeliveryOrders(
        page: currentPage.value,
        limit: limit,
      );

      // Mettre à jour les informations de pagination
      if (fetchedOrders.pagination != null) {
        totalPages.value = fetchedOrders.pagination!.totalPages;
        totalOrders.value = fetchedOrders.pagination!.total;
        hasMorePages.value = currentPage.value < totalPages.value;
      }

      if (reset) {
        orders.assignAll(fetchedOrders.orders);
      } else {
        orders.addAll(fetchedOrders.orders);
      }

      _applyFilter();

      debugPrint(
          '✅ ${fetchedOrders.orders.length} commandes récupérées (page ${currentPage.value}/${totalPages.value})');
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération des commandes: $e');
      hasError.value = true;
      errorMessage.value = 'Impossible de charger les commandes';

      Get.snackbar(
        'Erreur',
        'Impossible de charger les commandes',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Charge la page suivante
  Future<void> loadNextPage() async {
    if (!hasMorePages.value || isLoadingMore.value) return;

    currentPage.value++;
    await fetchOrders(reset: false);
  }

  /// Actualise les commandes (pull-to-refresh)
  Future<void> refreshOrders() async {
    await fetchOrders();
  }

  // ==========================================================================
  // 🔍 FILTRAGE ET RECHERCHE
  // ==========================================================================

  /// Applique le filtre actuel aux commandes
  void _applyFilter() {
    final filter = currentFilter.value;

    // Debug : afficher les statuts présents
    final statusCounts = <OrderStatus, int>{};
    for (final order in orders) {
      statusCounts[order.status] = (statusCounts[order.status] ?? 0) + 1;
    }
    debugPrint('📊 Statuts présents: $statusCounts');

    switch (filter) {
      case OrderStatusFilter.draft:
        filteredOrders.assignAll(orders
            .where((order) => order.status == OrderStatus.DRAFT)
            .toList());
        break;
      case OrderStatusFilter.pending:
        filteredOrders.assignAll(orders
            .where((order) => order.status == OrderStatus.PENDING)
            .toList());
        break;
      case OrderStatusFilter.collecting:
        filteredOrders.assignAll(orders
            .where((order) => order.status == OrderStatus.COLLECTING)
            .toList());
        break;
      case OrderStatusFilter.collected:
        final collectedOrders = orders
            .where((order) => order.status == OrderStatus.COLLECTED)
            .toList();
        debugPrint(
            '🔍 Commandes collectées trouvées: ${collectedOrders.length}');
        for (final order in collectedOrders) {
          debugPrint('  - ${order.id}: ${order.status}');
        }
        filteredOrders.assignAll(collectedOrders);
        break;
      case OrderStatusFilter.processing:
        filteredOrders.assignAll(orders
            .where((order) => order.status == OrderStatus.PROCESSING)
            .toList());
        break;
      case OrderStatusFilter.ready:
        filteredOrders.assignAll(orders
            .where((order) => order.status == OrderStatus.READY)
            .toList());
        break;
      case OrderStatusFilter.delivering:
        filteredOrders.assignAll(orders
            .where((order) => order.status == OrderStatus.DELIVERING)
            .toList());
        break;
      case OrderStatusFilter.delivered:
        final deliveredOrders = orders
            .where((order) => order.status == OrderStatus.DELIVERED)
            .toList();
        debugPrint('🔍 Commandes livrées trouvées: ${deliveredOrders.length}');
        for (final order in deliveredOrders) {
          debugPrint('  - ${order.id}: ${order.status}');
        }
        filteredOrders.assignAll(deliveredOrders);
        break;
      case OrderStatusFilter.cancelled:
        filteredOrders.assignAll(orders
            .where((order) => order.status == OrderStatus.CANCELLED)
            .toList());
        break;
      case OrderStatusFilter.all:
        filteredOrders.assignAll(orders);
        break;
    }

    debugPrint(
        '🔍 Filtre appliqué: $filter (${filteredOrders.length} commandes)');
  }

  /// Change le filtre actif
  void setFilter(OrderStatusFilter filter) {
    currentFilter.value = filter;
  }

  /// Recherche dans les commandes (par ID, nom client, etc.)
  void searchOrders(String query) {
    if (query.isEmpty) {
      _applyFilter();
      return;
    }

    final baseFiltered = orders.where((order) {
      final matchesFilter = currentFilter.value == OrderStatusFilter.all ||
          order.status == _filterToStatus(currentFilter.value);

      if (!matchesFilter) return false;

      final searchTerm = query.toLowerCase();
      return order.id.toLowerCase().contains(searchTerm) ||
          '${order.customer.firstName} ${order.customer.lastName}'
              .toLowerCase()
              .contains(searchTerm) ||
          order.address.street.toLowerCase().contains(searchTerm);
    }).toList();

    filteredOrders.assignAll(baseFiltered);
    debugPrint('🔍 Recherche: "$query" (${filteredOrders.length} résultats)');
  }

  /// Recherche avancée avec paramètres multiples
  Future<List<DeliveryOrder>> searchOrdersAdvanced(
      Map<String, dynamic> searchParams) async {
    try {
      debugPrint('🔍 Recherche avancée avec paramètres: $searchParams');

      final deliveryService = Get.find<DeliveryService>();

      // Utiliser la méthode de recherche du service
      final results = await deliveryService.searchOrders(
        query: searchParams['searchTerm'],
        status: searchParams['status'] != null
            ? OrderStatus.values
                .firstWhere((s) => s.name == searchParams['status'])
            : null,
        startDate: searchParams['startDate'] != null
            ? DateTime.parse(searchParams['startDate'])
            : null,
        endDate: searchParams['endDate'] != null
            ? DateTime.parse(searchParams['endDate'])
            : null,
      );

      debugPrint('✅ Recherche avancée: ${results.orders.length} résultats');
      return results.orders;
    } catch (e) {
      debugPrint('❌ Erreur recherche avancée: $e');
      throw Exception('Erreur lors de la recherche avancée: $e');
    }
  }

  OrderStatus _filterToStatus(OrderStatusFilter filter) {
    switch (filter) {
      case OrderStatusFilter.draft:
        return OrderStatus.DRAFT;
      case OrderStatusFilter.pending:
        return OrderStatus.PENDING;
      case OrderStatusFilter.collecting:
        return OrderStatus.COLLECTING;
      case OrderStatusFilter.collected:
        return OrderStatus.COLLECTED;
      case OrderStatusFilter.processing:
        return OrderStatus.PROCESSING;
      case OrderStatusFilter.ready:
        return OrderStatus.READY;
      case OrderStatusFilter.delivering:
        return OrderStatus.DELIVERING;
      case OrderStatusFilter.delivered:
        return OrderStatus.DELIVERED;
      case OrderStatusFilter.cancelled:
        return OrderStatus.CANCELLED;
      case OrderStatusFilter.all:
        return OrderStatus.PENDING;
    }
  }

  // ==========================================================================
  // 📝 GESTION DES COMMANDES
  // ==========================================================================

  /// Sélectionne une commande pour les détails
  void selectOrder(DeliveryOrder order) {
    selectedOrder.value = order;
    debugPrint('📝 Commande sélectionnée: ${order.id}');
  }

  /// Désélectionne la commande
  void clearSelection() {
    selectedOrder.value = null;
  }

  /// Met à jour le statut d'une commande
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      debugPrint('📝 Mise à jour statut commande $orderId: $newStatus');

      final deliveryService = Get.find<DeliveryService>();
      await deliveryService.updateOrderStatus(orderId, newStatus);

      // Mettre à jour localement
      final index = orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        final updatedOrder = orders[index].copyWith(status: newStatus);
        orders[index] = updatedOrder;

        // Mettre à jour la sélection si nécessaire
        if (selectedOrder.value?.id == orderId) {
          selectedOrder.value = updatedOrder;
        }
      }

      _applyFilter();

      Get.snackbar(
        'Succès',
        'Statut mis à jour avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );

      return true;
    } catch (e) {
      debugPrint('❌ Erreur mise à jour statut: $e');
      hasError.value = true;
      errorMessage.value = 'Impossible de mettre à jour le statut';

      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour le statut',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Ajoute une note à une commande
  Future<bool> addOrderNote(String orderId, String note) async {
    try {
      debugPrint('📝 Ajout note à commande $orderId');

      final deliveryService = Get.find<DeliveryService>();
      final success = await deliveryService.addOrderNote(orderId, note);

      if (success) {
        // Recharger les commandes pour avoir les notes à jour
        await fetchOrders();

        Get.snackbar(
          'Succès',
          'Note ajoutée avec succès',
          backgroundColor: AppColors.success,
          colorText: AppColors.textLight,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        return true;
      } else {
        throw Exception('Échec de l\'ajout de note');
      }
    } catch (e) {
      debugPrint('❌ Erreur ajout note: $e');

      Get.snackbar(
        'Erreur',
        'Impossible d\'ajouter la note',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );

      return false;
    }
  }

  // ==========================================================================
  // 📊 STATISTIQUES ET MÉTRIQUES
  // ==========================================================================

  /// Retourne le nombre de commandes par statut
  Map<OrderStatus, int> getOrderCounts() {
    final counts = <OrderStatus, int>{};

    for (final status in OrderStatus.values) {
      counts[status] = orders.where((order) => order.status == status).length;
    }

    return counts;
  }

  /// Retourne les commandes urgentes (à collecter/livrer aujourd'hui)
  List<DeliveryOrder> getUrgentOrders() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return orders.where((order) {
      if (order.collectionDate != null) {
        final collectionDay = DateTime(
          order.collectionDate!.year,
          order.collectionDate!.month,
          order.collectionDate!.day,
        );
        if (collectionDay == today && order.status == OrderStatus.PENDING) {
          return true;
        }
      }

      if (order.deliveryDate != null) {
        final deliveryDay = DateTime(
          order.deliveryDate!.year,
          order.deliveryDate!.month,
          order.deliveryDate!.day,
        );
        if (deliveryDay == today && order.status == OrderStatus.COLLECTED) {
          return true;
        }
      }

      return false;
    }).toList();
  }

  // ==========================================================================
  // 🧹 NETTOYAGE
  // ==========================================================================

  @override
  void onClose() {
    debugPrint('🧹 OrdersController nettoyé');
    super.onClose();
  }
}

/// 🔍 Filtres de statut pour les commandes
enum OrderStatusFilter {
  all,
  draft,
  pending,
  collecting,
  collected,
  processing,
  ready,
  delivering,
  delivered,
  cancelled,
}
