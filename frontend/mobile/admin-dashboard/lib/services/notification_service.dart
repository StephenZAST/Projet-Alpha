import '../models/admin_notification.dart';

class NotificationService {
  static Future<List<AdminNotification>> getAdminNotifications() async {
    // TODO: Implement API call
    return [
      AdminNotification(
        id: '1',
        title: 'New Order',
        message: 'You have a new order.',
        createdAt: DateTime.now().subtract(Duration(minutes: 5)),
        type: 'ORDER',
      ),
      // ...other notifications...
    ];
  }
}
