import 'package:admin/bindings/app_bindings.dart';
import 'package:admin/controllers/orders_controller.dart';
import 'package:admin/controllers/service_type_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import './routes/admin_routes.dart';
import './config/theme_config.dart';
import './controllers/menu_app_controller.dart';
import './controllers/theme_controller.dart';
import 'services/error_tracking_service.dart'; // change
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  ErrorTrackingService.initialize();

  // Initialiser l'ApiService en premier
  Get.put(ApiService(), permanent: true);

  // Ensuite initialiser les autres contrôleurs
  Get.put(MenuAppController(), permanent: true);
  Get.put<OrdersController>(OrdersController(), permanent: true);
  Get.put<ThemeController>(ThemeController(), permanent: true);
  Get.put<ServiceTypeController>(ServiceTypeController(), permanent: true);

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (details.exception is FlutterError) {
      final error = details.exception as FlutterError;
      if (error.toString().contains('GlobalKey')) {
        print('\n=== GlobalKey Error Details ===');
        print('Location: ${details.stack}');
        print('Context: ${details.context}');
        print('Library: ${details.library}');
        print('===========================\n');
      }
    }
  };

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
      initialBinding:
          AppBindings(), // Assurez-vous que cette ligne est présente
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
