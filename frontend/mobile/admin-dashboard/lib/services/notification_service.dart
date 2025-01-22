import 'package:get/get.dart';
import '../models/admin_notification.dart';
import './api_service.dart';

class NotificationService {
  static final _api = ApiService();
  static const String basePath = '/api/notifications';
  static const String adminBasePath = '/api/admin/notifications';

  // Méthodes spécifiques à l'admin
  static Future<List<AdminNotification>> getAdminNotifications() async {
    try {
      final response = await _api.get(adminBasePath);
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => AdminNotification.fromJson(json)).toList();
    } catch (e) {
      print('[NotificationService] Error getting admin notifications: $e');
      return [];
    }
  }

  static Future<bool> markAllAsRead() async {
    try {
      await _api.post(
        '$adminBasePath/mark-all-read',
        data: {},
      );
      return true;
    } catch (e) {
      print(
          '[NotificationService] Error marking all notifications as read: $e');
      return false;
    }
  }

  // Méthodes génériques pour notifications
  static Future<List<AdminNotification>> getNotifications() async {
    try {
      final response = await _api.get(basePath);
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => AdminNotification.fromJson(json)).toList();
    } catch (e) {
      print('[NotificationService] Error getting notifications: $e');
      return [];
    }
  }

  static Future<bool> markAsRead(String notificationId) async {
    try {
      await _api.post(
        '$basePath/$notificationId/read',
        data: {},
      );
      return true;
    } catch (e) {
      print('[NotificationService] Error marking notification as read: $e');
      return false;
    }
  }

  static Future<bool> deleteNotification(String notificationId) async {
    try {
      await _api.post(
        '$basePath/$notificationId/delete',
        data: {},
      );
      return true;
    } catch (e) {
      print('[NotificationService] Error deleting notification: $e');
      return false;
    }
  }

  // Méthodes utilitaires
  static String formatNotificationTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
