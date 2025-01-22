import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../services/auth_service.dart';
import '../routes/admin_routes.dart';

class AuthMiddleware extends GetMiddleware {
  final String? redirectTo;

  AuthMiddleware({this.redirectTo});

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    final token = AuthService.token;
    final currentUser = AuthService.currentUser;

    print('[AuthMiddleware] Checking route: $route');
    print('[AuthMiddleware] Token exists: ${token != null}');
    print('[AuthMiddleware] Current user: ${currentUser?.toJson()}');
    print(
        '[AuthMiddleware] isAuthenticated: ${authController.isAuthenticated}');

    // Si l'utilisateur essaie d'accéder à la page de login alors qu'il est déjà connecté
    if (route == AdminRoutes.login && authController.isAuthenticated) {
      print('[AuthMiddleware] Already authenticated, redirecting to dashboard');
      return RouteSettings(name: AdminRoutes.dashboard);
    }

    // Si l'utilisateur n'est pas authentifié et essaie d'accéder à une page protégée
    if (!authController.isAuthenticated && route != AdminRoutes.login) {
      print('[AuthMiddleware] Not authenticated, redirecting to login');
      return RouteSettings(name: redirectTo ?? AdminRoutes.login);
    }

    print('[AuthMiddleware] Access granted to route: $route');
    return null;
  }

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    print('[AuthMiddleware] Route location: ${route.location}');

    try {
      // Vérifier si l'authentification est en cours
      if (Get.find<AuthController>().isLoading.value) {
        await Future.delayed(Duration(milliseconds: 100));
      }

      final settings = redirect(route.location);
      if (settings != null) {
        print('[AuthMiddleware] Redirecting to: ${settings.name}');
        return GetNavConfig.fromRoute(settings.name!);
      }
    } catch (e) {
      print('[AuthMiddleware] Error in redirectDelegate: $e');
      // En cas d'erreur, rediriger vers la page de login
      return GetNavConfig.fromRoute(AdminRoutes.login);
    }

    return await super.redirectDelegate(route);
  }

  // Log pour le debug
  @override
  GetPageBuilder? onPageBuildStart(GetPageBuilder? page) {
    print('[AuthMiddleware] Page build starting');
    return page;
  }

  @override
  GetPageBuilder? onPageBuildDone(GetPageBuilder? page) {
    print('[AuthMiddleware] Page build complete');
    return page;
  }

  @override
  void onPageDispose() {
    print('[AuthMiddleware] Page disposed');
  }

  @override
  int? get priority => 1;
}
