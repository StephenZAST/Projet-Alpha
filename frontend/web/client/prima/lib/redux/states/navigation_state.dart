class NavigationState {
  final int currentIndex;
  final String currentRoute;
  final List<String> navigationStack;

  static const List<String> mainRoutes = [
    '/home',
    '/offers',
    '/services',
    '/chat',
    '/profile'
  ];
  static const List<String> secondaryRoutes = [
    '/orders',
    '/notifications',
    '/referral',
    '/settings'
  ];

  NavigationState({
    this.currentIndex = 0,
    this.currentRoute = '/home',
    List<String>? navigationStack,
  }) : navigationStack = navigationStack ?? ['/home'];

  NavigationState copyWith({
    int? currentIndex,
    String? currentRoute,
    List<String>? navigationStack,
  }) {
    return NavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
      currentRoute: currentRoute ?? this.currentRoute,
      navigationStack: navigationStack ?? this.navigationStack,
    );
  }

  bool shouldShowBottomNav(String route) => mainRoutes.contains(route);

  bool isRouteActive(String route) {
    return navigationStack.isNotEmpty
        ? navigationStack.last == route
        : currentRoute == route;
  }
}
