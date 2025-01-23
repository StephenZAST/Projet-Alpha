import 'package:get/get.dart';
import '../controllers/menu_app_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/dashboard_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core controllers
    Get.put(MenuAppController(), permanent: true);
    Get.put(NotificationController(), permanent: true);
    Get.put(DashboardController(), permanent: true);
  }
}
