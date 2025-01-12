class NotificationState {
  final List<Map<String, dynamic>> notifications;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? currentNotification;

  NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.currentNotification,
  });

  NotificationState copyWith({
    List<Map<String, dynamic>>? notifications,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? currentNotification,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentNotification: currentNotification ?? this.currentNotification,
    );
  }
}
