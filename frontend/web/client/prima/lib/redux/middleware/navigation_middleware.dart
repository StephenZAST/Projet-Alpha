import 'package:flutter/material.dart';
import 'package:prima/redux/states/app_state.dart';
import 'package:redux/redux.dart';
import '../actions/navigation_actions.dart';

class NavigationMiddleware {
  List<Middleware<AppState>> createMiddleware() {
    return [
      TypedMiddleware<AppState, NavigateToMainRouteAction>(
          _handleMainNavigation),
      TypedMiddleware<AppState, NavigateToSecondaryRouteAction>(
          _handleSecondaryNavigation),
    ];
  }

  void _handleMainNavigation(Store<AppState> store,
      NavigateToMainRouteAction action, NextDispatcher next) {
    next(action);
    store.dispatch(SetRouteAction(action.route));
    Navigator.pushNamedAndRemoveUntil(
      action.context,
      action.route,
      (route) => false,
    );
  }

  void _handleSecondaryNavigation(Store<AppState> store,
      NavigateToSecondaryRouteAction action, NextDispatcher next) {
    next(action);
    store.dispatch(PushRouteAction(action.route));
    Navigator.pushNamed(action.context, action.route);
  }
}
