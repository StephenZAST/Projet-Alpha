import 'package:flutter/material.dart';

/// 🎨 Design System Premium - Alpha Client App
///
/// Système de design sophistiqué pour l'application client Alpha Pressing
/// avec glassmorphism, micro-interactions et expérience utilisateur exceptionnelle.

// =============================================================================
// 🌈 COULEURS SIGNATURE ALPHA
// =============================================================================

class AppColors {
  // 🔵 Couleurs Signature Alpha Pressing
  static const Color primary = Color(0xFF2563EB); // Bleu signature Alpha
  static const Color primaryLight = Color(0xFF60A5FA); // Bleu clair Alpha
  static const Color primaryDark = Color(0xFF1E40AF); // Bleu foncé Alpha

  // 🎯 Couleurs d'Accent
  static const Color accent = Color(0xFF06B6D4); // Cyan moderne
  static const Color accentLight = Color(0xFF7DD3FC); // Cyan clair
  static const Color accentDark = Color(0xFF0369A1); // Cyan foncé

  // 🌈 Couleurs de Statut (Pressing)
  static const Color success = Color(0xFF10B981); // Vert - Service terminé
  static const Color warning = Color(0xFFF59E0B); // Ambre - En cours
  static const Color error = Color(0xFFEF4444); // Rouge - Problème
  static const Color info = Color(0xFF3B82F6); // Bleu info
  static const Color pending = Color(0xFFF59E0B); // Ambre - En attente

  // 🎭 Palette Étendue Premium
  static const Color violet = Color(0xFF8B5CF6); // Service premium
  static const Color violetLight = Color(0xFFEDE9FE);
  static const Color violetDark = Color(0xFF6D28D9);

  static const Color pink = Color(0xFFEC4899); // Promotions
  static const Color pinkLight = Color(0xFFFCE7F3);
  static const Color pinkDark = Color(0xFFBE185D);

  static const Color teal = Color(0xFF14B8A6); // Eco-friendly
  static const Color tealLight = Color(0xFFCCFBF1);
  static const Color tealDark = Color(0xFF0F766E);

  // Aliases pour compatibilité
  static const Color purple = violet;
  static const Color textTertiary = Color(0xFF9CA3AF);

  // 📝 Couleurs de Texte Sophistiquées
  static const Color textPrimary = Color(0xFF0F172A); // Presque noir
  static const Color textSecondary = Color(0xFF475569); // Gris moyen
  static const Color textMuted = Color(0xFF94A3B8); // Gris clair
  static const Color textOnPrimary = Color(0xFFFFFFFF); // Blanc sur bleu
  static const Color textOnDark = Color(0xFFFFFFFF); // Blanc sur sombre

  // 🎨 Couleurs de Surface
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8FAFC);
  static const Color surfaceTint = Color(0xFFF1F5F9);
  static const Color onSurface = textPrimary;

  // 💎 Glassmorphism Premium
  static final Color glassLight = Colors.white.withOpacity(0.95);
  static final Color glassDark = const Color(0xFF1E293B).withOpacity(0.85);
  static final Color glassAccent = primary.withOpacity(0.1);

  // Tokens de glass sophistiqués
  static const double glassBlur = 12.0;
  static const double glassBorderOpacity = 0.2;
  static final Color glassBorder = Colors.white.withOpacity(glassBorderOpacity);

  // 🎨 Gradients Signature
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [primaryLight, accent],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [surface, surfaceVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// =============================================================================
// 📏 ESPACEMENTS CONSISTANTS
// =============================================================================

class AppSpacing {
  // Système d'espacement basé sur 8pt
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // EdgeInsets optimisés
  static const EdgeInsets tinyPadding = EdgeInsets.all(xs);
  static const EdgeInsets smallPadding = EdgeInsets.all(sm);
  static const EdgeInsets mediumPadding = EdgeInsets.all(md);
  static const EdgeInsets largePadding = EdgeInsets.all(lg);
  static const EdgeInsets extraLargePadding = EdgeInsets.all(xl);

  // Padding spécialisés
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets pagePadding = EdgeInsets.all(lg);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets buttonPadding =
      EdgeInsets.symmetric(horizontal: lg, vertical: md);
  static const EdgeInsets inputPadding =
      EdgeInsets.symmetric(horizontal: md, vertical: sm);

  // Marges pour la cohérence
  static const EdgeInsets cardMargin = EdgeInsets.only(bottom: md);
  static const EdgeInsets sectionMargin = EdgeInsets.only(bottom: xl);
  static const EdgeInsets tinyMargin = EdgeInsets.only(bottom: xs);
}

// =============================================================================
// 🔘 RAYONS ET FORMES
// =============================================================================

class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 999.0;

  // BorderRadius optimisés
  static const BorderRadius radiusXS = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius radiusSM = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMD = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLG = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXL = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusXXL = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius radiusFull =
      BorderRadius.all(Radius.circular(full));

  // Alias pour compatibilité
  static const BorderRadius cardRadius = radiusLG;
  static const BorderRadius buttonRadius = radiusMD;
  static const BorderRadius inputRadius = radiusSM;
  static const BorderRadius modalRadius = radiusXL;
}

// =============================================================================
// 📝 TYPOGRAPHIE INTER PREMIUM
// =============================================================================

