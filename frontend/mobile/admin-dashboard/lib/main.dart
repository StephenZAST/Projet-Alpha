import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import './routes/admin_routes.dart';
import './constants.dart';
import './controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  runApp(AdminDashboard());
}

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Admin Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.bgColor,
        fontFamily: AppTextStyles.fontFamily,
        textTheme: TextTheme(
          headlineLarge: AppTextStyles.h1,
          headlineMedium: AppTextStyles.h2,
          headlineSmall: AppTextStyles.h3,
          titleLarge: AppTextStyles.h4,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelLarge: AppTextStyles.buttonLarge,
          labelMedium: AppTextStyles.buttonMedium,
        ).apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          error: AppColors.error,
          background: AppColors.bgColor,
          surface: AppColors.secondaryBg,
          onPrimary: AppColors.textLight,
          onSecondary: AppColors.textLight,
          onError: AppColors.textLight,
          onBackground: AppColors.textPrimary,
          onSurface: AppColors.textPrimary,
        ),
        cardTheme: CardTheme(
          color: AppColors.cardBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusMD,
            side: BorderSide(color: AppColors.borderLight),
          ),
        ),
      ),
      // Dark theme configuration (basé sur le thème clair)
      darkTheme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.darkBg,
        fontFamily: AppTextStyles.fontFamily,
        textTheme: TextTheme(
          headlineLarge: AppTextStyles.h1,
          headlineMedium: AppTextStyles.h2,
          headlineSmall: AppTextStyles.h3,
          titleLarge: AppTextStyles.h4,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelLarge: AppTextStyles.buttonLarge,
          labelMedium: AppTextStyles.buttonMedium,
        ).apply(
          bodyColor: AppColors.textLight,
          displayColor: AppColors.textLight,
        ),
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          error: AppColors.error,
          background: AppColors.darkBg,
          surface: AppColors.gray800,
          onPrimary: AppColors.textLight,
          onSecondary: AppColors.textLight,
          onError: AppColors.textLight,
          onBackground: AppColors.textLight,
          onSurface: AppColors.textLight,
        ),
        cardTheme: CardTheme(
          color: AppColors.gray800,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusMD,
            side: BorderSide(color: AppColors.borderDark),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      defaultTransition: Transition.fadeIn,
      initialRoute: AdminRoutes.login,
      getPages: AdminRoutes.routes,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
      }),
    );
  }
}
