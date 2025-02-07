import 'package:admin/bindings/app_bindings.dart';
import 'package:admin/controllers/orders_controller.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialisation unique des contrôleurs permanents
  Get.put(MenuAppController(), permanent: true);
  Get.put<OrdersController>(OrdersController(), permanent: true);
  Get.put<ThemeController>(ThemeController(), permanent: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Dashboard',
      theme: ThemeConfig.lightTheme(context),
      darkTheme: ThemeConfig.darkTheme(context),
      themeMode: ThemeMode.dark,
      initialRoute: AdminRoutes.login,
      initialBinding: AppBindings(),
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
