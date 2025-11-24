import 'package:get/get.dart';
import 'package:admin/controllers/client_managers_controller.dart';

/// Binding pour l'injection de dépendances du Client Managers
class ClientManagersBinding extends Bindings {
  @override
  void dependencies() {
    print('[ClientManagersBinding] Registering ClientManagersController');
    
    Get.lazyPut<ClientManagersController>(
      () => ClientManagersController(),
      fenix: true, // Permet la réutilisation du contrôleur
    );
  }
}
