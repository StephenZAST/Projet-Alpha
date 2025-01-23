import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/admin_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Core Controllers
    Get.put(ThemeController(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(AdminController(), permanent: true);
  }
}
