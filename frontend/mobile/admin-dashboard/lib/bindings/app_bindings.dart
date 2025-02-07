import 'package:admin/controllers/address_controller.dart';
import 'package:admin/controllers/flash_orders_controller.dart';
import 'package:get/get.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Controllers permanents déjà initialisés dans main()

    // Controllers avec une durée de vie limitée
    Get.lazyPut<FlashOrdersController>(
      () => FlashOrdersController(),
      fenix: true, // Permet la réinitialisation automatique
    );

    Get.lazyPut<AddressController>(
      () => AddressController(),
      fenix: true,
    );

    // ...autres controllers...
  }
}
