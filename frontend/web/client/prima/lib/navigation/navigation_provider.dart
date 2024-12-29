import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // Helper method to convert route names to indices
  int getIndexFromRoute(String route) {
    switch (route) {
      case '/':
        return 0;
      case '/offers':
        return 1;
      case '/services':
        return 2;
      case '/chat':
        return 3;
      case '/profile':
        return 4;
      default:
        return 0;
    }
  }

  // Helper method to convert indices to route names
  String getRouteFromIndex(int index) {
    switch (index) {
      case 0:
        return '/';
      case 1:
        return '/offers';
      case 2:
        return '/services';
      case 3:
        return '/chat';
      case 4:
        return '/profile';
      default:
        return '/';
    }
  }
}