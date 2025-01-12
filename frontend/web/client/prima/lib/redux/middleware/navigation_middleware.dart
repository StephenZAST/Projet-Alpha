import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import '../store.dart';
import '../actions/navigation_actions.dart';

class NavigationMiddleware {
  final GlobalKey<NavigatorState> navigatorKey;

  NavigationMiddleware(this.navigatorKey);

  List<Middleware<AppState>> createMiddleware() {
    return [
      TypedMiddleware<AppState, NavigateToMainRouteAction>(
          _handleMainNavigation),
      TypedMiddleware<AppState, NavigateToSecondaryRouteAction>(
          _handleSecondaryNavigation),
    ];
  }

  void _handleMainNavigation(Store<AppState> store,
      NavigateToMainRouteAction action, NextDispatcher next) async {
    next(action);
    store.dispatch(SetRouteAction(action.route));

    if (navigatorKey.currentState != null) {
      await navigatorKey.currentState!.pushNamedAndRemoveUntil(
        action.route,
        (route) => false,
      );
    }
  }

  void _handleSecondaryNavigation(Store<AppState> store,
      NavigateToSecondaryRouteAction action, NextDispatcher next) async {
    next(action);
    store.dispatch(PushRouteAction(action.route));

    if (navigatorKey.currentState != null) {
      await navigatorKey.currentState!.pushNamed(action.route);
    }
  }
}
