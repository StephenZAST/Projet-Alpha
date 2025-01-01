import 'package:flutter/material.dart';
import 'package:prima/main.dart';

class NavigationProvider with ChangeNotifier {
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

  int _currentIndex = 0;
  String _currentRoute = '/home';
  final List<String> _navigationStack = ['/home'];

  int get currentIndex => _currentIndex;
  String get currentRoute => _currentRoute;
  List<String> get navigationStack => List.unmodifiable(_navigationStack);

  bool shouldShowBottomNav(String route) => mainRoutes.contains(route);

  void setRoute(String route) {
    _currentRoute = route;
    if (mainRoutes.contains(route)) {
      _currentIndex = mainRoutes.indexOf(route);
      _navigationStack.clear();
      _navigationStack.add(route);
    }
    notifyListeners();
  }

  Future<void> navigateToMainRoute(BuildContext context, String route) async {
    if (!mainRoutes.contains(route)) return;

    // Mise à jour de l'index avant la navigation
    _currentIndex = mainRoutes.indexOf(route);
    _currentRoute = route;

    // Si nous sommes déjà sur la MainNavigationWrapper, pas besoin de recréer la pile
    if (ModalRoute.of(context)?.settings.name == '/') {
      notifyListeners();
      return;
    }

    // Sinon, retour à la MainNavigationWrapper avec le bon index
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const MainNavigationWrapper(),
        settings: const RouteSettings(name: '/'),
      ),
      (route) => false,
    );
    notifyListeners();
  }

  Future<void> navigateToSecondaryRoute(
      BuildContext context, String route) async {
    if (!secondaryRoutes.contains(route)) return;

    await Navigator.pushNamed(
      context,
      route,
      arguments: _currentRoute, // Sauvegarde la route précédente
    );
  }

  void returnToMainRoute(BuildContext context, String? previousRoute) {
    if (previousRoute != null && mainRoutes.contains(previousRoute)) {
      _currentIndex = mainRoutes.indexOf(previousRoute);
      _currentRoute = previousRoute;
    } else {
      _currentIndex = 0;
      _currentRoute = '/home';
    }
    notifyListeners();
  }

  void popRoute(BuildContext context) {
    if (_navigationStack.length > 1) {
      _navigationStack.removeLast();
      setRoute(_navigationStack.last);
      Navigator.pop(context);
    }
  }
}
