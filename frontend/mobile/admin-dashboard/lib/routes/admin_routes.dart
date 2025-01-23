import '../screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/menu_app_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/orders_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/article_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/service_controller.dart';
import '../controllers/article_service_controller.dart';
import '../controllers/theme_controller.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/auth/admin_login_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/orders/order_details_screen.dart';
import '../screens/orders/order_create_screen.dart';
import '../screens/users/users_screen.dart';
import '../screens/profile/admin_profile_screen.dart';
import '../screens/services/services_screen.dart';
import '../screens/categories/categories_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../middleware/auth_middleware.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core system controllers
    Get.put(ThemeController(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(MenuAppController(), permanent: true);
    Get.put(NotificationController(), permanent: true);

    // Initialize auth controller
    final authController = Get.find<AuthController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authController.verifyAuth();
    });
  }
}

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Navigation et Dashboard
    if (!Get.isRegistered<MenuAppController>()) {
      Get.put(MenuAppController(), permanent: true);
    }
    Get.put(DashboardController());
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController(), permanent: true);
    }
    Get.put(OrdersController());

    // Articles et catégories
    Get.put(CategoryController());
    Get.put(ArticleController());

    // Services et associations
    Get.put(ServiceController());
    Get.put(ArticleServiceController());
  }
}

class AdminRoutes {
  static const String splash = '/';
  static const String dashboard = '/dashboard';
  static const String orders = '/orders';
  static const String users = '/users';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String services = '/services';
  static const String categories = '/categories';
  static const String notifications = '/notifications';

  static final routes = <GetPage>[
    GetPage(
      name: splash,
      page: () => SplashScreen(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: login,
      page: () => AdminLoginScreen(),
      binding: InitialBinding(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 250),
    ),
    GetPage(
      name: dashboard,
      page: () => DashboardScreen(),
      binding: DashboardBinding(),
      middlewares: [AuthMiddleware(redirectTo: login)],
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 250),
    ),
    GetPage(
      name: orders,
      page: () => OrdersScreen(),
      binding: DashboardBinding(),
      middlewares: [AuthMiddleware(redirectTo: login)],
      children: [
        GetPage(
          name: '/create',
          page: () => OrderCreateScreen(),
        ),
        GetPage(
          name: '/:id',
          page: () => OrderDetailsScreen(),
        ),
      ],
    ),
    GetPage(
      name: users,
      page: () => UsersScreen(),
      binding: DashboardBinding(),
      middlewares: [AuthMiddleware(redirectTo: login)],
    ),
    GetPage(
      name: profile,
      page: () => AdminProfileScreen(),
      binding: DashboardBinding(),
      middlewares: [AuthMiddleware(redirectTo: login)],
    ),
    GetPage(
      name: services,
      page: () => ServicesScreen(),
      binding: DashboardBinding(),
      middlewares: [AuthMiddleware(redirectTo: login)],
    ),
    GetPage(
      name: categories,
      page: () => CategoriesScreen(),
      binding: DashboardBinding(),
      middlewares: [AuthMiddleware(redirectTo: login)],
    ),
    GetPage(
      name: notifications,
      page: () => NotificationsScreen(),
      binding: DashboardBinding(),
      middlewares: [AuthMiddleware(redirectTo: login)],
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 200),
    ),
  ];

  // Navigation helpers
  static void goToDashboard() {
    Get.offAllNamed(dashboard);
  }

  static void goToLogin() {
    Get.offAllNamed(login);
  }

  static void goToOrders() {
    Get.toNamed(orders);
  }

  static void goToOrderDetails(String id) {
    Get.toNamed('$orders/$id');
  }

  static void goToProfile() {
    Get.toNamed(profile);
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

  static void goToNotifications() {
    Get.toNamed(notifications);
  }
}
