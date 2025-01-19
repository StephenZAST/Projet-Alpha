import 'package:get/get.dart';
import 'package:admin/screens/dashboard/dashboard_screen.dart';
import 'package:admin/screens/orders/orders_screen.dart';
import 'package:admin/screens/products/products_screen.dart';
import 'package:admin/screens/users/users_screen.dart';
import 'package:admin/screens/auth/admin_login_screen.dart';

class AdminRoutes {
  static const String dashboard = '/dashboard';
  static const String orders = '/orders';
  static const String products = '/products';
  static const String users = '/users';
  static const String login = '/login';

  static List<GetPage> routes = [
    GetPage(name: dashboard, page: () => DashboardScreen()),
    GetPage(name: orders, page: () => OrdersScreen()),
    GetPage(name: products, page: () => ProductsScreen()),
    GetPage(name: users, page: () => UsersScreen()),
    GetPage(name: login, page: () => AdminLoginScreen()),
  ];
}
