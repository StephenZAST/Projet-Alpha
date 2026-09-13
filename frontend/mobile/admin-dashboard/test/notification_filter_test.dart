import 'package:flutter_test/flutter_test.dart';
import 'package:admin/models/admin_notification.dart';

void main() {
  group('AdminNotification category filtering', () {
    test('order notifications resolve to order category', () {
      final notification = AdminNotification.fromJson({
        'id': 'n-1',
        'title': 'Nouvelle commande',
        'message': 'Une commande a été créée',
        'type': 'ORDER_CREATED',
        'createdAt': '2026-09-13T12:00:00Z',
        'priority': 'NORMAL',
      });

      expect(notification.categoryKey, 'order');
      expect(notification.matchesCategory('order'), isTrue);
      expect(notification.matchesCategory('system'), isFalse);
    });

    test('system notifications resolve to system category', () {
      final notification = AdminNotification.fromJson({
        'id': 'n-2',
        'title': 'Notification système',
        'message': 'Maintenance prévue',
        'type': 'SYSTEM',
        'createdAt': '2026-09-13T12:00:00Z',
        'priority': 'LOW',
      });

      expect(notification.categoryKey, 'system');
      expect(notification.matchesCategory('system'), isTrue);
      expect(notification.matchesCategory('order'), isFalse);
    });

    test('admin event notifications with generic type still resolve to their real category', () {
      final orderNotification = AdminNotification.fromJson({
        'id': 'n-3',
        'title': '🔔 NEW_ORDER_ALERT',
        'message': 'Événement système: NEW_ORDER_ALERT',
        'type': 'NOTIFICATION',
        'data': {
          'type': 'NEW_ORDER_ALERT',
          'orderId': 'abc123',
        },
        'createdAt': '2026-09-13T12:00:00Z',
        'priority': 'HIGH',
      });

      final userNotification = AdminNotification.fromJson({
        'id': 'n-4',
        'title': '👤 NEW_USER_REGISTERED',
        'message': 'Événement système: NEW_USER_REGISTERED',
        'type': 'NOTIFICATION',
        'data': {
          'type': 'NEW_USER_REGISTERED',
          'userId': 'user-42',
        },
        'createdAt': '2026-09-13T12:00:00Z',
        'priority': 'NORMAL',
      });

      expect(orderNotification.categoryKey, 'order');
      expect(orderNotification.matchesCategory('order'), isTrue);
      expect(orderNotification.matchesCategory('system'), isFalse);

      expect(userNotification.categoryKey, 'user');
      expect(userNotification.matchesCategory('user'), isTrue);
      expect(userNotification.matchesCategory('system'), isFalse);
    });
  });
}
