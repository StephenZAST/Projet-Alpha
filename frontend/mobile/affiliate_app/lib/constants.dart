import 'package:flutter/material.dart';

/// 🎨 Constants - Alpha Affiliate App
///
/// Design system complet pour l'application Affiliate avec palette glassmorphism,
/// typographie responsive, espacements cohérents et animations fluides.

// 🌐 Configuration API
class ApiConfig {
  // Allow overriding the backend URL at build/run time:
  // flutter run --dart-define=API_BASE_URL=http://localhost:3001/api
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://alpha-laundry-backend.onrender.com/api',
  );
  static const String affiliateEndpoint = '/affiliate';

  // Endpoints principaux
  static const String profile = '$affiliateEndpoint/profile';
  static const String commissions = '$affiliateEndpoint/commissions';
  static const String withdrawal = '$affiliateEndpoint/withdrawal';
  static const String referrals = '$affiliateEndpoint/referrals';
  static const String levels = '$affiliateEndpoint/levels';
  static const String currentLevel = '$affiliateEndpoint/current-level';
  static const String generateCode = '$affiliateEndpoint/generate-code';
  static const String registerWithCode =
      '$affiliateEndpoint/register-with-code';

  // Timeout
  static const Duration timeout = Duration(seconds: 30);
}

// 🎨 Palette de Couleurs Alpha Laundry - Glassmorphism Premium
class AppColors {
  // Couleurs principales Alpha Laundry
  static const Color primary = Color(0xFF0045CE); // Bleu Alpha Laundry
  static const Color primaryDark = Color(0xFF003399); // Bleu plus foncé
  static const Color primaryLight = Color(0xFF49A3F1); // Nuance gradient Alpha

  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryDark = Color(0xFF059669);
  static const Color secondaryLight = Color(0xFF34D399);

  static const Color accent =
      Color(0xFF49A3F1); // Utiliser la nuance gradient comme accent
  static const Color accentDark = Color(0xFF2563EB);
  static const Color accentLight = Color(0xFF60A5FA);

  // Couleurs système
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Couleurs neutres
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Grays
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Couleurs contextuelles
  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? gray100 : gray900;
  }

  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? gray300 : gray600;
  }

  static Color textTertiary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? gray400 : gray500;
  }

  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? gray800 : white;
  }

  static Color surfaceVariant(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? gray700 : gray50;
  }

  static Color border(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? gray600 : gray200;
  }

  // 🌈 Tokens de Design Premium (Glassmorphism)
  // Card backgrounds (parité avec admin dashboard)
  static const Color cardBgDark = Color(0xCC1E293B); // gray800 @ 0.8
  static const Color cardBgLight = Color(0xE6FFFFFF); // white @ 0.9

  // Glass tokens
  static const double glassBlurSigma = 10.0;
  static const double glassBorderDarkOpacity = 0.3;
  static const double glassBorderLightOpacity = 0.5;

  // Micro tokens
  static const double iconBoxOpacity = 0.1;
  static const double badgeBorderOpacity = 0.3;

  // 🌈 Gradients Premium Alpha Laundry
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
  );

  static const LinearGradient alphaGradient = LinearGradient(
    colors: [primary, primaryLight, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.6, 1.0],
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x1A0045CE), // primary @ 0.1
      Color(0x0D49A3F1), // accent @ 0.05
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [warning, Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradient pour les stats cards
  static const LinearGradient statGradient = LinearGradient(
    colors: [primaryLight, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// 📝 Styles de Texte Responsive
class AppTextStyles {
  // Display
  static const TextStyle display = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  // Headlines
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.4,
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.3,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.3,
  );

  // Overline
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.6,
  );
}

// 📏 Espacements
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Padding standards
  static const EdgeInsets pagePadding = EdgeInsets.all(md);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(vertical: lg);
}

// 🔄 Rayons de Bordure
class AppRadius {
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;

