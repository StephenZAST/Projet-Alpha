import 'package:get/get.dart';
import '../controllers/menu_app_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    // Core controllers
    Get.put(ThemeController(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(MenuAppController(), permanent: true);

    // Feature controllers
    Get.lazyPut(() => DashboardController());
  }
}
