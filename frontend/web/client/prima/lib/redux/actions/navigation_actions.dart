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
  NavigateToMainRouteAction(this.route);
}

class NavigateToSecondaryRouteAction {
  final String route;
  NavigateToSecondaryRouteAction(this.route);
}
