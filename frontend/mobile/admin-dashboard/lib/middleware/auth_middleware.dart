import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/user.dart';

class AuthMiddleware extends GetMiddleware {
  final String? redirectTo;
  final List<UserRole>? allowedRoles;

  AuthMiddleware({
    this.redirectTo,
    this.allowedRoles,
  });

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();

    // Check if user is authenticated
    if (!authController.isAuthenticated) {
      return RouteSettings(name: redirectTo ?? '/login');
    }

    // Check token expiry
    if (authController.isTokenExpired()) {
      authController.logout();
      return RouteSettings(name: '/login');
    }

    // Check role permissions
    if (allowedRoles != null && allowedRoles!.isNotEmpty) {
      final userRole = authController.user.value?.role;
      if (userRole == null || !allowedRoles!.contains(userRole)) {
        return RouteSettings(name: '/unauthorized');
      }
    }

    return null;
  }

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    final authController = Get.find<AuthController>();
    if (authController.isLoading.value) {
      await Future.delayed(Duration(milliseconds: 500));
      final settings = redirect(route.location);
      if (settings != null) {
        return GetNavConfig.fromRoute(settings.name!);
      }
    }
    return await super.redirectDelegate(route);
  }

  @override
  int? get priority => 1;
}
