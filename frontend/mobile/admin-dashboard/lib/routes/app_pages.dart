import 'package:admin/middleware/auth_middleware.dart';
import 'package:admin/routes/admin_routes.dart';
import 'package:admin/screens/users/users_screen.dart';
import 'package:get/get.dart';
import '../bindings/flash_orders_binding.dart';
import '../screens/orders/flash_orders/flash_orders_screen.dart';
import '../bindings/users_binding.dart';

class AppPages {
  static final routes = [
    // ...existing routes...

    GetPage(
      name: '/orders/flash',
      page: () => FlashOrdersScreen(),
      binding: FlashOrdersBinding(),
    ),

    GetPage(
      name: AdminRoutes.users,
      page: () => UsersScreen(),
      binding: UsersBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // ...other routes...
  ];
}
