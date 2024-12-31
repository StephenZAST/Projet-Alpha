import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  static const List<String> mainRoutes = ['/', '/offers', '/services', '/chat', '/profile'];
  
  int _currentIndex = 0;
  String _currentRoute = '/';
  PageController? _pageController;

  int get currentIndex => _currentIndex;
  String get currentRoute => _currentRoute;
  PageController get pageController => _pageController ??= PageController(initialPage: _currentIndex);

  void setPageController(PageController controller) {
    _pageController = controller;
  }

  bool shouldShowBottomNav(String route) => mainRoutes.contains(route);

  void setRoute(String route) {
    if (_currentRoute != route) {
      _currentRoute = route;
      if (mainRoutes.contains(route)) {
        _currentIndex = mainRoutes.indexOf(route);
        _pageController?.jumpToPage(_currentIndex); // Changed from animateToPage
      }
      notifyListeners();
    }
  }

  Future<void> navigateToMainRoute(BuildContext context, String route) async {
    if (mainRoutes.contains(route)) {
      final index = mainRoutes.indexOf(route);
      _currentIndex = index;
      _currentRoute = route;
      _pageController?.jumpToPage(index); // Changed from animateToPage
      notifyListeners();
    }
  }

  Future<void> navigateToSecondaryRoute(BuildContext context, String route) async {
    await Navigator.pushNamed(context, route);
  }
}