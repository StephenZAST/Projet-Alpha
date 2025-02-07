import 'package:get/get.dart';
import '../controllers/flash_orders_controller.dart';
import '../controllers/orders_controller.dart';

class FlashOrdersBinding extends Bindings {
  @override
  void dependencies() {
    // S'assurer que OrdersController est disponible
    if (!Get.isRegistered<OrdersController>()) {
      Get.put(OrdersController());
    }

    // Injecter le FlashOrdersController
    Get.lazyPut<FlashOrdersController>(() => FlashOrdersController());
  }
}
