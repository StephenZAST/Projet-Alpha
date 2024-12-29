import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;
  String _currentRoute = '/';
  bool _isSecondaryPage = false;

  // Définition des constantes statiques
  static const int homeIndex = 0;
  static const int offersIndex = 1;
  static const int servicesIndex = 2;
  static const int chatIndex = 3;
  static const int profileIndex = 4;
  static const int orderIndex = 5;
  static const int notificationsIndex = 6;
  static const int referralIndex = 7;
  static const int settingsIndex = 8;

  int get currentIndex => _currentIndex;
  String get currentRoute => _currentRoute;
  bool get isSecondaryPage => _isSecondaryPage;

  static const List<String> mainRoutes = [
    '/',           // Home
    '/offers',     // Offres
    '/services',   // Services
    '/chat',       // Messages
    '/profile',    // Profile
  ];

  static const Map<String, int> allRoutes = {
    '/': homeIndex,
    '/offers': offersIndex,
    '/services': servicesIndex,
    '/chat': chatIndex,
    '/profile': profileIndex,
    '/orders': orderIndex,
    '/notifications': notificationsIndex,
    '/referral': referralIndex,
    '/settings': settingsIndex,
  };

  bool isPageSelected(int index) {
    return _currentIndex == index && 
           (index < 5 ? !_isSecondaryPage : _isSecondaryPage);
  }

  bool isCurrentRoute(String route) {
    return _currentRoute == route;
  }

  bool shouldShowBottomNav(String route) {
    return mainRoutes.contains(route);
  }

  void setRoute(String route) {
    _currentRoute = route;
    _currentIndex = allRoutes[route] ?? 0;
    _isSecondaryPage = !mainRoutes.contains(route);
    notifyListeners();
  }

  void navigateToMainRoute(BuildContext context, String route) {
    if (mainRoutes.contains(route)) {
      setRoute(route);
      while (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      if (route == '/') {
        Navigator.pushReplacementNamed(context, '/');
      } else {
        int index = mainRoutes.indexOf(route);
        _currentIndex = index;
        notifyListeners();
      }
    }
  }

  void navigateToSecondaryRoute(BuildContext context, String route) {
    if (!mainRoutes.contains(route)) {
      setRoute(route);
      Navigator.pushNamed(context, route);
    }
  }
}