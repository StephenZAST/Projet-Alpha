import 'package:admin/controllers/address_controller.dart';
import 'package:admin/controllers/flash_orders_controller.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/menu_app_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/article_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/orders_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Controllers permanents déjà initialisés dans main()

    // Initialiser uniquement si non déjà initialisé
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }
    if (!Get.isRegistered<MenuAppController>()) {
      Get.put(MenuAppController(), permanent: true);
    }
    if (!Get.isRegistered<ThemeController>()) {
      Get.put(ThemeController(), permanent: true);
    }

    // Controllers avec une durée de vie limitée
    Get.lazyPut<FlashOrdersController>(
      () => FlashOrdersController(),
      fenix: true, // Permet la réinitialisation automatique
    );

    Get.lazyPut<AddressController>(
      () => AddressController(),
      fenix: true,
    );

    // Controllers with fenix true for automatic recreation
    Get.lazyPut(() => CategoryController(), fenix: true);
    Get.lazyPut(() => ArticleController(), fenix: true);
    Get.lazyPut(() => NotificationController(), fenix: true);
    Get.lazyPut(() => OrdersController(), fenix: true);

    // ...autres controllers...
  }
}