class AppTextStyles {
  static const String fontFamily = 'Inter';

  // 🎯 Titres Premium
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48.0,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.02,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // 📝 Corps de Texte
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // 🏷️ Labels et Boutons
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  // 🎯 Buttons Sophistiqués
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    height: 1.1,
  );

  // 📝 Caption et Helper
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10.0,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.5,
  );

  // Aliases pour compatibilité
  static const TextStyle headlineLarge = h1;
  static const TextStyle headlineMedium = h2;
  static const TextStyle headlineSmall = h3;
}

// =============================================================================
// 🎭 ANIMATIONS MICROINTERACTIONS
// =============================================================================

class AppAnimations {
  // Durées sophistiquées
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration extraSlow = Duration(milliseconds: 500);

  // Courbes d'animation premium
  static const Curve slideIn = Curves.easeOutQuart;
  static const Curve slideOut = Curves.easeInQuart;
  static const Curve fadeIn = Curves.easeOut;
  static const Curve fadeOut = Curves.easeIn;
  static const Curve bounceIn = Curves.elasticOut;
  static const Curve buttonPress = Curves.easeInOut;
  static const Curve modalSlide = Curves.easeOutExpo;

  // Configurations d'animation
  static const double microOffset = 4.0;
  static const double slideOffset = 20.0;
  static const double modalOffset = 40.0;
}

// =============================================================================
// 🌟 OMBRES GLASSMORPHISM
// =============================================================================

class AppShadows {
  // Ombres sophistiquées avec glassmorphism
  static const List<BoxShadow> light = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> heavy = [
    BoxShadow(
      color: Color(0x25000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  // Ombres glass effect
  static const List<BoxShadow> glass = [
    BoxShadow(
      color: Color(0x0A2563EB),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> glassHeavy = [
    BoxShadow(
      color: Color(0x1A2563EB),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
}

// =============================================================================
// 💀 SKELETON LOADING SYSTEM
// =============================================================================

class AppSkeletons {
  // Couleurs de skeleton sophistiquées
  static const Color baseColor = Color(0xFFE2E8F0);
  static const Color highlightColor = Color(0xFFF1F5F9);
  static const Color shimmerColor = Color(0xFFFFFFFF);

  // Configuration d'animation
  static const Duration animationDuration = Duration(milliseconds: 1200);
  static const BorderRadius skeletonRadius =
      BorderRadius.all(Radius.circular(8));

  // Tailles de skeleton standardisées
  static const double textLineHeight = 16.0;
  static const double buttonHeight = 48.0;
  static const double avatarSize = 56.0;
  static const double cardHeight = 120.0;
}

// =============================================================================
// 📱 DIMENSIONS RESPONSIVES
// =============================================================================

class AppDimensions {
  // Hauteurs standardisées
  static const double buttonHeight = 48.0;
  static const double inputHeight = 48.0;
  static const double cardMinHeight = 120.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 72.0;

  // Largeurs
  static const double maxContentWidth = 600.0;
  static const double sidebarWidth = 280.0;
  static const double modalMaxWidth = 400.0;

  // Tailles d'icônes
  static const double iconSize = 24.0;
  static const double iconSizeSmall = 16.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXL = 48.0;

  // Breakpoints responsifs
  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1440.0;
}

// =============================================================================
// 🎯 STATUTS DE COMMANDE
// =============================================================================

enum OrderStatus {
  pending,
  inProgress,
  ready,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.inProgress:
        return 'En cours';
      case OrderStatus.ready:
        return 'Prêt';
      case OrderStatus.delivered:
        return 'Livré';
      case OrderStatus.cancelled:
        return 'Annulé';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.inProgress:
        return AppColors.info;
      case OrderStatus.ready:
        return AppColors.success;
      case OrderStatus.delivered:
        return AppColors.textSecondary;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.pending;
      case OrderStatus.inProgress:
        return Icons.refresh;
      case OrderStatus.ready:
        return Icons.check_circle;
      case OrderStatus.delivered:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }
}

// =============================================================================
// ⚙️ CONFIGURATION API
// =============================================================================

class ApiConfig {
  static const String baseUrl = 'https://api.alphapressing.com';
  static const String apiVersion = 'v1';
  static const Duration timeout = Duration(seconds: 30);

  // Endpoints
  static const String ordersEndpoint = '/orders';
  static const String servicesEndpoint = '/services';
  static const String userEndpoint = '/user';
  static const String authEndpoint = '/auth';
}

// =============================================================================
// 💾 STORAGE KEYS
// =============================================================================

class StorageKeys {
  static const String userToken = 'user_token';
  static const String userId = 'user_id';
  static const String userProfile = 'user_profile';
  static const String appSettings = 'app_settings';
  static const String orderDrafts = 'order_drafts';
  static const String favoriteServices = 'favorite_services';
}

// =============================================================================
// 🎲 VALEURS PAR DÉFAUT
// =============================================================================

class AppDefaults {
  static const String defaultLanguage = 'fr';
  static const String defaultCurrency = 'EUR';
  static const int defaultPageSize = 20;
  static const int maxRetryAttempts = 3;

  // Timeouts
  static const Duration cacheTimeout = Duration(hours: 1);
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration notificationDelay = Duration(seconds: 3);
}
