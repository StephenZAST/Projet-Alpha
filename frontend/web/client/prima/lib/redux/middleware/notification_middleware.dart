import 'package:redux/redux.dart';
import '../store.dart';
import '../actions/notification_actions.dart';

class NotificationMiddleware {
  List<Middleware<AppState>> createMiddleware() {
    return [
      TypedMiddleware<AppState, ShowNotificationAction>(
          _handleShowNotification),
      TypedMiddleware<AppState, FetchNotificationsAction>(
          _handleFetchNotifications),
    ];
  }

  void _handleShowNotification(
    Store<AppState> store,
    ShowNotificationAction action,
    NextDispatcher next,
  ) async {
    next(action);

    if (action.duration != null) {
      await Future.delayed(action.duration!);
      store.dispatch(DismissNotificationAction());
    }
  }

  void _handleFetchNotifications(
    Store<AppState> store,
    FetchNotificationsAction action,
    NextDispatcher next,
  ) async {
    next(action);

    try {
      // Implement notification fetching logic
    } catch (e) {
      store.dispatch(FetchNotificationsFailureAction(e.toString()));
    }
  }
}
