import 'api_service.dart';

class DashboardService {
  static Future<Map<String, dynamic>> getStatistics() async {
    final response = await ApiService.get('admin/statistics');
    return response['data'];
  }

  static Future<List<Map<String, dynamic>>> getRecentOrders() async {
    final response = await ApiService.get('orders/recent');
    return List<Map<String, dynamic>>.from(response['data']);
  }

  static Future<Map<String, int>> getOrdersByStatus() async {
    final response = await ApiService.get('orders/by-status');
    return Map<String, int>.from(response['data']);
  }
}
