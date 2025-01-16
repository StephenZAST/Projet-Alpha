import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

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
}
