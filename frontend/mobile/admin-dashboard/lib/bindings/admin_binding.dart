import 'package:admin/controllers/menu_app_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    // S'assurer qu'une seule instance du MenuAppController existe
    if (!Get.isRegistered<MenuAppController>()) {
      Get.put(MenuAppController(), permanent: true);
    }

    // ...rest of existing bindings...
  }
}
