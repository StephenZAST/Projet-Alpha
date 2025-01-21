import 'api_service.dart';
import '../models/admin_notification.dart';

class NotificationService {
  static Future<List<AdminNotification>> getAdminNotifications() async {
    final response = await ApiService.get('notifications');
    return (response['data'] as List)
        .map((json) => AdminNotification.fromJson(json))
        .toList();
  }

  static Future<void> markAsRead(String notificationId) async {
    await ApiService.post('admin/notifications/$notificationId/read', {});
  }

  static Future<void> markAllAsRead() async {
    await ApiService.post('admin/notifications/mark-all-read', {});
  }
}
