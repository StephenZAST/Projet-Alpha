import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;
  bool _isSecondaryPage = false;

  int get currentIndex => _currentIndex;
  bool get isSecondaryPage => _isSecondaryPage;

  static const int orderIndex = 5;
  static const int notificationsIndex = 6;
  static const int referralIndex = 7;
  static const int settingsIndex = 8;

  void setIndex(int index) {
    _currentIndex = index;
    _isSecondaryPage = false;
    notifyListeners();
  }

  void setSecondaryPageIndex(int index) {
    _currentIndex = index;
    _isSecondaryPage = true;
    notifyListeners();
  }

  void navigateToMainPage(BuildContext context, int index) {
    setIndex(index);
    while (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  // Helper method to convert route names to indices
  int getIndexFromRoute(String route) {
    switch (route) {
      case '/orders':
        return orderIndex;
      case '/notifications':
        return notificationsIndex;
      case '/referral':
        return referralIndex;
      case '/settings':
        return settingsIndex;
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