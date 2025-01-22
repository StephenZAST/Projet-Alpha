import 'package:get/get.dart';
import '../models/order.dart';
import '../services/dashboard_service.dart';
import '../constants.dart';

class DashboardController extends GetxController {
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Statistiques générales
  final totalRevenue = 0.0.obs;
  final totalOrders = 0.obs;
  final totalCustomers = 0.obs;

  // Données pour les graphiques
  final revenueChartData = <String, List<dynamic>>{}.obs;
  final orderStatusCount = <String, int>{}.obs;

  // Commandes récentes
  final recentOrders = <Order>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Récupérer les statistiques générales
      final stats = await DashboardService.getStatistics();
      totalRevenue.value = (stats['totalRevenue'] as num).toDouble();
      totalOrders.value = stats['totalOrders'] as int;
      totalCustomers.value = stats['totalCustomers'] as int;

      // Récupérer les commandes par statut
      final statusData = await DashboardService.getOrdersByStatus();
      orderStatusCount.value = statusData;

      // Récupérer les commandes récentes
      final recentData = await DashboardService.getRecentOrders();
      recentOrders.value = (recentData['orders'] as List)
          .map((json) => Order.fromJson(json))
          .toList();

      // Récupérer les données du graphique de revenus
      final chartData = await DashboardService.getRevenueChartData();
      revenueChartData.value = {
        'labels': chartData['labels'] as List<String>,
        'data': (chartData['data'] as List)
            .map((e) => (e as num).toDouble())
            .toList(),
      };
    } catch (e) {
      print('[DashboardController] Error fetching dashboard data: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des données';

      Get.snackbar(
        'Erreur',
        'Impossible de charger les données du tableau de bord',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
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
}
