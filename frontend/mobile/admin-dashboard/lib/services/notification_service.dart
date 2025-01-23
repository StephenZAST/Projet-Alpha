import '../models/admin_notification.dart';
import './api_service.dart';

class NotificationService {
  static final _api = ApiService();
  static const String basePath = '/notifications';

  static Future<List<AdminNotification>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _api.get(
        basePath,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.data != null && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => AdminNotification.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('[NotificationService] Error getting notifications: $e');
      throw 'Erreur lors du chargement des notifications';
    }
  }

  static Future<int> getUnreadCount() async {
    try {
      final response = await _api.get('$basePath/unread');
      if (response.data != null && response.data['count'] != null) {
        return response.data['count'] as int;
      }
      return 0;
    } catch (e) {
      print('[NotificationService] Error getting unread count: $e');
      return 0;
    }
  }

  static Future<void> markAsRead(String notificationId) async {
    try {
      await _api.patch(
        '$basePath/$notificationId/read',
        data: {},
      );
    } catch (e) {
      print('[NotificationService] Error marking notification as read: $e');
      throw 'Erreur lors du marquage de la notification';
    }
  }

  static Future<void> markAllAsRead() async {
    try {
      await _api.post(
        '$basePath/mark-all-read',
        data: {},
      );
    } catch (e) {
      print('[NotificationService] Error marking all as read: $e');
      throw 'Erreur lors du marquage des notifications';
    }
  }

  static Future<void> deleteNotification(String notificationId) async {
    try {
      await _api.delete('$basePath/$notificationId');
    } catch (e) {
      print('[NotificationService] Error deleting notification: $e');
      throw 'Erreur lors de la suppression de la notification';
    }
  }

  static Future<Map<String, dynamic>> getPreferences() async {
    try {
      final response = await _api.get('$basePath/preferences');
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      print('[NotificationService] Error getting preferences: $e');
      throw 'Erreur lors du chargement des préférences';
    }
  }

  static Future<void> updatePreferences(
      Map<String, dynamic> preferences) async {
    try {
      await _api.put(
        '$basePath/preferences',
        data: preferences,
      );
    } catch (e) {
      print('[NotificationService] Error updating preferences: $e');
      throw 'Erreur lors de la mise à jour des préférences';
    }
  }

  // Méthodes utilitaires
  static String formatNotificationTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return 'Il y a $minutes ${minutes > 1 ? 'minutes' : 'minute'}';
    } else if (difference.inDays < 1) {
      final hours = difference.inHours;
      return 'Il y a $hours ${hours > 1 ? 'heures' : 'heure'}';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'Il y a $days ${days > 1 ? 'jours' : 'jour'}';
    } else {
      return '${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')}/${time.year}';
    }
  }
}
