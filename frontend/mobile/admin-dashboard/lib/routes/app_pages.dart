import 'package:get/get.dart';
import '../bindings/flash_orders_binding.dart';
import '../screens/orders/flash_orders/flash_orders_screen.dart';

class AppPages {
  static final routes = [
    // ...existing routes...

    GetPage(
      name: '/orders/flash',
      page: () => FlashOrdersScreen(),
      binding: FlashOrdersBinding(),
    ),

    // ...other routes...
  ];
}
