import 'api_service.dart';
import '../constants.dart';
import 'package:get/get.dart';

class DashboardService {
  static const String baseAdminPath = 'admin';
  static const String baseOrderPath = 'orders';

  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      print('[DashboardService] Fetching statistics...');
      final response = await ApiService.get('$baseAdminPath/statistics');
      print('[DashboardService] Statistics response: $response');

      if (!response['success']) {
        throw response['message'] ?? 'Failed to fetch statistics';
      }

      if (response['data'] == null) {
        throw 'Invalid response format';
      }

      return response['data'];
    } catch (e) {
      print('[DashboardService] Error fetching statistics: $e');
      _showError('Erreur de chargement des statistiques', e.toString());

      // Retourner des données par défaut en cas d'erreur
      return {
        'totalRevenue': 0.0,
        'totalOrders': 0,
        'totalCustomers': 0,
        'recentOrders': [],
        'ordersByStatus': {},
      };
    }
  }

  static Future<List<Map<String, dynamic>>> getRecentOrders() async {
    try {
      print('[DashboardService] Fetching recent orders...');
      final response = await ApiService.get('$baseOrderPath/recent');
      print('[DashboardService] Recent orders response: $response');

      if (!response['success']) {
        throw response['message'] ?? 'Failed to fetch recent orders';
      }

      if (response['data'] == null) {
        return [];
      }

      return List<Map<String, dynamic>>.from(response['data']);
    } catch (e) {
      print('[DashboardService] Error fetching recent orders: $e');
      _showError('Erreur de chargement des commandes récentes', e.toString());
      return [];
    }
  }

  static Future<Map<String, int>> getOrdersByStatus() async {
    try {
      print('[DashboardService] Fetching orders by status...');
      final response = await ApiService.get('$baseOrderPath/by-status');
      print('[DashboardService] Orders by status response: $response');

      if (!response['success']) {
        throw response['message'] ?? 'Failed to fetch orders by status';
      }

      if (response['data'] == null) {
        return {};
      }

      final data = response['data'] as Map<String, dynamic>;
      return data.map(
          (key, value) => MapEntry(key, int.tryParse(value.toString()) ?? 0));
    } catch (e) {
      print('[DashboardService] Error fetching orders by status: $e');
      _showError('Erreur de chargement des statuts de commandes', e.toString());
      return {};
    }
  }

  static Future<Map<String, dynamic>> getRevenueChart() async {
    try {
      print('[DashboardService] Fetching revenue chart data...');
      final response = await ApiService.get('$baseAdminPath/revenue-chart');
      print('[DashboardService] Revenue chart response: $response');

      if (!response['success']) {
        throw response['message'] ?? 'Failed to fetch revenue chart data';
      }

      if (response['data'] == null) {
        return {};
      }

      return response['data'];
    } catch (e) {
      print('[DashboardService] Error fetching revenue chart: $e');
      _showError('Erreur de chargement des données de revenus', e.toString());
      return {};
    }
  }

  static void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.error,
      colorText: AppColors.textLight,
      snackPosition: SnackPosition.TOP,
      padding: AppSpacing.paddingMD,
      margin: AppSpacing.marginMD,
      borderRadius: AppRadius.sm,
      duration: Duration(seconds: 4),
    );
  }
}
