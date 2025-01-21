import 'api_service.dart';

class DashboardService {
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      print('Fetching statistics...');
      final response = await ApiService.get('admin/statistics');
      print('Statistics response: $response');
      if (response == null || response['data'] == null) {
        throw 'Invalid response format';
      }
      return response['data'];
    } catch (e) {
      print('Error fetching statistics: $e');
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
      print('Fetching recent orders...');
      final response = await ApiService.get('orders/recent');
      print('Recent orders response: $response');
      if (response == null || response['data'] == null) {
        return [];
      }
      return List<Map<String, dynamic>>.from(response['data']);
    } catch (e) {
      print('Error fetching recent orders: $e');
      return [];
    }
  }

  static Future<Map<String, int>> getOrdersByStatus() async {
    try {
      final response = await ApiService.get('orders/by-status');
      if (response == null || response['data'] == null) {
        return {};
      }
      final data = response['data'] as Map<String, dynamic>;
      return data.map(
          (key, value) => MapEntry(key, int.tryParse(value.toString()) ?? 0));
    } catch (e) {
      print('Error parsing order status: $e');
      return {};
    }
  }
}
