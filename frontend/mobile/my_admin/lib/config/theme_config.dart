import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';

class ThemeConfig {
  static ThemeData darkTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.bgColor,
      primaryColor: AppColors.primary,
      canvasColor: AppColors.secondaryBg,
      textTheme:
          GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).copyWith(
        displayLarge: TextStyle(color: AppColors.textPrimary, fontSize: 32),
        displayMedium: TextStyle(color: AppColors.textPrimary, fontSize: 24),
        titleLarge: TextStyle(color: AppColors.textPrimary, fontSize: 20),
        bodyLarge: TextStyle(color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textSecondary),
      ),
      cardTheme: CardTheme(
        color: AppColors.secondaryBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.secondaryBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.textSecondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.textSecondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: defaultPadding * 1.5,
            vertical: defaultPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
