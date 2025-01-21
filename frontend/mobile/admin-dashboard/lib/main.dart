import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'config/theme_config.dart';
import 'routes/admin_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
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
      initialBinding: AdminBinding(),
      defaultTransition: Transition.fadeIn,
    );
  }
}
