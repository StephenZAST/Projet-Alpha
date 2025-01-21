import 'package:admin/controllers/dashboard_controller.dart';
import 'package:admin/controllers/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/theme_config.dart';
import 'controllers/menu_app_controller.dart';
import 'controllers/auth_controller.dart';
import 'routes/admin_routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Dashboard',
      theme: ThemeConfig.darkTheme(context),
      initialRoute: AdminRoutes.login,
      getPages: AdminRoutes.routes,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
        Get.lazyPut(() => MenuAppController());
        Get.lazyPut(() => DashboardController());
        Get.lazyPut(() => NotificationController());
      }),
    );
  }
}
