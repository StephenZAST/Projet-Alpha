import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'config/theme_config.dart';
import 'routes/admin_routes.dart';
import 'controllers/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize controllers
  final themeController = Get.put(ThemeController());
  themeController.initTheme();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Dashboard',
      themeMode: Get.find<ThemeController>().theme,
      theme: ThemeConfig.lightTheme(context),
      darkTheme: ThemeConfig.darkTheme(context),
      initialRoute: AdminRoutes.login,
      getPages: AdminRoutes.routes,
      initialBinding: AdminBinding(),
      defaultTransition: Transition.fadeIn,
    );
  }
}

class AdminBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ThemeController(), fenix: true);
    // Add other controllers here
  }
}
