import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';

import '../constants.dart';
import '../models/delivery_order.dart';
import '../services/delivery_service.dart';
import '../services/location_service.dart';

/// 🗺️ Contrôleur Carte - Alpha Delivery App
///
/// Gère la logique métier de la carte de livraison.
/// Fonctionnalités : markers, position GPS, filtres, sélection zones.
class MapController extends GetxController {
  // ==========================================================================
  // 🗺️ PROPRIÉTÉS RÉACTIVES
  // ==========================================================================

  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Contrôleur de carte
  late flutter_map.MapController mapController;

  // Position et zoom
  final currentCenter =
      const LatLng(MapConfig.defaultLatitude, MapConfig.defaultLongitude).obs;
  final currentZoom = MapConfig.defaultZoom.obs;
  final deliveryPosition = Rxn<LatLng>();

  // Commandes et markers
  final orders = <DeliveryOrder>[].obs;
  final visibleOrders = <DeliveryOrder>[].obs;
  final orderMarkers = <OrderMarker>[].obs;
  final selectedOrder = Rxn<DeliveryOrder>();

  // Filtres
  final statusFilter = Rxn<OrderStatus>();
  final selectedZone = Rxn<MapZone>();

  // Mode sélection de zone
  final isSelectingZone = false.obs;

  // Pagination
  int currentPage = 1;
  final int pageSize = 20;
  final hasMorePages = true.obs;
  final isLoadingMore = false.obs;

  // ==========================================================================
  // 🚀 INITIALISATION
  // ==========================================================================

  @override
  void onInit() {
    super.onInit();
    debugPrint('🗺️ Initialisation MapController...');

    // Initialiser le contrôleur de carte
    mapController = flutter_map.MapController();

    // Charger les données initiales
    _initializeMap();
  }

  @override
  void onClose() {
    debugPrint('🧹 MapController nettoyé');
    super.onClose();
  }

  /// Initialise la carte avec les données
  Future<void> _initializeMap() async {
    try {
      // Obtenir la position du livreur
      await _getCurrentPosition();

      // Charger les commandes
      await loadOrders();

      debugPrint('✅ Carte initialisée');
    } catch (e) {
      debugPrint('❌ Erreur initialisation carte: $e');
    }
  }

  // ==========================================================================
  // 📍 GESTION POSITION GPS
  // ==========================================================================

  /// Obtient la position actuelle du livreur
  Future<void> _getCurrentPosition() async {
    try {
      final locationService = Get.find<LocationService>();
      final position = await locationService.getCurrentPosition();

      if (position != null) {
        deliveryPosition.value = LatLng(position.latitude, position.longitude);

        // Centrer la carte sur la position du livreur
        currentCenter.value = deliveryPosition.value!;

        debugPrint('📍 Position livreur: ${deliveryPosition.value}');
      }
    } catch (e) {
      debugPrint('❌ Erreur obtention position: $e');

      // Utiliser la position par défaut (Dakar)
      deliveryPosition.value = const LatLng(
        MapConfig.defaultLatitude,
        MapConfig.defaultLongitude,
      );
    }
  }

