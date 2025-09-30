import 'package:flutter/material.dart';
import 'constants.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const AlphaCustomerApp());
}

/// 🚀 Alpha Customer App - Premium Pressing Experience
class AlphaCustomerApp extends StatelessWidget {
  const AlphaCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alpha Pressing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        fontFamily: AppTextStyles.fontFamily,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
      ),
      home: const HomePage(),
    );
  }
}
