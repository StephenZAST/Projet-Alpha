import '../models/admin_notification.dart';
import './api_service.dart';

class NotificationService {
  static const String _baseUrl =
      '/api/notifications'; // Modifier le chemin de base
  static final ApiService _api = ApiService();

  static Future<List<AdminNotification>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _api.get(
        _baseUrl,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 404) {
        print('[NotificationService] Endpoint not found');
        return [];
      }

      if (response.data != null && response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((item) => AdminNotification.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('[NotificationService] Error getting notifications: $e');
      return [];
    }
  }

  static Future<int> getUnreadCount() async {
    try {
      final response =
          await _api.get('$_baseUrl/unread/count'); // Modifier le chemin

      if (response.statusCode == 404) {
        return 0;
      }

      if (response.data != null && response.data['data'] != null) {
        return response.data['data']['count'] ?? 0;
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
        '$_baseUrl/$notificationId/read',
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
        '$_baseUrl/mark-all-read',
        data: {},
      );
    } catch (e) {
      print('[NotificationService] Error marking all as read: $e');
      throw 'Erreur lors du marquage des notifications';
    }
  }

  static Future<void> deleteNotification(String notificationId) async {
    try {
      await _api.delete('$_baseUrl/$notificationId');
    } catch (e) {
      print('[NotificationService] Error deleting notification: $e');
      throw 'Erreur lors de la suppression de la notification';
    }
  }

  static Future<Map<String, dynamic>> getPreferences() async {
    try {
      final response = await _api.get('$_baseUrl/preferences');
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
        '$_baseUrl/preferences',
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
