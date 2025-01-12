import '../states/notification_state.dart';
import '../actions/notification_actions.dart';

NotificationState notificationReducer(NotificationState state, dynamic action) {
  if (action is ShowNotificationAction) {
    final newNotification = {
      'id': DateTime.now().toString(),
      'message': action.message,
      'type': action.type.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    return state.copyWith(
      currentNotification: newNotification,
      notifications: [...state.notifications, newNotification],
    );
  }

  if (action is DismissNotificationAction) {
    return state.copyWith(
      currentNotification: null,
      notifications: action.id != null
          ? state.notifications.where((n) => n['id'] != action.id).toList()
          : state.notifications,
    );
  }

  // ...rest of notification actions handling...

  return state;
}
