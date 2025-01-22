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
}
