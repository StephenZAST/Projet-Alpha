import 'api_service.dart';

class DashboardService {
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      print('Fetching statistics...');
      final response = await ApiService.get('/admin/statistics');
      print('Statistics response: $response');
      return response['data'];
    } catch (e) {
      print('Error fetching statistics: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getRecentOrders() async {
    try {
      print('Fetching recent orders...');
      final response = await ApiService.get('/orders/recent');
      print('Recent orders response: $response');
      return List<Map<String, dynamic>>.from(response['data']);
    } catch (e) {
      print('Error fetching recent orders: $e');
      rethrow;
    }
  }

  static Future<Map<String, int>> getOrdersByStatus() async {
    try {
      final response = await ApiService.get('/orders/by-status');
      final data = response['data'] as Map<String, dynamic>;
      return data
          .map((key, value) => MapEntry(key, int.parse(value.toString())));
    } catch (e) {
      print('Error parsing order status: $e');
      return {};
    }
  }
}
