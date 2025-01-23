import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/main/main_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/services/services_screen.dart';
import '../screens/categories/categories_screen.dart';
import '../screens/users/users_screen.dart';
import '../screens/profile/admin_profile_screen.dart';
import '../screens/auth/admin_login_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../controllers/theme_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/menu_app_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../middleware/auth_middleware.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }
    if (!Get.isRegistered<ThemeController>()) {
      Get.put(ThemeController(), permanent: true);
    }
    if (!Get.isRegistered<MenuAppController>()) {
      Get.put(MenuAppController(), permanent: true);
    }

    // Controllers non permanents
    Get.lazyPut(() => DashboardController(), fenix: true);
  }
}

class AdminRoutes {
  static const String login = '/login';
  static const String main = '/';
  static const String dashboard = '/dashboard';
  static const String orders = '/orders';
  static const String services = '/services';
  static const String categories = '/categories';
  static const String users = '/users';
  static const String profile = '/profile';
  static const String notifications = '/notifications';

  static final routes = [
    // Route de login - Sans MainScreen car c'est une page indépendante
    GetPage(
      name: login,
      page: () => AdminLoginScreen(),
      binding: AdminBinding(),
    ),

    // Route principale - Conteneur par défaut avec DashboardScreen
    GetPage(
      name: main,
      page: () => MainScreen(),
      binding: AdminBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // Routes protégées - Toutes enveloppées dans MainScreen
    GetPage(
      name: dashboard,
      page: () => MainScreen.withChild(DashboardScreen()),
      binding: AdminBinding(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: orders,
      page: () => MainScreen.withChild(OrdersScreen()),
      binding: AdminBinding(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: services,
      page: () => MainScreen.withChild(ServicesScreen()),
      binding: AdminBinding(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: categories,
      page: () => MainScreen.withChild(CategoriesScreen()),
      binding: AdminBinding(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: users,
      page: () => MainScreen.withChild(UsersScreen()),
      binding: AdminBinding(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: profile,
      page: () => MainScreen.withChild(AdminProfileScreen()),
      binding: AdminBinding(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: notifications,
      page: () => MainScreen.withChild(NotificationsScreen()),
      binding: AdminBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];

  // Navigation helpers
  static void goToDashboard() {
    Get.offAllNamed(dashboard);
  }

  static void goToOrders() {
    Get.toNamed(orders);
  }

  static void goToServices() {
    Get.toNamed(services);
  }

  static void goToCategories() {
    Get.toNamed(categories);
  }

  static void goToUsers() {
    Get.toNamed(users);
  }

  static void goToProfile() {
    Get.toNamed(profile);
  }

  static void goToLogin() {
    Get.offAllNamed(login);
  }

  static void goToNotifications() {
    Get.toNamed(notifications);
  }
}