  static const BorderRadius borderRadiusSM =
      BorderRadius.all(Radius.circular(radiusSM));
  static const BorderRadius borderRadiusMD =
      BorderRadius.all(Radius.circular(radiusMD));
  static const BorderRadius borderRadiusLG =
      BorderRadius.all(Radius.circular(radiusLG));
  static const BorderRadius borderRadiusXL =
      BorderRadius.all(Radius.circular(radiusXL));
}

// 🌟 Ombres Glassmorphism Premium
class AppShadows {
  // Ombres pour les conteneurs glass
  static const List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Color(0x0A000000), // Ombre primaire
      blurRadius: 10,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0F000000), // Ombre ambiante
      blurRadius: 20,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  // Ombres pour les cartes
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  // Ombres pour les boutons premium
  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x1A0045CE), // Ombre colorée Alpha
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000), // Ombre neutre
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  // Ombres pour les boutons outlined
  static const List<BoxShadow> buttonOutlinedShadow = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 6,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  // Ombres pour les éléments flottants
  static const List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: Color(0x1A0045CE), // Ombre colorée
      blurRadius: 20,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0F000000), // Ombre ambiante
      blurRadius: 40,
      offset: Offset(0, 16),
      spreadRadius: 0,
    ),
  ];

  // Ombres pour les headers
  static const List<BoxShadow> headerShadow = [
    BoxShadow(
      color: Color(0x1A0045CE), // Ombre Alpha
      blurRadius: 24,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
}

// ⏱️ Animations
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  // Curves
  static const Curve fadeIn = Curves.easeInOut;
  static const Curve slideIn = Curves.easeOutCubic;
  static const Curve bounceIn = Curves.elasticOut;
  static const Curve scaleIn = Curves.easeOutBack;
}

// 🔑 Clés de Stockage
class StorageKeys {
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userRole = 'user_role';
  static const String affiliateProfile = 'affiliate_profile';
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String onboardingCompleted = 'onboarding_completed';
}

// 📱 Configuration Notifications
class NotificationConfig {
  static const String channelId = 'alpha_affiliate_notifications';
  static const String channelName = 'Alpha Affiliate';
  static const String channelDescription =
      'Notifications pour l\'app Alpha Affiliate';
}

// 💰 Configuration Affiliate
class AffiliateConfig {
  static const double minWithdrawalAmount = 5000.0; // FCFA
  static const int withdrawalCooldownDays = 7;
  static const double indirectCommissionRate = 2.0; // %
  static const double profitMarginRate = 0.40; // 40%

  // Niveaux
  static const Map<String, String> commissionLevels = {
    'BRONZE': 'Bronze',
    'SILVER': 'Argent',
    'GOLD': 'Or',
    'PLATINUM': 'Platine',
  };

  // Couleurs par niveau
  static const Map<String, Color> levelColors = {
    'BRONZE': Color(0xFFCD7F32),
    'SILVER': Color(0xFFC0C0C0),
    'GOLD': Color(0xFFFFD700),
    'PLATINUM': Color(0xFFE5E4E2),
  };
}

// 📊 Status
enum OrderStatus {
  pending,
  inProgress,
  ready,
  delivered,
  cancelled,
}

enum WithdrawalStatus {
  pending,
  approved,
  rejected,
}

enum AffiliateStatus {
  active,
  pending,
  suspended,
}

// 🎯 Extensions utiles
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

extension DoubleExtension on double {
  String toFormattedString() {
    if (isNaN || isInfinite) return '0';
    return toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }
}

// Support pour int
extension IntExtension on int {
  String toFormattedString() {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }
}

// Support pour int et double via num
extension NumExtension on num {
  String toFormattedString() {
    if (this is double && (this as double).isNaN) return '0';
    if (this is double && (this as double).isInfinite) return '0';
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }
}

// Extension pour les valeurs nullables
extension NullableNumExtension on num? {
  String toFormattedString() {
    if (this == null) return '0';
    return this!.toFormattedString();
  }
}

// Fonction utilitaire globale pour formater les nombres
String formatNumber(dynamic value) {
  if (value == null) return '0';
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed == null) return '0';
    value = parsed;
  }
  if (value is num) {
    if (value is double && (value.isNaN || value.isInfinite)) return '0';
    return value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }
  return value.toString();
}
