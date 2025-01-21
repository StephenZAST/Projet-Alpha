import 'api_service.dart';
import '../models/admin.dart';
import '../models/dashboard_stats.dart';

class AdminService {
  static Future<Admin> updateProfile(AdminUpdateDTO dto) async {
    final response = await ApiService.put('admin/profile', dto.toJson());
    return Admin.fromJson(response['data']);
  }

  static Future<DashboardStats> getDashboardStats() async {
    final response = await ApiService.get('admin/dashboard/stats');
    return DashboardStats.fromJson(response['data']);
  }

  static Future<void> updatePassword(
      String currentPassword, String newPassword) async {
    await ApiService.post('admin/change-password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  static Future<void> updateSettings(Map<String, dynamic> settings) async {
    await ApiService.put('admin/settings', settings);
  }
}
