import 'package:flutter/material.dart'; // change

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2563EB); // Modern blue
  static const Color primaryLight = Color(0xFF60A5FA); // Light blue
  static const Color primaryDark = Color(0xFF1E40AF); // Dark blue

  // Accent Colors
  static const Color accent = Color(0xFF0EA5E9); // Sky blue
  static const Color accentLight = Color(0xFF7DD3FC); // Light sky blue
  static const Color accentDark = Color(0xFF0369A1); // Dark sky blue

  // Status Colors
  static const Color success = Color(0xFF22C55E); // Modern green
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successDark = Color(0xFF166534);
  static const Color error = Color(0xFFEF4444); // Modern red
  static const Color errorLight = Color(0xFFFFE4E6);
  static const Color errorDark = Color(0xFFB91C1C);
  static const Color warning = Color(0xFFF59E0B); // Modern amber
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFB45309);
  static const Color info = Color(0xFF3B82F6); // Info blue
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF1D4ED8);

  // Vibrant Colors
  static const Color violet = Color(0xFF8B5CF6); // Violet
  static const Color violetLight = Color(0xFFEDE9FE);
  static const Color violetDark = Color(0xFF6D28D9);
  static const Color pink = Color(0xFFEC4899); // Pink
  static const Color pinkLight = Color(0xFFFCE7F3);
  static const Color pinkDark = Color(0xFFBE185D);
  static const Color teal = Color(0xFF14B8A6); // Teal
  static const Color tealLight = Color(0xFFCCFBF1);
  static const Color tealDark = Color(0xFF0F766E);
  static const Color indigo = Color(0xFF6366F1); // Indigo
  static const Color indigoLight = Color(0xFFE0E7FF);
  static const Color indigoDark = Color(0xFF4338CA);
  static const Color orange = Color(0xFFF97316); // Orange
  static const Color orangeLight = Color(0xFFFFEDD5);
  static const Color orangeDark = Color(0xFFC2410C);

  // Custom Accent Colors
  static const Color rose = Color(0xFFF43F5E); // Rose
  static const Color roseLight = Color(0xFFFFE4E6);
  static const Color roseDark = Color(0xFFBE123C);
  static const Color lime = Color(0xFF84CC16); // Lime
  static const Color limeLight = Color(0xFFECFCCB);
  static const Color limeDark = Color(0xFF4D7C0F);
  static const Color cyan = Color(0xFF06B6D4); // Cyan
  static const Color cyanLight = Color(0xFFCFFAFE);
  static const Color cyanDark = Color(0xFF0E7490);

  // Order Status Colors
  static const Color pending = Color(0xFFF59E0B); // Amber
  static const Color processing = Color(0xFF3B82F6); // Blue
  static const Color completed = Color(0xFF22C55E); // Green
  static const Color cancelled = Color(0xFFEF4444); // Red
  static const Color delivered = Color(0xFF8B5CF6); // Purple

  // Service Category Colors
  static const Color serviceHighlight = Color(0xFF0EA5E9); // Sky blue
  static const Color categoryTag = Color(0xFF6366F1); // Indigo
  static const Color categoryTagLight = Color(0xFFE0E7FF); // Light indigo

  // Background Colors
  static const Color bgColor = Color(0xFFF8FAFC); // Light gray background
  static const Color secondaryBg = Color(0xFFFFFFFF); // White
  static const Color cardBg = Color(0xFFFFFFFF); // White
  static const Color darkBg = Color(0xFF1E293B); // Dark mode background

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Very dark blue gray
  static const Color textSecondary = Color(0xFF475569); // Slate gray
  static const Color textMuted = Color(0xFF64748B); // Light slate gray
  static const Color textLight = Color(0xFFFFFFFF); // White text

  // Grays
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFF8FAFC);
  static const Color gray100 = Color(0xFFF1F5F9);
  static const Color gray200 = Color(0xFFE2E8F0);
  static const Color gray300 = Color(0xFFCBD5E1);
  static const Color gray400 = Color(0xFF94A3B8);
  static const Color gray500 = Color(0xFF64748B);
  static const Color gray600 = Color(0xFF475569);
  static const Color gray700 = Color(0xFF334155);
  static const Color gray800 = Color(0xFF1E293B);
  static const Color gray900 = Color(0xFF0F172A);

  // Border Colors
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);

  static final Color surfaceDark = Colors.grey[800]!;
  static final Color surfaceLight = Colors.grey[100]!;
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Padding
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);

  // Margin
  static const EdgeInsets marginXS = EdgeInsets.all(xs);
  static const EdgeInsets marginSM = EdgeInsets.all(sm);
  static const EdgeInsets marginMD = EdgeInsets.all(md);
  static const EdgeInsets marginLG = EdgeInsets.all(lg);
}

class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 999.0;

  static final BorderRadius radiusXS = BorderRadius.circular(xs);
  static final BorderRadius radiusSM = BorderRadius.circular(sm);
  static final BorderRadius radiusMD = BorderRadius.circular(md);
  static final BorderRadius radiusLG = BorderRadius.circular(lg);
  static final BorderRadius radiusXL = BorderRadius.circular(xl);
  static final BorderRadius radiusFull = BorderRadius.circular(full);
}

class AppTextStyles {
  static const String fontFamily = 'SourceSansPro';

  // Headings
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
  );

  // Body text
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodyBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
  );

  // Button text
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
  );

  // Ajouter le style caption manquant
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
  );

  static const titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const bodySmallSecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}

// Default values
const defaultPadding = AppSpacing.md;
const defaultRadius = AppRadius.md;

// Menu Indices
class MenuIndices {
  static const int dashboard = 0;
  static const int orders = 1;
  static const int services = 2;
  static const int categories = 3;
  static const int articles = 4;
  static const int serviceTypes = 5;
  static const int users = 6;
  static const int profile = 7;
  static const int notifications = 8;
  static const int serviceArticleCouples = 9;
  static const int subscriptions = 10;
}
