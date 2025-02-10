import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart';
import '../models/delivery.dart';
import '../services/delivery_service.dart';
import '../constants.dart';

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

  // Google Maps
  final markers = <Marker>{}.obs;
  final mapController = Rxn<GoogleMapController>();
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

  // ... Ajoutez le reste des méthodes du contrôleur que vous avez fournies ...

  Future<void> centerMapOnDelivery(Delivery delivery) async {
    final controller = mapController.value;
    if (controller == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        delivery.pickupLocation.latitude
            .min(delivery.deliveryLocation.latitude),
        delivery.pickupLocation.longitude
            .min(delivery.deliveryLocation.longitude),
      ),
      northeast: LatLng(
        delivery.pickupLocation.latitude
            .max(delivery.deliveryLocation.latitude),
        delivery.pickupLocation.longitude
            .max(delivery.deliveryLocation.longitude),
      ),
    );

    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  Future<void> showRouteForDelivery(String deliveryId) async {
    try {
      final delivery = deliveries.firstWhere((d) => d.id == deliveryId);

      final response = await _directionsService.getDirections(
        origin: delivery.pickupLatLng,
        destination: delivery.deliveryLatLng,
      );

      if (response != null) {
        final points = response.routes.first.overviewPolyline.points;
        final polyline = Polyline(
          polylineId: PolylineId(deliveryId),
          points: _decodePolyline(points),
          color: AppColors.primary,
          width: 3,
        );

        deliveryRoutes[deliveryId] = {polyline};
        _fitRouteInMap(response.routes.first.bounds);
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
