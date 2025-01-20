import 'package:admin/constants.dart';
import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/controllers/auth_controller.dart';
import 'package:admin/routes/admin_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Admin Panel',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: AppColors.textPrimary),
        canvasColor: AppColors.secondaryBg,
      ),
      initialRoute: AdminRoutes.login,
      getPages: AdminRoutes.routes,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
        Get.put(MenuAppController());
      }),
    );
  }
}
