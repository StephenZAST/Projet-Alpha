import 'package:admin/constants.dart';
import 'package:admin/controllers/article_controller.dart';
import 'package:admin/controllers/service_type_controller.dart';
import 'package:admin/screens/articles/articles_screen.dart';
import 'package:admin/screens/orders/flash_orders/flash_order_update_screen.dart';
import 'package:admin/screens/orders/flash_orders/flash_orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/main/main_screen.dart';
import '../screens/auth/admin_login_screen.dart';
import '../controllers/theme_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/menu_app_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/orders_controller.dart';
import '../controllers/service_controller.dart';
import '../controllers/category_controller.dart';
import '../middleware/auth_middleware.dart';
import '../screens/services/service_type_management_screen.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    // Core controllers - permanent
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }
    if (!Get.isRegistered<ThemeController>()) {
      Get.put(ThemeController(), permanent: true);
    }
    if (!Get.isRegistered<MenuAppController>()) {
      Get.put(MenuAppController(), permanent: true);
    }
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController(), permanent: true);
    }

    // Feature controllers - lazy loaded
    Get.lazyPut(() => DashboardController(), fenix: true);
    Get.lazyPut(() => OrdersController(), fenix: true);
    Get.lazyPut(() => ServiceController(), fenix: true);
    Get.lazyPut(() => CategoryController(), fenix: true);
    Get.lazyPut(() => ArticleController(),
        fenix: true); // Ajout du ArticleController
    Get.lazyPut(() => ServiceTypeController(),
        fenix: true); // Ajout du ServiceTypeController
  }
}

class AdminRoutes {
  // Routes définies
  static const String login = '/login';
  static const String main = '/';
  static const String dashboard = '/dashboard';
  static const String orders = '/orders';
  static const String services = '/services';
  static const String categories = '/categories';
  static const String users = '/users';
  static const String profile = '/profile';
  static const String notifications = '/notifications';

  // Ajouter les routes pour les commandes flash
  static const String flashOrders = '/orders/flash';
  static const String flashOrderUpdate = '/orders/flash/:id';

  // Mapping index -> route
  static String getRouteByIndex(int index) {
    switch (index) {
      case MenuIndices.dashboard:
        return dashboard;
      case MenuIndices.orders:
        return orders;
      case MenuIndices.services:
        return services;
      case MenuIndices.categories:
        return categories;
      case MenuIndices.articles:
        return '/articles'; // Ajout de la route articles
      case MenuIndices.serviceTypes:
        return '/service-types'; // Ajout de la route service-types
      case MenuIndices.users:
        return users;
      case MenuIndices.profile:
        return profile;
      case MenuIndices.notifications:
        return notifications;
      default:
        return dashboard;
    }
  }

  // Mapping route -> index
  static int getIndexByRoute(String route) {
    switch (route) {
      case dashboard:
        return MenuIndices.dashboard;
      case orders:
        return MenuIndices.orders;
      case services:
        return MenuIndices.services;
      case categories:
        return MenuIndices.categories;
      case '/articles':
        return MenuIndices.articles;
      case '/service-types':
        return MenuIndices.serviceTypes;
      case users:
        return MenuIndices.users;
      case profile:
        return MenuIndices.profile;
      case notifications:
        return MenuIndices.notifications;
      default:
        return MenuIndices.dashboard;
    }
  }

  static final routes = [
    // Route de login
    GetPage(
      name: login,
      page: () => AdminLoginScreen(),
      binding: AdminBinding(),
      transition: Transition.fadeIn,
    ),

    // Route principale avec MainScreen qui gère la navigation interne
    GetPage(
      name: main,
      page: () => MainScreen(),
      binding: AdminBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // Routes pour les commandes flash
    GetPage(
      name: flashOrders,
      page: () => FlashOrdersScreen(),
      binding: AdminBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: flashOrderUpdate,
      page: () {
        final orderId = Get.parameters['id']!;
        final controller = Get.find<OrdersController>();
        controller.initFlashOrderUpdate(orderId);
        return FlashOrderUpdateScreen();
      },
      binding: AdminBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/articles',
      page: () => ArticlesScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ArticleController>()) {
          Get.put(ArticleController());
        }
      }),
    ),
    GetPage(
      name: '/service-types',
      page: () => ServiceTypeManagementScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ServiceTypeController>()) {
          Get.put(ServiceTypeController());
        }
      }),
    ),
  ];

  // Navigation helpers
  static bool canGoBack() {
    return Get.previousRoute.isNotEmpty;
  }

  static void goBack() {
    if (canGoBack()) {
      Get.back();
    }
  }

  static void navigateByIndex(int index) {
    final menuController = Get.find<MenuAppController>();
    menuController.updateIndex(index);
  }

  static void navigateByRoute(String route) {
    final menuController = Get.find<MenuAppController>();
    menuController.updateIndex(getIndexByRoute(route));
  }

  static void goToDashboard() {
    navigateByIndex(0);
  }

  static void goToOrders() {
    navigateByIndex(1);
  }

  static void goToServices() {
    navigateByIndex(2);
  }

  static void goToCategories() {
    navigateByIndex(3);
  }

  static void goToUsers() {
    navigateByIndex(4);
  }

  static void goToProfile() {
    navigateByIndex(5);
  }

  static void goToLogin() {
    Get.offAllNamed(login);
  }

  static void goToNotifications() {
    navigateByIndex(6);
  }

  // Ajouter les méthodes de navigation
  static void goToFlashOrders() {
    Get.toNamed(flashOrders);
  }

  static void goToFlashOrderUpdate(String orderId) {
    Get.toNamed('$flashOrderUpdate/$orderId');
  }
}
