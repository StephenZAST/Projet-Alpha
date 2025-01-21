import 'dart:ui';

import 'package:get/get.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../models/chart_data.dart';
import '../constants.dart';

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
      ]);
    } catch (e) {
      print('Error fetching dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStatistics() async {
    try {
      final response = await ApiService.get('admin/statistics');
      statistics.value = response['data'];
      totalRevenue.value = response['data']['totalRevenue'] ?? 0.0;
      totalOrders.value = response['data']['totalOrders'] ?? 0;
      totalCustomers.value = response['data']['totalCustomers'] ?? 0;
    } catch (e) {
      print('Error fetching statistics: $e');
    }
  }

  Future<void> fetchRecentOrders() async {
    try {
      final response = await ApiService.get('orders/recent');
      recentOrders.value = (response['data'] as List)
          .map((order) => Order.fromJson(order))
          .toList();
    } catch (e) {
      print('Error fetching recent orders: $e');
    }
  }

  Future<void> fetchOrdersByStatus() async {
    try {
      final response = await ApiService.get('orders/by-status');
      ordersByStatus.value = Map<String, int>.from(response['data']);
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
