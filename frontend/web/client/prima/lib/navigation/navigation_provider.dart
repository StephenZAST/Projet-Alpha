import 'package:flutter/material.dart';
import 'package:prima/animations/page_transition.dart';
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
  PageController? _pageController;

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

  // Ajout d'une méthode pour vérifier la route active
  bool isRouteActive(String route) {
    // Si nous sommes sur une route secondaire (dans la pile de navigation)
    if (_navigationStack.length > 1) {
      // Seule la dernière route de la pile est active
      return _navigationStack.last == route;
    }
    // Sinon, nous sommes sur une route principale
    return _currentRoute == route;
  }

  Future<void> navigateToMainRoute(BuildContext context, String route) async {
    if (!mainRoutes.contains(route)) return;

    final int newIndex = mainRoutes.indexOf(route);
    _currentRoute = route;
    _currentIndex = newIndex;
    _navigationStack
      ..clear()
      ..add(route);

    if (ModalRoute.of(context)?.settings.name != '/') {
      await Navigator.pushAndRemoveUntil(
        context,
        CustomPageTransition(
          child: const MainNavigationWrapper(),
        ),
        (route) => false,
      );
    }
    notifyListeners();
  }

  Future<void> navigateToSecondaryRoute(
      BuildContext context, String route) async {
    if (!secondaryRoutes.contains(route)) return;

    // Ajouter la nouvelle route à la pile
    _navigationStack.add(route);
    notifyListeners();

    await Navigator.pushNamed(context, route);

    // Après le retour de la page secondaire
    if (_navigationStack.length > 1) {
      _navigationStack.removeLast();
      notifyListeners();
    }
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

  Future<bool> goBack(BuildContext context) async {
    if (_currentIndex != 0) {
      setRouteFromIndex(0);
      return true;
    }
    return false;
  }

  void setRouteFromIndex(int index) {
    if (index >= 0 && index < mainRoutes.length) {
      _currentIndex = index;
      _currentRoute = mainRoutes[index];
      notifyListeners();
    }
  }

  void setPageController(PageController controller) {
    _pageController = controller;
  }

  void animateToPage(int index) {
    _pageController?.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }
}
