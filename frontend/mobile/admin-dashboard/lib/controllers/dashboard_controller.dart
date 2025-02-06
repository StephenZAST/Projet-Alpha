import 'dart:async';
import 'package:admin/controllers/auth_controller.dart';
import 'package:get/get.dart';
import '../models/order.dart';
import '../services/dashboard_service.dart';
import '../constants.dart';
import '../services/order_service.dart'; // Ajouter cet import

class DashboardController extends GetxController {
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Statistiques générales
  final totalRevenue = 0.0.obs;
  final totalOrders = 0.obs;
  final totalCustomers = 0.obs;

  // Données pour les graphiques
  final revenueChartData = Rx<Map<String, List<dynamic>>>({
    'labels': <String>[],
    'data': <double>[],
  });
  final orderStatusCount = <String, int>{}.obs;

  // Données pour le graphique des revenus
  final revenueData = <Map<String, dynamic>>[].obs;

  // Commandes récentes
  final recentOrders = <Order>[].obs;

  // Timer pour le rafraîchissement automatique
  Timer? _refreshTimer;
  static const refreshInterval = Duration(minutes: 5);

  // État initial du dashboard
  final isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('[DashboardController] Initializing');

    // Charger les données immédiatement si l'utilisateur est déjà connecté
    final authController = Get.find<AuthController>();
    if (authController.isAuthenticated) {
      print('[DashboardController] User is authenticated, loading data');
      fetchDashboardData();
    }

    // Observer les changements d'authentification
    ever(authController.user, (user) {
      print('[DashboardController] Auth state changed: ${user != null}');
      if (user != null) {
        print('[DashboardController] User logged in, loading dashboard data');
        fetchDashboardData();
        _startRefreshTimer();
      } else {
        print('[DashboardController] User logged out, clearing dashboard data');
        _clearDashboardData();
        _refreshTimer?.cancel();
      }
    });
  }

  void _clearDashboardData() {
    totalRevenue.value = 0.0;
    totalOrders.value = 0;
    totalCustomers.value = 0;
    recentOrders.clear();
    orderStatusCount.clear();
    revenueChartData.value = {
      'labels': <String>[],
      'data': <double>[],
    };
    isInitialized.value = false;
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(refreshInterval, (timer) {
      fetchDashboardData();
    });
  }

  Future<void> fetchDashboardData() async {
    try {
      print('[DashboardController] Starting to fetch dashboard data');
      isLoading.value = true;
      hasError.value = false;

      // Charger toutes les données en parallèle
      final futures = await Future.wait([
        DashboardService.getDashboardStatistics(),
        DashboardService.getRevenueChartData(),
        OrderService.getOrdersByStatus(),
        OrderService.getRecentOrders(),
      ]);

      print('[DashboardController] All data fetched, processing results');

      // Traiter les résultats
      final stats = futures[0] as Map<String, dynamic>;
      totalRevenue.value = (stats['totalRevenue'] as num?)?.toDouble() ?? 0.0;
      totalOrders.value = (stats['totalOrders'] as num?)?.toInt() ?? 0;
      totalCustomers.value = (stats['totalCustomers'] as num?)?.toInt() ?? 0;

      final chartData = futures[1] as Map<String, dynamic>;
      revenueChartData.value = {
        'labels': List<String>.from(chartData['labels'] ?? []),
        'data': List<double>.from(
            chartData['data']?.map((e) => (e as num).toDouble()) ?? []),
      };

      orderStatusCount.value = futures[2] as Map<String, int>;
      recentOrders.value = futures[3] as List<Order>;

      print('[DashboardController] Dashboard data updated successfully');
      print('Revenue: ${totalRevenue.value}');
      print('Orders: ${totalOrders.value}');
      print('Customers: ${totalCustomers.value}');
    } catch (e) {
      print('[DashboardController] Error fetching dashboard data: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des données';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> configureCommissions({
    required double commissionRate,
    required int rewardPoints,
  }) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      await DashboardService.configureCommissions(
        commissionRate: commissionRate,
        rewardPoints: rewardPoints,
      );

      Get.snackbar(
        'Succès',
        'Configuration des commissions mise à jour',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );

      // Rafraîchir les données après la mise à jour
      await fetchDashboardData();
    } catch (e) {
      print('[DashboardController] Error configuring commissions: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors de la configuration';

      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour la configuration',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> configureRewards({
    required int rewardPoints,
    required String rewardType,
  }) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      await DashboardService.configureRewards(
        rewardPoints: rewardPoints,
        rewardType: rewardType,
      );

      Get.snackbar(
        'Succès',
        'Configuration des récompenses mise à jour',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );

      // Rafraîchir les données après la mise à jour
      await fetchDashboardData();
    } catch (e) {
      print('[DashboardController] Error configuring rewards: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors de la configuration';

      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour la configuration',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboard() async {
    await fetchDashboardData();
  }

  // Helpers pour l'accès aux données du graphique
  List<String> get chartLabels =>
      revenueChartData.value['labels'] as List<String>;
  List<double> get chartData => revenueChartData.value['data'] as List<double>;

  // Helper pour obtenir le statut d'une commande
  int getOrderCountByStatus(String status) => orderStatusCount[status] ?? 0;
}
