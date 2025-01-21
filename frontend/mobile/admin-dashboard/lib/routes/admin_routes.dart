import 'package:admin/screens/orders/order_create_screen.dart';
import 'package:admin/screens/orders/order_details_screen.dart';
import 'package:get/get.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/products/products_screen.dart';
import '../screens/users/users_screen.dart';
import '../screens/auth/admin_login_screen.dart';
import '../screens/profile/admin_profile_screen.dart';
import '../screens/services/services_screen.dart';
import '../screens/categories/categories_screen.dart';
import '../middleware/auth_middleware.dart';

class AdminRoutes {
  // Route names
  static const String dashboard = '/dashboard';
  static const String orders = '/orders';
  static const String products = '/products';
  static const String users = '/users';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String services = '/services';
  static const String categories = '/categories';

  // Route list with middleware
  static List<GetPage> routes = [
    GetPage(
      name: login,
      page: () => AdminLoginScreen(),
      middlewares: [
        AuthMiddleware(redirectTo: dashboard),
      ],
    ),
    GetPage(
      name: dashboard,
      page: () => DashboardScreen(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: orders,
      page: () => OrdersScreen(),
      middlewares: [
        AuthMiddleware(),
      ],
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
      name: products,
      page: () => ProductsScreen(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: users,
      page: () => UsersScreen(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: profile,
      page: () => AdminProfileScreen(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: services,
      page: () => ServicesScreen(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: categories,
      page: () => CategoriesScreen(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
  ];

  // Navigation methods
  static void goToDashboard() => Get.offAllNamed(dashboard);
  static void goToLogin() => Get.offAllNamed(login);
  static void goToOrders() => Get.toNamed(orders);
  static void goToOrderDetails(String id) => Get.toNamed('$orders/$id');
  static void goToProfile() => Get.toNamed(profile);
}
