import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void navigateToLogin() {
    try {
      navigatorKey.currentState
          ?.pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      // ignore: avoid_print
      print('Navigation to login failed: $e');
    }
  }
}
