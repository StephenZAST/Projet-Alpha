import 'package:flutter/material.dart';
import 'package:prima/main.dart';

class NavigationProvider with ChangeNotifier {
  static const List<String> mainRoutes = ['/home', '/offers', '/services', '/chat', '/profile'];
  static const List<String> secondaryRoutes = ['/orders', '/notifications', '/referral', '/settings'];

  int _currentIndex = 0;
  String _currentRoute = '/home';

  int get currentIndex => _currentIndex;
  String get currentRoute => _currentRoute;

  bool shouldShowBottomNav(String route) => mainRoutes.contains(route);

  void setRoute(String route) {
    _currentRoute = route;
    if (mainRoutes.contains(route)) {
      _currentIndex = mainRoutes.indexOf(route);
    }
    notifyListeners();
  }

  Future<void> navigateToMainRoute(BuildContext context, String route) async {
    if (mainRoutes.contains(route)) {
      // Retour à la MainNavigationWrapper avec l'index correct
      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const MainNavigationWrapper(),
        ),
        (route) => false,
      );
      setRoute(route);
    }2
  }

  Future<void> navigateToSecondaryRoute(BuildContext context, String route) async {
    if (secondaryRoutes.contains(route)) {
      await Navigator.pushNamed(context, route);
    }
  }
}