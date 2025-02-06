import './api_service.dart';

class DashboardService {
  static const String _baseUrl = '/api/admin'; // Corriger le chemin
  static final ApiService _api = ApiService();

  static Future<Map<String, dynamic>> getDashboardStatistics() async {
    try {
      print('[DashboardService] Fetching statistics...');
      final response = await _api.get('$_baseUrl/statistics');

      if (response.statusCode == 404) {
        print('[DashboardService] Statistics endpoint not found');
        return _getFallbackStatistics();
      }

      if (response.data != null && response.data['data'] != null) {
        final data = response.data['data'];
        print('[DashboardService] Raw statistics data: $data');

        return {
          'totalRevenue': double.parse((data['totalRevenue'] ?? 0).toString()),
          'totalOrders':
              int.tryParse(data['totalOrders']?.toString() ?? '0') ?? 0,
          'totalCustomers':
              int.tryParse(data['totalCustomers']?.toString() ?? '0') ?? 0,
          'recentOrders': data['recentOrders'] ?? [],
          'ordersByStatus': data['ordersByStatus'] ?? {},
        };
      }
      return _getFallbackStatistics();
    } catch (e) {
      print('[DashboardService] Error getting statistics: $e');
      return _getFallbackStatistics();
    }
  }

  // Méthode de secours pour fournir des données par défaut
  static Map<String, dynamic> _getFallbackStatistics() {
    return {
      'totalRevenue': 0.0,
      'totalOrders': 0,
      'totalCustomers': 0,
      'recentOrders': [],
      'ordersByStatus': {
        'PENDING': 0,
        'PROCESSING': 0,
        'DELIVERED': 0,
      }
    };
  }

  static Future<Map<String, dynamic>> getRevenueChartData() async {
    try {
      final response = await _api.get('$_baseUrl/revenue-chart');
      return response.data['data'];
    } catch (e) {
      print('[DashboardService] Error getting revenue chart: $e');
      rethrow;
    }
  }

  static Future<double> getTotalRevenue() async {
    try {
      final response = await _api.get('$_baseUrl/total-revenue');
      return (response.data['data'] as num).toDouble();
    } catch (e) {
      print('[DashboardService] Error getting total revenue: $e');
      rethrow;
    }
  }

  static Future<int> getTotalCustomers() async {
    try {
      final response = await _api.get('$_baseUrl/total-customers');
      return response.data['data'];
    } catch (e) {
      print('[DashboardService] Error getting total customers: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getRecentOrders() async {
    try {
      // Correction de l'URL pour correspondre au backend
      final response =
          await _api.get('/orders/recent', queryParameters: {'limit': '5'});

      if (response.data != null && response.data['data'] != null) {
        return {
          'orders': response.data['data'],
        };
      }
      return {'orders': []};
    } catch (e) {
      print('[DashboardService] Error getting recent orders: $e');
      return {'orders': []};
    }
  }

  static Future<Map<String, int>> getOrdersByStatus() async {
    try {
      // Correction de l'URL pour correspondre au backend
      final response = await _api.get('/orders/by-status');

      if (response.data != null && response.data['data'] != null) {
        return Map<String, int>.from(response.data['data']);
      }
      return {};
    } catch (e) {
      print('[DashboardService] Error getting orders by status: $e');
      return {};
    }
  }

  static Future<void> configureCommissions({
    required double commissionRate,
    required int rewardPoints,
  }) async {
    try {
      await _api.post(
        '$_baseUrl/configure-commissions',
        data: {
          'commissionRate': commissionRate,
          'rewardPoints': rewardPoints,
        },
      );
    } catch (e) {
      print('[DashboardService] Error configuring commissions: $e');
      throw 'Erreur lors de la configuration des commissions';
    }
  }

  static Future<void> configureRewards({
    required int rewardPoints,
    required String rewardType,
  }) async {
    try {
      await _api.post(
        '$_baseUrl/configure-rewards',
        data: {
          'rewardPoints': rewardPoints,
          'rewardType': rewardType,
        },
      );
    } catch (e) {
      print('[DashboardService] Error configuring rewards: $e');
      throw 'Erreur lors de la configuration des récompenses';
    }
  }

  static Future<Map<String, dynamic>> updateAffiliateStatus({
    required String affiliateId,
    required String status,
    required bool isActive,
  }) async {
    try {
      final response = await _api.patch(
        '$_baseUrl/affiliates/$affiliateId/status',
        data: {
          'status': status,
          'isActive': isActive,
        },
      );

      if (response.data != null && response.data['data'] != null) {
        return response.data['data'];
      }
      throw 'Erreur lors de la mise à jour du statut';
    } catch (e) {
      print('[DashboardService] Error updating affiliate status: $e');
      throw 'Erreur lors de la mise à jour du statut';
    }
  }
}
