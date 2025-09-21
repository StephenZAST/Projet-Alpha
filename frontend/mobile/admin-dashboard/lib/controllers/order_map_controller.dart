import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/order_map.dart';
import '../models/enums.dart';
import '../services/order_map_service.dart';
import '../constants.dart';

class OrderMapController extends GetxController {
  // État de chargement et erreurs
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Données de la carte
  final mapOrders = <OrderMapData>[].obs;
  final mapStats = Rxn<OrderMapStats>();
  final geoStats = Rxn<OrderGeoStats>();
  final selectedOrder = Rxn<OrderMapData>();

  // Filtres pour la carte
  final filterStatus = ''.obs;
  final filterStartDate = Rx<DateTime?>(null);
  final filterEndDate = Rx<DateTime?>(null);
  final filterCollectionDateStart = Rx<DateTime?>(null);
  final filterCollectionDateEnd = Rx<DateTime?>(null);
  final filterDeliveryDateStart = Rx<DateTime?>(null);
  final filterDeliveryDateEnd = Rx<DateTime?>(null);
  final filterIsFlashOrder = Rxn<bool>();
  final filterServiceTypeId = ''.obs;
  final filterPaymentMethod = ''.obs;
  final filterCity = ''.obs;
  final filterPostalCode = ''.obs;

  // État de la carte
  final mapBounds = Rxn<MapBounds>();
  final mapCenter = Rxn<OrderCoordinates>();
  final mapZoom = 10.0.obs;
  final showClusters = true.obs;
  final showHeatmap = false.obs;

  // Contrôleurs de date
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final collectionStartDateController = TextEditingController();
  final collectionEndDateController = TextEditingController();
  final deliveryStartDateController = TextEditingController();
  final deliveryEndDateController = TextEditingController();

  // Options d'affichage
  final showOrderDetails = true.obs;
  final showStatusFilter = true.obs;
  final showDateFilter = true.obs;
  final autoRefresh = false.obs;
  final refreshInterval = 30.obs; // secondes
  
  // Thème de la carte (indépendant du thème de l'app)
  final mapTheme = 'auto'.obs; // 'auto', 'light', 'dark'

  @override
  void onInit() {
    super.onInit();
    loadOrdersForMap();
    loadGeoStats();
    
    // Auto-refresh si activé
    ever(autoRefresh, (bool enabled) {
      if (enabled) {
        _startAutoRefresh();
      } else {
        _stopAutoRefresh();
      }
    });
  }

  @override
  void onClose() {
    startDateController.dispose();
    endDateController.dispose();
    collectionStartDateController.dispose();
    collectionEndDateController.dispose();
    deliveryStartDateController.dispose();
    deliveryEndDateController.dispose();
    _stopAutoRefresh();
    super.onClose();
  }

