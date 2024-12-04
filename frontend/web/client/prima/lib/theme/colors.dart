import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF0045CE);
  static const Color primaryLight = Color(0xFF1E4AE9);
  static const Color primaryDark = Color(0xFF00349B);

  // Status Colors
  static const Color success = Color(0xFF00AC4F);
  static const Color successLight = Color(0xFFDCF5E8);
  static const Color error = Color(0xFFD00049);
  static const Color errorLight = Color(0xFFFFE0E3);
  static const Color warning = Color(0xFFD29302);
  static const Color warningLight = Color(0xFFFCE6B3);

  // Grays
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFF9FBFF);
  static const Color gray100 = Color(0xFFF0F5F8);
  static const Color gray200 = Color(0xFFEAECF0);
  static const Color gray300 = Color(0xFFD0D5DD);
  static const Color gray400 = Color(0xFFB5B7C0);
  static const Color gray500 = Color(0xFF737791);
  static const Color gray600 = Color(0xFF5F6980);
  static const Color gray700 = Color(0xFF404B52);
  static const Color gray800 = Color(0xFF282828);
  static const Color gray900 = Color(0xFF000000);
  static const Color dashboardBackground = Color(0xFFF4F7FE); // Added dashboard background color
  static const Color labelColor = Color(0xFF99AED7);

  // Gradient
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF49A3F1), Color(0xFF0045CE)],
    stops: [0.0, 1.0],
  );

  // Shadows
  static BoxShadow primaryShadow = BoxShadow(
    color: const Color(0xFF959DA5).withOpacity(0.2),
    blurRadius: 24,
    offset: const Offset(0, 8),
  );
}
