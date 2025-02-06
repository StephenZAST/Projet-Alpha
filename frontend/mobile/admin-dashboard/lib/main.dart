import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import './routes/admin_routes.dart';
import './config/theme_config.dart';
import './controllers/auth_controller.dart';
import './controllers/menu_app_controller.dart';
import './controllers/theme_controller.dart';
import './controllers/notification_controller.dart';

void main() async {
  print('[Main] Starting application initialization');
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Ajouter un mode test pour le débogage
  Get.testMode = true;
  print('[Main] GetX test mode enabled');

  // Initialiser les contrôleurs essentiels
  Get.put(AuthController(), permanent: true);
  Get.put(ThemeController(), permanent: true);
  Get.put(MenuAppController(), permanent: true);
  Get.put(NotificationController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('[MyApp] Building GetMaterialApp');
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Dashboard',
      theme: ThemeConfig.lightTheme(context),
      darkTheme: ThemeConfig.darkTheme(context),
      themeMode: ThemeMode.dark,
      initialRoute: AdminRoutes.login,
      initialBinding: BindingsBuilder(() {
        print('[MyApp] Initializing bindings');
        AdminBinding().dependencies();
        print('[MyApp] Bindings initialized');
      }),
      getPages: AdminRoutes.routes,
      defaultTransition: Transition.fade,
      onInit: () {
        print('[MyApp] GetMaterialApp onInit called');
      },
      onReady: () {
        print('[MyApp] GetMaterialApp onReady called');
      },
      routingCallback: (routing) {
        print('[MyApp] Route changed: ${routing?.current}');
      },
      enableLog: true,
      logWriterCallback: (String text, {bool isError = false}) {
        print('[Router] $text');
      },
    );
  }
}
