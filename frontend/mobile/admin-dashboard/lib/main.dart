import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import './routes/admin_routes.dart';
import './config/theme_config.dart';

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
      theme: ThemeConfig.lightTheme(context),
      darkTheme: ThemeConfig.darkTheme(context),
      themeMode: ThemeMode.light,
      initialRoute: AdminRoutes.login,
      initialBinding: AdminBinding(),
      getPages: AdminRoutes.routes,
      defaultGlobalState: false,
      routingCallback: (routing) {
        if (routing?.current != null) {
          print('[Router] Current route: ${routing?.current}');
        }
      },
      onInit: () {
        print('[App] Initializing...');
      },
      onReady: () {
        print('[App] Ready!');
      },
    );
  }
}
