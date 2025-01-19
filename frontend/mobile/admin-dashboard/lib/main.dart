import 'package:admin/constants.dart';
import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/screens/main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Dashboard',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.bgColor,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.dark().copyWith(
          primary: AppColors.primary,
          secondary: AppColors.primaryLight,
          error: AppColors.error,
        ),
        cardTheme: CardTheme(
          color: AppColors.secondaryBg,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.secondaryBg,
          elevation: 0,
        ),
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => MenuAppController(),
          ),
        ],
        child: MainScreen(),
      ),
    );
  }
}
