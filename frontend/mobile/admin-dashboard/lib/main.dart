import 'package:admin/services/drawer_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import './routes/admin_routes.dart';
import './config/theme_config.dart';
import './controllers/auth_controller.dart';
import './controllers/theme_controller.dart';
import './controllers/menu_app_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialiser les services et contrôleurs core
  Get.put(ThemeController(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(DrawerService(), permanent: true);
  Get.put(MenuAppController(), permanent: true);

  runApp(AdminDashboard());
}

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // S'assurer que MenuAppController est initialisé
    final menuController = Get.find<MenuAppController>();
    print(
        '[AdminDashboard] MenuController initialized: ${menuController.scaffoldKey}');

    return GetX<ThemeController>(
      builder: (themeController) {
        return GetMaterialApp(
          title: 'Admin Dashboard',
          debugShowCheckedModeBanner: false,
          theme: ThemeConfig.lightTheme(context),
          darkTheme: ThemeConfig.darkTheme(context),
          themeMode:
              themeController.darkMode ? ThemeMode.dark : ThemeMode.light,
          defaultTransition: Transition.fadeIn,
          transitionDuration: Duration(milliseconds: 200),
          initialRoute: AdminRoutes.splash,
          getPages: AdminRoutes.routes,
          defaultGlobalState: false,
        );
      },
    );
  }
}
