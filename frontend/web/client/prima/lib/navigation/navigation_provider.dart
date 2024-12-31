import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  static const List<String> mainRoutes = ['/home', '/offers', '/services', '/chat', '/profile'];
  static const List<String> secondaryRoutes = ['/orders', '/notifications', '/referral', '/settings'];

  int _currentIndex = 0;
  String _currentRoute = '/home';
  final List<String> _navigationHistory = ['/home'];

  int get currentIndex => _currentIndex;
  String get currentRoute => _currentRoute;
  bool get canGoBack => _navigationHistory.length > 1;

  bool shouldShowBottomNav(String route) => mainRoutes.contains(route);

  void setRoute(String route) {
    _currentRoute = route;
    if (mainRoutes.contains(route)) {
      _currentIndex = mainRoutes.indexOf(route);
    }
    notifyListeners();
  }

  Future<void> navigateToMainRoute(BuildContext context, String route) async {
    if (route == '/home') route = '/';
    if (mainRoutes.contains(route) || route == '/') {
      await Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (route) => false,
      );
      if (route != '/') {
        setRoute(route);
      }
    }
  }

  Future<void> navigateToSecondaryRoute(BuildContext context, String route) async {
    if (secondaryRoutes.contains(route)) {
      await Navigator.pushNamed(context, route);
    }
  }

  Future<bool> goBack(BuildContext context) async {
    if (_navigationHistory.length > 1) {
      _navigationHistory.removeLast();
      final previousRoute = _navigationHistory.last;
      await navigateToMainRoute(context, previousRoute);
      return true;
    }
    return false;
  }
}