import 'package:admin/services/directions_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../models/delivery.dart';
import '../constants.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/map_service.dart';

class DeliveryController extends GetxController {
  // État observable
  final deliveries = <Delivery>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Filtres
  final selectedStatus = Rxn<DeliveryStatus>();
  final selectedDate = Rxn<DateTime>();
  final showPickups = true.obs;
  final showDeliveries = true.obs;

  // Stats journalières
  final totalDeliveries = 0.obs;
  final completedDeliveries = 0.obs;
  final totalDistance = 0.0.obs;
  final averageTime = 0.obs;

  // Remplacer les types Google Maps par Flutter Map
  final mapController = MapController().obs;
  final markers = <Marker>[].obs;
  final routes = <Polyline>[].obs;
  final selectedDelivery = Rxn<Delivery>();

  // Route tracking
  final deliveryRoutes = <String, Set<Polyline>>{}.obs;
  final DirectionsService _directionsService = DirectionsService();

  @override
  void onInit() {
    super.onInit();
    print('[DeliveryController] Initializing');
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await Future.wait([
      fetchDeliveries(),
      fetchDailyStats(),
    ]);
  }

  Future<void> fetchDeliveries() async {
    // TODO: Implémenter la logique pour récupérer les livraisons depuis une source de données
    // Pour l'instant, nous allons simuler des données
    deliveries.value = [
      Delivery(
        id: '1',
        orderId: '123',
        status: DeliveryStatus.PENDING_PICKUP,
        createdAt: DateTime.now(),
        pickupLocation: DeliveryLocation(
            latitude: 48.8566, longitude: 2.3522, address: 'Paris'),
        deliveryLocation: DeliveryLocation(
            latitude: 48.8738, longitude: 2.2950, address: 'Paris'),
      ),
      Delivery(
        id: '2',
        orderId: '456',
        status: DeliveryStatus.IN_TRANSIT,
        createdAt: DateTime.now(),
        pickupLocation: DeliveryLocation(
            latitude: 48.8647, longitude: 2.3490, address: 'Paris'),
        deliveryLocation: DeliveryLocation(
            latitude: 48.8584, longitude: 2.2945, address: 'Paris'),
      ),
    ];
  }

  Future<void> fetchDailyStats() async {
    // TODO: Implémenter la logique pour récupérer les statistiques journalières
    // Pour l'instant, nous allons simuler des données
    totalDeliveries.value = 100;
    completedDeliveries.value = 75;
    totalDistance.value = 150.5;
    averageTime.value = 30;
  }

  Future<void> centerMapOnDelivery(Delivery delivery) async {
    final bounds = LatLngBounds.fromPoints([
      LatLng(
          delivery.pickupLocation.latitude, delivery.pickupLocation.longitude),
      LatLng(delivery.deliveryLocation.latitude,
          delivery.deliveryLocation.longitude),
    ]);

    mapController.value.fitBounds(
      bounds,
      options: const FitBoundsOptions(padding: EdgeInsets.all(50.0)),
    );
  }

  void updateMarkers(List<Delivery> deliveries) {
    markers.value = deliveries
        .map((delivery) {
          return [
            MapService.createMarker(
              point: LatLng(delivery.pickupLocation.latitude,
                  delivery.pickupLocation.longitude),
              key: 'pickup_${delivery.id}',
              onTap: () => _onMarkerTapped(delivery),
            ),
            MapService.createMarker(
              point: LatLng(delivery.deliveryLocation.latitude,
                  delivery.deliveryLocation.longitude),
              key: 'delivery_${delivery.id}',
              onTap: () => _onMarkerTapped(delivery),
            ),
          ];
        })
        .expand((markers) => markers)
        .toList();
  }

  void _onMarkerTapped(Delivery delivery) {
    // Logique de gestion du tap sur un marqueur
    selectedDelivery.value = delivery;
  }

  Future<void> showRouteForDelivery(String deliveryId) async {
    try {
      final delivery = deliveries.firstWhere((d) => d.id == deliveryId);

      final points = await _directionsService.getDirections(
        origin: LatLng(delivery.pickupLocation.latitude,
            delivery.pickupLocation.longitude),
        destination: LatLng(delivery.deliveryLocation.latitude,
            delivery.deliveryLocation.longitude),
      );

      if (points.isNotEmpty) {
        final polyline = Polyline(
          points: points,
          color: AppColors.primary,
          strokeWidth: 3,
        );

        deliveryRoutes[deliveryId] = {polyline};

        // TODO: Ajuster la carte pour afficher l'itinéraire complet
        // _fitRouteInMap(response.routes.first.bounds);
      }
    } catch (e) {
      print('[DeliveryController] Error showing route: $e');
      _showErrorSnackbar('Impossible d\'afficher l\'itinéraire');
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Erreur',
      message,
      backgroundColor: AppColors.error,
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 4),
    );
  }
}
