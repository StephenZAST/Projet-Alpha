import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../routes/admin_routes.dart';

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
    final currentUser = AuthService.currentUser;

    // Vérifier si l'utilisateur est connecté
    if (!authController.isAuthenticated || AuthService.token == null) {
      return RouteSettings(name: redirectTo ?? AdminRoutes.login);
    }

    // Vérifier les permissions de rôle
    if (allowedRoles != null &&
        allowedRoles!.isNotEmpty &&
        currentUser != null) {
      final hasPermission = allowedRoles!.contains(currentUser.role) ||
          currentUser.role == UserRole.SUPER_ADMIN;

      if (!hasPermission) {
        return RouteSettings(name: AdminRoutes.login);
      }
    }

    return null;
  }

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    final authController = Get.find<AuthController>();

    if (authController.isLoading.value) {
      // Attendre que le chargement soit terminé avant de rediriger
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

class AdminMiddleware extends AuthMiddleware {
  AdminMiddleware()
      : super(
          redirectTo: AdminRoutes.login,
          allowedRoles: [UserRole.ADMIN, UserRole.SUPER_ADMIN],
        );
}

class SuperAdminMiddleware extends AuthMiddleware {
  SuperAdminMiddleware()
      : super(
          redirectTo: AdminRoutes.login,
          allowedRoles: [UserRole.SUPER_ADMIN],
        );
}
