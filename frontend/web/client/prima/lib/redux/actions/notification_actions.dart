import 'package:flutter/material.dart';

enum NotificationType { success, error, warning, info }

class ShowNotificationAction {
  final String message;
  final NotificationType type;
  final Duration? duration;
  final IconData? icon;

  const ShowNotificationAction({
    required this.message,
    this.type = NotificationType.info,
    this.duration = const Duration(seconds: 3),
    this.icon,
  });
}

class DismissNotificationAction {
  final String? id;
  const DismissNotificationAction([this.id]);
}

class FetchNotificationsAction {
  const FetchNotificationsAction();
}

class FetchNotificationsSuccessAction {
  final List<Map<String, dynamic>> notifications;
  const FetchNotificationsSuccessAction(this.notifications);
}

class FetchNotificationsFailureAction {
  final String error;
  const FetchNotificationsFailureAction(this.error);
}

class MarkNotificationAsReadAction {
  final String id;
  const MarkNotificationAsReadAction(this.id);
}

class ClearAllNotificationsAction {
  const ClearAllNotificationsAction();
}

class UpdateNotificationSettingsAction {
  final bool enabled;
  final List<NotificationType> enabledTypes;

  const UpdateNotificationSettingsAction({
    required this.enabled,
    required this.enabledTypes,
  });
}

class NotificationReceivedAction {
  final Map<String, dynamic> notification;
  const NotificationReceivedAction(this.notification);
}

class BatchUpdateNotificationsAction {
  final List<String> ids;
  final bool markAsRead;

  const BatchUpdateNotificationsAction({
    required this.ids,
    this.markAsRead = true,
  });
}
