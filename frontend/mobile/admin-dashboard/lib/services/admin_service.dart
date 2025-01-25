import './api_service.dart';

class AdminService {
  static final _api = ApiService();

  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> data) async {
    try {
      final response = await _api.put(
        '/admin/profile',
        data: data,
      );
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'];
      }
      throw 'Erreur lors de la mise à jour du profil';
    } catch (e) {
      print('[AdminService] Error updating profile: $e');
      throw 'Erreur lors de la mise à jour du profil';
    }
  }

  static Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await _api.get('/admin/statistics');
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'];
      }
      throw 'Erreur lors du chargement des statistiques';
    } catch (e) {
      print('[AdminService] Error getting dashboard data: $e');
      throw 'Erreur lors du chargement des statistiques';
    }
  }

  static Future<Map<String, dynamic>> exportData(String type) async {
    try {
      final response = await _api.post(
        '/admin/export',
        data: {'type': type},
      );
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'];
      }
      throw 'Erreur lors de l\'export des données';
    } catch (e) {
      print('[AdminService] Error exporting data: $e');
      throw 'Erreur lors de l\'export des données';
    }
  }

  static Future<void> updateSystemSettings(
      Map<String, dynamic> settings) async {
    try {
      await _api.put(
        '/admin/settings',
        data: settings,
      );
    } catch (e) {
      print('[AdminService] Error updating system settings: $e');
      throw 'Erreur lors de la mise à jour des paramètres';
    }
  }

  static Future<Map<String, dynamic>> getSystemActivity() async {
    try {
      final response = await _api.get('/admin/activity');
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'];
      }
      throw 'Erreur lors du chargement de l\'activité';
    } catch (e) {
      print('[AdminService] Error getting system activity: $e');
      throw 'Erreur lors du chargement de l\'activité';
    }
  }

  static Future<List<Map<String, dynamic>>> getAdminUsers() async {
    try {
      final response = await _api.get('/admin/users');
      if (response.data != null && response.data['data'] != null) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      print('[AdminService] Error getting admin users: $e');
      throw 'Erreur lors du chargement des administrateurs';
    }
  }

  static Future<void> updateAdminUser(
      String userId, Map<String, dynamic> data) async {
    try {
      await _api.put(
        '/admin/users/$userId',
        data: data,
      );
    } catch (e) {
      print('[AdminService] Error updating admin user: $e');
      throw 'Erreur lors de la mise à jour de l\'administrateur';
    }
  }

  // Nouvelles méthodes pour la gestion des affiliés
  static Future<Map<String, dynamic>> getAllAffiliates({
    int page = 1,
    int limit = 50,
    String? status,
    String? query,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
        if (query != null && query.isNotEmpty) 'query': query,
      };

      final response = await _api.get(
        '/admin/affiliates',
        queryParameters: queryParams,
      );

      if (response.data != null && response.data['data'] != null) {
        return {
          'affiliates': response.data['data'],
          'total': response.data['pagination']['total'],
          'currentPage': page,
          'totalPages': response.data['pagination']['totalPages'],
        };
      }
      throw 'Erreur lors du chargement des affiliés';
    } catch (e) {
      print('[AdminService] Error getting affiliates: $e');
      throw 'Erreur lors du chargement des affiliés';
    }
  }

  static Future<void> updateAffiliateStatus(
    String affiliateId,
    String status,
    bool isActive,
  ) async {
    try {
      await _api.patch(
        '/admin/affiliates/$affiliateId/status',
        data: {
          'status': status,
          'isActive': isActive,
        },
      );
    } catch (e) {
      print('[AdminService] Error updating affiliate status: $e');
      throw 'Erreur lors de la mise à jour du statut';
    }
  }

  static Future<Map<String, dynamic>> getAffiliateStats() async {
    try {
      final response = await _api.get('/admin/affiliates/stats');
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'];
      }
      throw 'Erreur lors du chargement des statistiques affiliés';
    } catch (e) {
      print('[AdminService] Error getting affiliate stats: $e');
      throw 'Erreur lors du chargement des statistiques affiliés';
    }
  }

  static Future<void> approveWithdrawal(String withdrawalId) async {
    try {
      await _api.patch('/admin/withdrawals/$withdrawalId/approve');
    } catch (e) {
      print('[AdminService] Error approving withdrawal: $e');
      throw 'Erreur lors de l\'approbation du retrait';
    }
  }

  static Future<void> rejectWithdrawal(
      String withdrawalId, String reason) async {
    try {
      await _api.patch(
        '/admin/withdrawals/$withdrawalId/reject',
        data: {'reason': reason},
      );
    } catch (e) {
      print('[AdminService] Error rejecting withdrawal: $e');
      throw 'Erreur lors du rejet du retrait';
    }
  }

  static Future<List<Map<String, dynamic>>> getWithdrawals() async {
    try {
      final response = await _api.get('/admin/withdrawals');
      if (response.data != null && response.data['data'] != null) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      print('[AdminService] Error getting withdrawals: $e');
      throw 'Erreur lors du chargement des demandes de retrait';
    }
  }

  static Future<void> configureCommissions(
    double commissionRate,
    int rewardPoints,
  ) async {
    try {
      await _api.put(
        '/admin/config/commissions',
        data: {
          'commissionRate': commissionRate,
          'rewardPoints': rewardPoints,
        },
      );
    } catch (e) {
      print('[AdminService] Error configuring commissions: $e');
      throw 'Erreur lors de la configuration des commissions';
    }
  }

  static Future<Map<String, dynamic>> getSystemConfig() async {
    try {
      final response = await _api.get('/admin/config');
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'];
      }
      throw 'Erreur lors du chargement de la configuration';
    } catch (e) {
      print('[AdminService] Error getting system config: $e');
      throw 'Erreur lors du chargement de la configuration';
    }
  }
}
