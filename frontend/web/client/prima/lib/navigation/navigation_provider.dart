import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  static const List<String> mainRoutes = ['/', '/offers', '/services', '/chat', '/profile'];
  static const List<String> secondaryRoutes = ['/orders', '/notifications', '/referral', '/settings'];

  int _currentIndex = 0;
  String _currentRoute = '/';
  final List<String> _navigationHistory = ['/'];

  int get currentIndex => _currentIndex;
  String get currentRoute => _currentRoute;
  bool get canGoBack => _navigationHistory.length > 1;
  PageController? _pageController;

  PageController get pageController => _pageController ??= PageController(initialPage: _currentIndex);

  void setPageController(PageController controller) {
    _pageController = controller;
  }

  bool shouldShowBottomNav(String route) => mainRoutes.contains(route);

  void setRoute(String route, {bool addToHistory = true}) {
    if (_currentRoute != route) {
      _currentRoute = route;
      if (mainRoutes.contains(route)) {
        _currentIndex = mainRoutes.indexOf(route);
        _pageController?.jumpToPage(_currentIndex); // Changed from animateToPage
      }
      if (addToHistory) {
        _navigationHistory.add(route);
      }
      notifyListeners();
    }
  }

  Future<bool> goBack(BuildContext context) async {
    if (_navigationHistory.length > 1) {
      _navigationHistory.removeLast();
      final previousRoute = _navigationHistory.last;
      setRoute(previousRoute, addToHistory: false);
      
      if (mainRoutes.contains(previousRoute)) {
        _currentIndex = mainRoutes.indexOf(previousRoute);
        return true;
      } else {
        await Navigator.pushReplacementNamed(context, previousRoute);
        return true;
      }
    }
    return false;
  }

  Future<void> navigateToMainRoute(BuildContext context, String route) async {
    setRoute(route);
    if (!mainRoutes.contains(_currentRoute)) {
      await Navigator.pushReplacementNamed(context, route);
    }
  }

  Future<void> navigateToSecondaryRoute(BuildContext context, String route) async {
    setRoute(route);
    await Navigator.pushNamed(context, route);
  }
}