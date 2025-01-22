import 'dart:ui';

import 'package:get/get.dart';
import '../models/order.dart';
import '../services/dashboard_service.dart';
import '../models/chart_data.dart';
import '../constants.dart';
import '../utils/error_handler.dart';

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

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        fetchStatistics(),
        fetchRecentOrders(),
        fetchOrdersByStatus(),
        fetchRevenueChartData(),
      ]);
    } catch (e) {
      print('Error fetching dashboard data: $e');
      Get.snackbar(
        'Error',
        'Failed to load dashboard data',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStatistics() async {
    try {
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
          print('Error parsing recent orders: $e');
          recentOrders.value = [];
        }
      }

      if (data['ordersByStatus'] != null) {
        try {
          ordersByStatus.value = Map<String, int>.from(data['ordersByStatus']
              .map((key, value) => MapEntry(
                  key.toString(), int.tryParse(value.toString()) ?? 0)));
        } catch (e) {
          print('Error parsing orders by status: $e');
          ordersByStatus.value = {};
        }
      }
    } catch (e) {
      print('Error in fetchStatistics: $e');
    }
  }

  Future<void> fetchRecentOrders() async {
    try {
      final data = await DashboardService.getRecentOrders();
      recentOrders.value = data.map((order) => Order.fromJson(order)).toList();
    } catch (e) {
      print('Error fetching recent orders: $e');
    }
  }

  Future<void> fetchRevenueChartData() async {
    try {
      final data = await DashboardService.getRevenueChart();
      if (data.containsKey('labels') && data.containsKey('data')) {
        revenueChartLabels.value = List<String>.from(data['labels']);
        revenueChartData.value = List<double>.from(
            (data['data'] as List).map((value) => (value as num).toDouble()));
      }
    } catch (e) {
      print('Error fetching revenue chart data: $e');
      // En cas d'erreur, initialiser avec des listes vides
      revenueChartLabels.value = [];
      revenueChartData.value = [];
    }
  }

  Future<void> fetchOrdersByStatus() async {
    try {
      final data = await DashboardService.getOrdersByStatus();
      ordersByStatus.value = data;
    } catch (e) {
      print('Error fetching orders by status: $e');
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