  /// Centre la carte sur la position du livreur
  void centerOnDeliveryPosition() {
    if (deliveryPosition.value != null) {
      _animateToPosition(deliveryPosition.value!, MapConfig.defaultZoom);
    } else {
      Get.snackbar(
        'Position',
        'Position du livreur non disponible',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Anime la carte vers une position
  void _animateToPosition(LatLng position, double zoom) {
    currentCenter.value = position;
    currentZoom.value = zoom;

    // Animation fluide vers la nouvelle position
    mapController.move(position, zoom);
  }

  // ==========================================================================
  // 📦 GESTION DES COMMANDES
  // ==========================================================================

  /// Charge les commandes depuis le backend (première page)
  Future<void> loadOrders() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      currentPage = 1;

      debugPrint('📦 [MapController] Chargement page $currentPage (limit: $pageSize)...');

      final deliveryService = Get.find<DeliveryService>();
      final response = await deliveryService.getAllDeliveryOrders(
        page: currentPage,
        limit: pageSize,
      );

      debugPrint('📦 [MapController] Réponse reçue: ${response.orders.length} commandes');
      
      // Vérifier s'il y a plus de pages
      if (response.pagination != null) {
        hasMorePages.value = currentPage < response.pagination!.totalPages;
        debugPrint('📄 [MapController] Page $currentPage/${response.pagination!.totalPages}');
      } else {
        hasMorePages.value = response.orders.length >= pageSize;
      }

      orders.assignAll(response.orders);
      _updateVisibleOrders();
      _updateMarkers();

      debugPrint('✅ [MapController] ${orders.length} commandes chargées');
      debugPrint('✅ [MapController] ${visibleOrders.length} commandes visibles');
      debugPrint('✅ [MapController] ${orderMarkers.length} markers créés');
    } catch (e, stackTrace) {
      debugPrint('❌ [MapController] Erreur chargement commandes: $e');
      hasError.value = true;
      errorMessage.value = 'Impossible de charger les commandes';

      Get.snackbar(
        'Erreur',
        'Impossible de charger les commandes',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Charge plus de commandes (pagination)
  Future<void> loadMoreOrders() async {
    if (isLoadingMore.value || !hasMorePages.value) {
      debugPrint('⏭️ [MapController] Pas de chargement: isLoadingMore=${isLoadingMore.value}, hasMore=${hasMorePages.value}');
      return;
    }

    try {
      isLoadingMore.value = true;
      currentPage++;

      debugPrint('📦 [MapController] Chargement page $currentPage...');

      final deliveryService = Get.find<DeliveryService>();
      final response = await deliveryService.getAllDeliveryOrders(
        page: currentPage,
        limit: pageSize,
      );

      debugPrint('📦 [MapController] Page $currentPage: ${response.orders.length} nouvelles commandes');

      // Vérifier s'il y a plus de pages
      if (response.pagination != null) {
        hasMorePages.value = currentPage < response.pagination!.totalPages;
        debugPrint('📄 [MapController] Page $currentPage/${response.pagination!.totalPages}');
      } else {
        hasMorePages.value = response.orders.length >= pageSize;
      }

      // Ajouter les nouvelles commandes (éviter les doublons)
      for (final newOrder in response.orders) {
        if (!orders.any((o) => o.id == newOrder.id)) {
          orders.add(newOrder);
        }
      }

      _updateVisibleOrders();
      _updateMarkers();

      debugPrint('✅ [MapController] Total: ${orders.length} commandes, ${orderMarkers.length} markers');
    } catch (e) {
      debugPrint('❌ [MapController] Erreur chargement page $currentPage: $e');
      currentPage--; // Revenir à la page précédente en cas d'erreur
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Actualise les commandes (recharge depuis le début)
  Future<void> refreshOrders() async {
    await loadOrders();
  }

  /// Met à jour les commandes visibles selon les filtres
  void _updateVisibleOrders() {
    List<DeliveryOrder> filtered = orders.toList();

    // Filtre par statut
    if (statusFilter.value != null) {
      filtered = filtered
          .where((order) => order.status == statusFilter.value)
          .toList();
    }

    // Filtre par zone sélectionnée
    if (selectedZone.value != null) {
      filtered = filtered.where((order) {
        if (!order.address.hasCoordinates) return false;

        final orderPosition = LatLng(
          order.address.latitude!,
          order.address.longitude!,
        );

        return _isPointInZone(orderPosition, selectedZone.value!);
      }).toList();
    }

    visibleOrders.assignAll(filtered);
    debugPrint('🔍 ${visibleOrders.length} commandes visibles');
  }

  /// Met à jour les markers sur la carte
  void _updateMarkers() {
    final markers = <OrderMarker>[];

    for (final order in visibleOrders) {
      if (order.address.hasCoordinates) {
        markers.add(OrderMarker(
          order: order,
          position: LatLng(order.address.latitude!, order.address.longitude!),
          isSelected: selectedOrder.value?.id == order.id,
        ));
      }
    }

    orderMarkers.assignAll(markers);
    debugPrint('📍 ${orderMarkers.length} markers mis à jour');
  }

  // ==========================================================================
  // 🎯 SÉLECTION ET FILTRES
  // ==========================================================================

  /// Sélectionne une commande
  void selectOrder(DeliveryOrder order) {
    selectedOrder.value = order;
    _updateMarkers();

    // Centrer sur la commande sélectionnée
    if (order.address.hasCoordinates) {
      final position =
          LatLng(order.address.latitude!, order.address.longitude!);
      _animateToPosition(position, 16.0);
    }

    debugPrint('🎯 Commande sélectionnée: ${order.shortId}');
  }

  /// Désélectionne la commande
  void clearSelection() {
    selectedOrder.value = null;
    _updateMarkers();
  }

  /// Définit le filtre de statut
  void setStatusFilter(OrderStatus? status) {
    statusFilter.value = status;
    _updateVisibleOrders();
    _updateMarkers();

    final statusName = status?.displayName ?? 'Toutes';
    debugPrint('🔍 Filtre statut: $statusName');
  }

  /// Ajuste la vue pour montrer toutes les commandes
  void fitOrdersInView() {
    if (visibleOrders.isEmpty) {
      Get.snackbar(
        'Carte',
        'Aucune commande à afficher',
        backgroundColor: AppColors.info,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final positions = <LatLng>[];

    // Ajouter la position du livreur
    if (deliveryPosition.value != null) {
      positions.add(deliveryPosition.value!);
    }

    // Ajouter les positions des commandes
    for (final order in visibleOrders) {
      if (order.address.hasCoordinates) {
        positions
            .add(LatLng(order.address.latitude!, order.address.longitude!));
      }
    }

    if (positions.isNotEmpty) {
      final bounds = _calculateBounds(positions);
      _fitBounds(bounds);
    }
  }

  /// Calcule les limites pour une liste de positions
  flutter_map.LatLngBounds _calculateBounds(List<LatLng> positions) {
    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (final position in positions) {
      minLat = minLat < position.latitude ? minLat : position.latitude;
      maxLat = maxLat > position.latitude ? maxLat : position.latitude;
      minLng = minLng < position.longitude ? minLng : position.longitude;
      maxLng = maxLng > position.longitude ? maxLng : position.longitude;
    }

    return flutter_map.LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }

  /// Ajuste la carte aux limites données
  void _fitBounds(flutter_map.LatLngBounds bounds) {
    // Calculer le centre et le zoom approprié
    final center = bounds.center;

    // Zoom basé sur la distance
    final distance = const Distance()
        .as(LengthUnit.Kilometer, bounds.southWest, bounds.northEast);

    double zoom = MapConfig.defaultZoom;
    if (distance < 1) {
      zoom = 16.0;
    } else if (distance < 5) {
      zoom = 14.0;
    } else if (distance < 10) {
      zoom = 12.0;
    } else {
      zoom = 10.0;
    }

    _animateToPosition(center, zoom);
  }

  // ==========================================================================
  // 🔄 SÉLECTION DE ZONE
  // ==========================================================================

  /// Démarre la sélection de zone
  void startZoneSelection() {
    isSelectingZone.value = true;
    selectedZone.value = null;

    Get.snackbar(
      'Sélection de zone',
      'Tapez sur la carte pour définir une zone',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  /// Arrête la sélection de zone
  void stopZoneSelection() {
    isSelectingZone.value = false;
  }

  /// Vérifie si un point est dans une zone
  bool _isPointInZone(LatLng point, MapZone zone) {
    final distance = const Distance().as(
      LengthUnit.Meter,
      point,
      zone.center,
    );
    return distance <= zone.radius;
  }

  // ==========================================================================
  // 🎬 ÉVÉNEMENTS CARTE
  // ==========================================================================

  /// Gère le tap sur la carte
  void onMapTap(LatLng point) {
    if (isSelectingZone.value) {
      // Créer une zone de 1km de rayon
      selectedZone.value = MapZone(
        center: point,
        radius: 1000, // 1km en mètres
      );

      isSelectingZone.value = false;
      _updateVisibleOrders();
      _updateMarkers();

      Get.snackbar(
        'Zone sélectionnée',
        'Zone de 1km définie',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } else {
      // Désélectionner la commande actuelle
      clearSelection();
    }
  }

  /// Gère le déplacement de la carte
  void onMapMove(LatLng center, double zoom) {
    currentCenter.value = center;
    currentZoom.value = zoom;
  }

  // ==========================================================================
  // 📝 GESTION DES COMMANDES
  // ==========================================================================

  /// Met à jour le statut d'une commande
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      final deliveryService = Get.find<DeliveryService>();
      final updatedOrder =
          await deliveryService.updateOrderStatus(orderId, newStatus);

      // Mettre à jour localement
      final index = orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        orders[index] = updatedOrder;
        _updateVisibleOrders();
        _updateMarkers();
      }

      Get.snackbar(
        'Succès',
        'Statut mis à jour',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      debugPrint('❌ Erreur mise à jour statut: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour le statut',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // ==========================================================================
  // 📊 STATISTIQUES
  // ==========================================================================

  /// Retourne les statistiques des commandes visibles
  Map<OrderStatus, int> getVisibleOrderStats() {
    final stats = <OrderStatus, int>{};

    for (final status in OrderStatus.values) {
      stats[status] =
          visibleOrders.where((order) => order.status == status).length;
    }

    return stats;
  }

  /// Retourne la distance totale à parcourir
  double getTotalDistance() {
    if (deliveryPosition.value == null || visibleOrders.isEmpty) return 0.0;

    double totalDistance = 0.0;
    LatLng currentPos = deliveryPosition.value!;

    for (final order in visibleOrders) {
      if (order.address.hasCoordinates) {
        final orderPos =
            LatLng(order.address.latitude!, order.address.longitude!);
        totalDistance +=
            const Distance().as(LengthUnit.Kilometer, currentPos, orderPos);
        currentPos = orderPos;
      }
    }

    return totalDistance;
  }
}

/// 📍 Modèle de marker de commande
class OrderMarker {
  final DeliveryOrder order;
  final LatLng position;
  final bool isSelected;

  OrderMarker({
    required this.order,
    required this.position,
    required this.isSelected,
  });
}

/// 🔵 Modèle de zone de sélection
class MapZone {
  final LatLng center;
  final double radius; // en mètres

  MapZone({
    required this.center,
    required this.radius,
  });
}
