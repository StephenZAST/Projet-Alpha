import 'package:flutter/material.dart';

class SetRouteAction {
  final String route;
  SetRouteAction(this.route);
}

class SetIndexAction {
  final int index;
  SetIndexAction(this.index);
}

class PushRouteAction {
  final String route;
  PushRouteAction(this.route);
}

class PopRouteAction {}

class NavigateToMainRouteAction {
  final String route;
  final BuildContext context;

  NavigateToMainRouteAction(this.route, this.context);
}

class NavigateToSecondaryRouteAction {
  final String route;
  final BuildContext context;

  NavigateToSecondaryRouteAction(this.route, this.context);
}
