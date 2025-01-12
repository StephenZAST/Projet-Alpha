enum NotificationType { success, error, warning, info }

class ShowNotificationAction {
  final String message;
  final NotificationType type;
  final Duration? duration;

  ShowNotificationAction({
    required this.message,
    this.type = NotificationType.info,
    this.duration = const Duration(seconds: 3),
  });
}

class DismissNotificationAction {
  final String? id;
  DismissNotificationAction([this.id]);
}

class FetchNotificationsAction {}

class FetchNotificationsSuccessAction {
  final List<Map<String, dynamic>> notifications;
  FetchNotificationsSuccessAction(this.notifications);
}

class FetchNotificationsFailureAction {
  final String error;
  FetchNotificationsFailureAction(this.error);
}
