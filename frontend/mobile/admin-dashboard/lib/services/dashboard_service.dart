import './api_service.dart';

class DashboardService {
  static final _api = ApiService();

  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await _api.get('/admin/statistics');
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'];
      }
      throw 'Erreur lors du chargement des statistiques';
    } catch (e) {
      print('[DashboardService] Error getting statistics: $e');
      throw 'Erreur lors du chargement des statistiques';
    }
  }

  static Future<Map<String, dynamic>> getRecentOrders() async {
    try {
      final response = await _api.get('/admin/orders/recent');
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'];
      }
      throw 'Erreur lors du chargement des commandes récentes';
    } catch (e) {
      print('[DashboardService] Error getting recent orders: $e');
      throw 'Erreur lors du chargement des commandes récentes';
    }
  }

  static Future<Map<String, dynamic>> getRevenueChartData() async {
    try {
      final response = await _api.get('/admin/revenue-chart');
      if (response.data != null && response.data['data'] != null) {
        final data = response.data['data'];
        if (data['labels'] != null && data['data'] != null) {
          return {
            'labels': List<String>.from(data['labels']),
            'data': List<double>.from(
                data['data'].map((d) => (d as num).toDouble())),
          };
        }
      }
      throw 'Erreur lors du chargement des données du graphique';
    } catch (e) {
      print('[DashboardService] Error getting revenue chart data: $e');
      throw 'Erreur lors du chargement des données du graphique';
    }
  }

  static Future<Map<String, int>> getOrdersByStatus() async {
    try {
      final response = await _api.get('/admin/orders/by-status');
      if (response.data != null && response.data['data'] != null) {
        final Map<String, dynamic> data = response.data['data'];
        return Map<String, int>.from(data);
      }
      return {};
    } catch (e) {
      print('[DashboardService] Error getting orders by status: $e');
      throw 'Erreur lors du chargement des statuts de commandes';
    }
  }

  static Future<void> configureCommissions({
    required double commissionRate,
    required int rewardPoints,
  }) async {
    try {
      await _api.put('/admin/config/commissions', data: {
        'commissionRate': commissionRate,
        'rewardPoints': rewardPoints,
      });
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
      await _api.put('/admin/config/rewards', data: {
        'rewardPoints': rewardPoints,
        'rewardType': rewardType,
      });
    } catch (e) {
      print('[DashboardService] Error configuring rewards: $e');
      throw 'Erreur lors de la configuration des récompenses';
    }
  }

  static Future<Map<String, dynamic>> getTotalRevenue() async {
    try {
      final response = await _api.get('/admin/revenue/total');
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'];
      }
      throw 'Erreur lors du chargement des revenus';
    } catch (e) {
      print('[DashboardService] Error getting total revenue: $e');
      throw 'Erreur lors du chargement des revenus';
    }
  }

  static Future<Map<String, dynamic>> updateAffiliateStatus({
    required String affiliateId,
    required String status,
    required bool isActive,
  }) async {
    try {
      final response = await _api.put(
        '/admin/affiliates/$affiliateId/status',
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
