import 'dart:ui';
import 'package:get/get.dart';
import '../models/order.dart';
import '../services/dashboard_service.dart';
import '../models/chart_data.dart';
import '../constants.dart';
import '../utils/error_handler.dart';
import '../services/auth_service.dart';

class DashboardController extends GetxController {
  // États observables
  final isLoading = false.obs;
  final orders = <Order>[].obs;
  final statistics = <String, dynamic>{}.obs;
  final ordersByStatus = <String, int>{}.obs;
  final recentOrders = <Order>[].obs;
  final totalRevenue = 0.0.obs;
  final totalOrders = 0.obs;
  final totalCustomers = 0.obs;
  final revenueChartLabels = <String>[].obs;
  final revenueChartData = <double>[].obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  bool get isAuthenticated => AuthService.token != null;

  @override
  void onInit() {
    print('[DashboardController] Initializing');
    super.onInit();
  }

  @override
  void onReady() {
    print('[DashboardController] Ready, checking authentication');
    super.onReady();
    if (isAuthenticated) {
      print('[DashboardController] User is authenticated, fetching data');
      fetchDashboardData();
    } else {
      print(
          '[DashboardController] User is not authenticated, skipping data fetch');
    }
  }

  Future<void> fetchDashboardData() async {
    if (!isAuthenticated) {
      print('[DashboardController] Not authenticated, skipping data fetch');
      return;
    }

    try {
      print('[DashboardController] Fetching dashboard data');
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      await Future.wait([
        fetchStatistics(),
        fetchRecentOrders(),
        fetchOrdersByStatus(),
        fetchRevenueChartData(),
      ]);

      print('[DashboardController] Dashboard data fetched successfully');
    } catch (e) {
      print('[DashboardController] Error fetching dashboard data: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des données';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStatistics() async {
    try {
      print('[DashboardController] Fetching statistics');
      final data = await DashboardService.getStatistics();
      totalRevenue.value = (data['totalRevenue'] ?? 0.0).toDouble();
      totalOrders.value = data['totalOrders'] ?? 0;
      totalCustomers.value = data['totalCustomers'] ?? 0;

      if (data['recentOrders'] != null) {
        try {
          recentOrders.value = (data['recentOrders'] as List)
              .where((order) => order != null)
              .map((order) => Order.fromJson(order as Map<String, dynamic>))
              .toList();
        } catch (e) {
          print('[DashboardController] Error parsing recent orders: $e');
          recentOrders.value = [];
        }
      }

      if (data['ordersByStatus'] != null) {
        try {
          ordersByStatus.value = Map<String, int>.from(data['ordersByStatus']
              .map((key, value) => MapEntry(
                  key.toString(), int.tryParse(value.toString()) ?? 0)));
        } catch (e) {
          print('[DashboardController] Error parsing orders by status: $e');
          ordersByStatus.value = {};
        }
      }
    } catch (e) {
      print('[DashboardController] Error in fetchStatistics: $e');
      rethrow;
    }
  }

  Future<void> fetchRecentOrders() async {
    try {
      print('[DashboardController] Fetching recent orders');
      final data = await DashboardService.getRecentOrders();
      recentOrders.value = data.map((order) => Order.fromJson(order)).toList();
    } catch (e) {
      print('[DashboardController] Error fetching recent orders: $e');
      rethrow;
    }
  }

  Future<void> fetchRevenueChartData() async {
    try {
      print('[DashboardController] Fetching revenue chart data');
      final data = await DashboardService.getRevenueChart();
      if (data.containsKey('labels') && data.containsKey('data')) {
        revenueChartLabels.value = List<String>.from(data['labels']);
        revenueChartData.value = List<double>.from(
            (data['data'] as List).map((value) => (value as num).toDouble()));
      }
    } catch (e) {
      print('[DashboardController] Error fetching revenue chart data: $e');
      revenueChartLabels.value = [];
      revenueChartData.value = [];
      rethrow;
    }
  }

  Future<void> fetchOrdersByStatus() async {
    try {
      print('[DashboardController] Fetching orders by status');
      final data = await DashboardService.getOrdersByStatus();
      ordersByStatus.value = data;
    } catch (e) {
      print('[DashboardController] Error fetching orders by status: $e');
      rethrow;
    }
  }

  // Méthodes pour les graphiques
  List<ChartData> getOrdersChartData() {
    return ordersByStatus.entries
        .map((entry) => ChartData(
              label: entry.key,
              value: entry.value.toDouble(),
              color: _getStatusColor(entry.key),
            ))
        .toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return AppColors.warning;
      case 'COLLECTING':
        return AppColors.primary;
      case 'COLLECTED':
        return AppColors.primaryLight;
      case 'PROCESSING':
        return AppColors.primary;
      case 'READY':
        return AppColors.success;
      case 'DELIVERING':
        return AppColors.primary;
      case 'DELIVERED':
        return AppColors.success;
      case 'CANCELLED':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
