import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dio/dio.dart';
import '../models/notification.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final Dio _dio;

  NotificationService(this._dio);

  Future<void> initialize() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _notifications.initialize(initializationSettings);
  }

  Future<void> showOrderStatusNotification(
      String orderId, String status) async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'orders_channel',
        'Commandes',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      orderId.hashCode,
      'Mise à jour de commande',
      'Votre commande #$orderId est maintenant $status',
      notificationDetails,
    );
  }

  Future<List<Notification>> getNotifications(
      {int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/api/notifications',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Notification.fromJson(json)).toList();
      }

      throw Exception('Failed to load notifications');
    } catch (e) {
      print('Error loading notifications: $e');
      rethrow;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _dio.patch(
        '/api/notifications/$notificationId/read',
      );
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.post('/api/notifications/mark-all-read');
    } catch (e) {
      print('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/api/notifications/unread');
      return response.data['count'];
    } catch (e) {
      print('Error getting unread count: $e');
      rethrow;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _dio.delete('/api/notifications/$notificationId');
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }
}