  /// Charge les commandes pour affichage sur la carte
  Future<void> loadOrdersForMap({bool showLoading = true}) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }
      hasError.value = false;
      errorMessage.value = '';

      print('[OrderMapController] Loading orders for map with filters...');

      final response = await OrderMapService.getOrdersForMap(
        status: filterStatus.value.isEmpty ? null : filterStatus.value,
        startDate: startDateController.text.isEmpty ? null : startDateController.text,
        endDate: endDateController.text.isEmpty ? null : endDateController.text,
        collectionDateStart: collectionStartDateController.text.isEmpty ? null : collectionStartDateController.text,
        collectionDateEnd: collectionEndDateController.text.isEmpty ? null : collectionEndDateController.text,
        deliveryDateStart: deliveryStartDateController.text.isEmpty ? null : deliveryStartDateController.text,
        deliveryDateEnd: deliveryEndDateController.text.isEmpty ? null : deliveryEndDateController.text,
        isFlashOrder: filterIsFlashOrder.value,
        serviceTypeId: filterServiceTypeId.value.isEmpty ? null : filterServiceTypeId.value,
        paymentMethod: filterPaymentMethod.value.isEmpty ? null : filterPaymentMethod.value,
        city: filterCity.value.isEmpty ? null : filterCity.value,
        postalCode: filterPostalCode.value.isEmpty ? null : filterPostalCode.value,
        bounds: mapBounds.value,
      );

      mapOrders.value = response.orders;
      mapStats.value = response.stats;

      print('[OrderMapController] Loaded ${response.orders.length} orders for map');

      // Centrer la carte sur les commandes si pas encore défini
      if (mapCenter.value == null && response.orders.isNotEmpty) {
        _calculateMapCenter();
      }

    } catch (e) {
      print('[OrderMapController] Error loading orders for map: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des commandes : $e';
      _showErrorSnackbar(errorMessage.value);
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  /// Charge les statistiques géographiques
  Future<void> loadGeoStats() async {
    try {
      final stats = await OrderMapService.getOrdersGeoStats(
        status: filterStatus.value.isEmpty ? null : filterStatus.value,
        startDate: startDateController.text.isEmpty ? null : startDateController.text,
        endDate: endDateController.text.isEmpty ? null : endDateController.text,
        isFlashOrder: filterIsFlashOrder.value,
      );

      geoStats.value = stats;
      print('[OrderMapController] Loaded geo stats: ${stats.totalCities} cities, ${stats.totalOrders} orders');

    } catch (e) {
      print('[OrderMapController] Error loading geo stats: $e');
    }
  }

  /// Applique les filtres et recharge les données
  Future<void> applyFilters() async {
    await Future.wait([
      loadOrdersForMap(),
      loadGeoStats(),
    ]);
  }

  /// Réinitialise tous les filtres
  void clearFilters() {
    filterStatus.value = '';
    filterStartDate.value = null;
    filterEndDate.value = null;
    filterCollectionDateStart.value = null;
    filterCollectionDateEnd.value = null;
    filterDeliveryDateStart.value = null;
    filterDeliveryDateEnd.value = null;
    filterIsFlashOrder.value = null;
    filterServiceTypeId.value = '';
    filterPaymentMethod.value = '';
    filterCity.value = '';
    filterPostalCode.value = '';

    startDateController.clear();
    endDateController.clear();
    collectionStartDateController.clear();
    collectionEndDateController.clear();
    deliveryStartDateController.clear();
    deliveryEndDateController.clear();

    applyFilters();
  }

  /// Sélectionne une commande sur la carte
  void selectOrder(OrderMapData order) {
    selectedOrder.value = order;
    print('[OrderMapController] Selected order: ${order.id}');
  }

  /// Désélectionne la commande
  void deselectOrder() {
    selectedOrder.value = null;
  }

  /// Met à jour les limites de la carte
  void updateMapBounds(MapBounds bounds) {
    mapBounds.value = bounds;
    // Optionnel : recharger les commandes dans la nouvelle zone
    // loadOrdersForMap(showLoading: false);
  }

  /// Met à jour le centre de la carte
  void updateMapCenter(OrderCoordinates center) {
    mapCenter.value = center;
  }

  /// Met à jour le zoom de la carte
  void updateMapZoom(double zoom) {
    mapZoom.value = zoom;
  }

  /// Calcule le centre de la carte basé sur les commandes
  void _calculateMapCenter() {
    if (mapOrders.isEmpty) return;

    double totalLat = 0;
    double totalLng = 0;
    int count = 0;

    for (final order in mapOrders) {
      totalLat += order.coordinates.latitude;
      totalLng += order.coordinates.longitude;
      count++;
    }

    if (count > 0) {
      mapCenter.value = OrderCoordinates(
        latitude: totalLat / count,
        longitude: totalLng / count,
      );
    }
  }

  /// Filtre par statut
  void filterByStatus(String status) {
    filterStatus.value = status;
    applyFilters();
  }

  /// Filtre par type de commande (flash ou normale)
  void filterByFlashOrder(bool? isFlash) {
    filterIsFlashOrder.value = isFlash;
    applyFilters();
  }

  /// Filtre par ville
  void filterByCity(String city) {
    filterCity.value = city;
    applyFilters();
  }

  /// Filtre par code postal
  void filterByPostalCode(String postalCode) {
    filterPostalCode.value = postalCode;
    applyFilters();
  }

  /// Sélecteurs de date
  Future<void> pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: filterStartDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      filterStartDate.value = picked;
      startDateController.text = picked.toIso8601String().substring(0, 10);
      applyFilters();
    }
  }

  Future<void> pickEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: filterEndDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      filterEndDate.value = picked;
      endDateController.text = picked.toIso8601String().substring(0, 10);
      applyFilters();
    }
  }

  Future<void> pickCollectionStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: filterCollectionDateStart.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      filterCollectionDateStart.value = picked;
      collectionStartDateController.text = picked.toIso8601String().substring(0, 10);
      applyFilters();
    }
  }

  Future<void> pickCollectionEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: filterCollectionDateEnd.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      filterCollectionDateEnd.value = picked;
      collectionEndDateController.text = picked.toIso8601String().substring(0, 10);
      applyFilters();
    }
  }

  Future<void> pickDeliveryStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: filterDeliveryDateStart.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      filterDeliveryDateStart.value = picked;
      deliveryStartDateController.text = picked.toIso8601String().substring(0, 10);
      applyFilters();
    }
  }

  Future<void> pickDeliveryEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: filterDeliveryDateEnd.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      filterDeliveryDateEnd.value = picked;
      deliveryEndDateController.text = picked.toIso8601String().substring(0, 10);
      applyFilters();
    }
  }

  /// Basculer l'affichage des clusters
  void toggleClusters() {
    showClusters.value = !showClusters.value;
  }

  /// Basculer l'affichage de la heatmap
  void toggleHeatmap() {
    showHeatmap.value = !showHeatmap.value;
  }

  /// Basculer l'auto-refresh
  void toggleAutoRefresh() {
    autoRefresh.value = !autoRefresh.value;
  }

  /// Actualiser manuellement
  Future<void> refresh() async {
    await applyFilters();
    _showSuccessSnackbar('Données actualisées');
  }

  /// Changer le thème de la carte
  void setMapTheme(String theme) {
    mapTheme.value = theme;
  }

  /// Obtenir si la carte doit être en mode sombre
  bool isMapDark(BuildContext context) {
    switch (mapTheme.value) {
      case 'dark':
        return true;
      case 'light':
        return false;
      case 'auto':
      default:
        return Theme.of(context).brightness == Brightness.dark;
    }
  }

  /// Obtenir l'URL des tuiles selon le thème
  String getMapTileUrl(BuildContext context) {
    if (isMapDark(context)) {
      return 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png';
    } else {
      return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  /// Auto-refresh
  void _startAutoRefresh() {
    // Implémentation du timer pour l'auto-refresh
    // TODO: Implémenter avec Timer.periodic
  }

  void _stopAutoRefresh() {
    // TODO: Arrêter le timer
  }

  /// Obtenir les commandes par statut
  List<OrderMapData> getOrdersByStatus(String status) {
    return mapOrders.where((order) => order.status.toUpperCase() == status.toUpperCase()).toList();
  }

  /// Obtenir les commandes flash
  List<OrderMapData> get flashOrders {
    return mapOrders.where((order) => order.isFlashOrder).toList();
  }

  /// Obtenir les commandes normales
  List<OrderMapData> get normalOrders {
    return mapOrders.where((order) => !order.isFlashOrder).toList();
  }

  /// Obtenir les statistiques rapides
  Map<String, int> get quickStats {
    return {
      'total': mapOrders.length,
      'pending': getOrdersByStatus('PENDING').length,
      'processing': getOrdersByStatus('PROCESSING').length + 
                   getOrdersByStatus('COLLECTING').length + 
                   getOrdersByStatus('COLLECTED').length +
                   getOrdersByStatus('READY').length +
                   getOrdersByStatus('DELIVERING').length,
      'delivered': getOrdersByStatus('DELIVERED').length,
      'flash': flashOrders.length,
    };
  }

  void _showSuccessSnackbar(String message) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.success.withOpacity(0.85),
      borderRadius: 16,
      margin: AppSpacing.marginMD,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
      isDismissible: true,
      overlayBlur: 2.5,
    );
  }

  void _showErrorSnackbar(String message) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.error.withOpacity(0.90),
      borderRadius: 16,
      margin: AppSpacing.marginMD,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 3),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
      isDismissible: true,
      overlayBlur: 2.5,
    );
  }
}