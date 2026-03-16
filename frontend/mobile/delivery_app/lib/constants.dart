import 'package:flutter/material.dart';

/// 🎨 Design System Mobile-First - Alpha Delivery App
///
/// Ce fichier centralise tous les tokens de design optimisés pour mobile
/// avec une approche glassmorphism moderne et cohérente.

// =============================================================================
// 🎨 COULEURS PRINCIPALES
// =============================================================================

class AppColors {
  // Couleurs primaires
  static const Color primary = Color(0xFF2563EB); // Modern blue
  static const Color primaryLight = Color(0xFF60A5FA); // Light blue
  static const Color primaryDark = Color(0xFF1E40AF); // Dark blue

  // Couleurs secondaires
  static const Color secondary = Color(0xFF8B5CF6); // Violet
  static const Color accent = Color(0xFF06B6D4); // Cyan

  // Couleurs de statut
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Blue

  // Couleurs neutres
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

  // Couleurs de texte
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFF9FAFB);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Couleurs de bordure
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF374151);

  // Couleurs de fond glassmorphism
  static const Color cardBgLight = Color(0xE6FFFFFF); // white @ 0.9
  static const Color cardBgDark = Color(0xCC1E293B); // gray800 @ 0.8

  // Tokens glassmorphism
  static const double glassBlurSigma = 10.0;
  static const double glassBorderLightOpacity = 0.5;
  static const double glassBorderDarkOpacity = 0.3;
}

// =============================================================================
// 📏 ESPACEMENTS MOBILE-FIRST
// =============================================================================

class MobileSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0; // Base spacing mobile
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// Alias pour compatibilité
class AppSpacing {
  static const double xs = MobileSpacing.xs;
  static const double sm = MobileSpacing.sm;
  static const double md = MobileSpacing.md;
  static const double lg = MobileSpacing.lg;
  static const double xl = MobileSpacing.xl;
  static const double xxl = MobileSpacing.xxl;
}

// =============================================================================
// 📐 DIMENSIONS TOUCH-FRIENDLY
// =============================================================================

class MobileDimensions {
  // Tailles minimales pour l'accessibilité
  static const double minTouchTarget = 48.0;

  // Hauteurs optimisées mobile
  static const double cardHeight = 120.0; // Cards optimales
  static const double buttonHeight = 56.0; // Boutons Material
  static const double bottomNavHeight = 80.0; // Navigation bottom
  static const double appBarHeight = 64.0; // AppBar mobile

  // Largeurs de conteneurs
  static const double maxCardWidth = 400.0;
  static const double maxDialogWidth = 500.0;

  // Rayons de bordure
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
}

// Alias pour compatibilité
class AppRadius {
  static const BorderRadius radiusXS =
      BorderRadius.all(Radius.circular(MobileDimensions.radiusXS));
  static const BorderRadius radiusSM =
      BorderRadius.all(Radius.circular(MobileDimensions.radiusSM));
  static const BorderRadius radiusMD =
      BorderRadius.all(Radius.circular(MobileDimensions.radiusMD));
  static const BorderRadius radiusLG =
      BorderRadius.all(Radius.circular(MobileDimensions.radiusLG));
  static const BorderRadius radiusXL =
      BorderRadius.all(Radius.circular(MobileDimensions.radiusXL));
}

// =============================================================================
// ✍️ TYPOGRAPHIE MOBILE
// =============================================================================

class AppTextStyles {
  // Titres
  static const TextStyle h1 = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // Corps de texte
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // Boutons
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
  );

  // Labels et captions
  static const TextStyle label = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 10.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );
}

// =============================================================================
// 🎬 ANIMATIONS MOBILE
// =============================================================================

class AppAnimations {
  // Durées d'animation
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  // Courbes d'animation
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounce = Curves.elasticOut;

  // Transitions spécifiques mobile
  static const Curve swipeTransition = Curves.easeOutCubic;
  static const Curve fabAnimation = Curves.elasticOut;
  static const Curve cardHover = Curves.easeInOut;
}

// =============================================================================
// 🌟 OMBRES ET ÉLÉVATIONS
// =============================================================================

class AppShadows {
  static List<BoxShadow> small = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> medium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> large = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glassmorphism = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

// =============================================================================
// 📱 BREAKPOINTS RESPONSIVE
// =============================================================================

class AppBreakpoints {
  static const double mobile = 480.0;
  static const double tablet = 768.0;
  static const double desktop = 1024.0;
  static const double largeDesktop = 1440.0;
}

// =============================================================================
// 🎯 STATUTS DE COMMANDES
// =============================================================================

enum OrderStatus {
  DRAFT,
  PENDING,
  COLLECTING,
  COLLECTED,
  PROCESSING,
  READY,
  DELIVERING,
  DELIVERED,
  CANCELLED,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.DRAFT:
        return 'Brouillon';
      case OrderStatus.PENDING:
        return 'En attente';
      case OrderStatus.COLLECTING:
        return 'Collecte';
      case OrderStatus.COLLECTED:
        return 'Collectée';
      case OrderStatus.PROCESSING:
        return 'Traitement';
      case OrderStatus.READY:
        return 'Prête';
      case OrderStatus.DELIVERING:
        return 'Livraison';
      case OrderStatus.DELIVERED:
        return 'Livrée';
      case OrderStatus.CANCELLED:
        return 'Annulée';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.DRAFT:
        return AppColors.gray400;
      case OrderStatus.PENDING:
        return AppColors.warning;
      case OrderStatus.COLLECTING:
        return AppColors.info;
      case OrderStatus.COLLECTED:
        return AppColors.primary;
      case OrderStatus.PROCESSING:
        return AppColors.secondary;
      case OrderStatus.READY:
        return AppColors.accent;
      case OrderStatus.DELIVERING:
        return AppColors.primary;
      case OrderStatus.DELIVERED:
        return AppColors.success;
      case OrderStatus.CANCELLED:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.DRAFT:
        return Icons.edit_outlined;
      case OrderStatus.PENDING:
        return Icons.schedule_outlined;
      case OrderStatus.COLLECTING:
        return Icons.local_shipping_outlined;
      case OrderStatus.COLLECTED:
        return Icons.inventory_2_outlined;
      case OrderStatus.PROCESSING:
        return Icons.settings_outlined;
      case OrderStatus.READY:
        return Icons.check_circle_outline;
      case OrderStatus.DELIVERING:
        return Icons.delivery_dining_outlined;
      case OrderStatus.DELIVERED:
        return Icons.done_all_outlined;
      case OrderStatus.CANCELLED:
        return Icons.cancel_outlined;
    }
  }
}

// =============================================================================
// 🌐 CONFIGURATION API
// =============================================================================

class ApiConfig {
  // ⚠️ IMPORTANT: Configuration pour tester localement vs production
  // Utiliser: flutter run -d chrome -v --dart-define=USE_LOCAL=true
  // Pour tester avec le backend local (localhost:3001)
  // Sans le flag, utilise le backend Render en production
  
  static const bool _useLocal = bool.fromEnvironment('USE_LOCAL', defaultValue: false);
  
  // URL de base (adaptée selon l'environnement)
  static const String baseUrl = _useLocal
      ? 'http://localhost:3001/api'
      : 'https://alpha-laundry-backend.onrender.com/api';

  // Endpoints principaux
  static const String authEndpoint = '/auth';
  static const String deliveryEndpoint = '/delivery';
  static const String ordersEndpoint = '/orders';
  static const String usersEndpoint = '/users';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers par défaut
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  /// Affiche la configuration actuelle (utile pour déboguer)
  static void printConfig() {
    print('═══════════════════════════════════════════════════════════');
    print('🌐 API Configuration');
    print('═══════════════════════════════════════════════════════════');
    print('Mode: ${_useLocal ? '🔴 LOCAL (localhost:3001)' : '🟢 PRODUCTION (Render)'}');
    print('Base URL: $baseUrl');
    print('═══════════════════════════════════════════════════════════');
  }
}

// =============================================================================
// 🗺️ CONFIGURATION CARTE
// =============================================================================

class MapConfig {
  // Centre par défaut (Dakar, Sénégal)
  static const double defaultLatitude = 14.7167;
  static const double defaultLongitude = -17.4677;

  // Niveaux de zoom
  static const double minZoom = 5.0;
  static const double maxZoom = 18.0;
  static const double defaultZoom = 13.0;

  // URLs des tuiles OpenStreetMap
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String osmAttribution = '© OpenStreetMap contributors';

  // Limites de performance
  static const int maxMarkersOnMap = 1000;
  static const Duration locationUpdateInterval = Duration(seconds: 30);
}

// =============================================================================
// 🔔 CONFIGURATION NOTIFICATIONS
// =============================================================================

class NotificationConfig {
  static const String channelId = 'alpha_delivery_channel';
  static const String channelName = 'Alpha Delivery Notifications';
  static const String channelDescription =
      'Notifications pour les livreurs Alpha Laundry';

  // Types de notifications
  static const String orderAssigned = 'order_assigned';
  static const String orderStatusChanged = 'order_status_changed';
  static const String locationUpdate = 'location_update';
}

// =============================================================================
// 💾 CLÉS DE STOCKAGE LOCAL
// =============================================================================

class StorageKeys {
  static const String authToken = 'auth_token';
  static const String userProfile = 'user_profile';
  static const String appSettings = 'app_settings';
  static const String lastLocation = 'last_location';
  static const String offlineOrders = 'offline_orders';
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
}

// =============================================================================
// 🎛️ PARAMÈTRES PAR DÉFAUT
// =============================================================================

class AppDefaults {
  // Pagination
  static const int itemsPerPage = 20;
  static const int maxItemsPerPage = 100;

  // Refresh
  static const Duration autoRefreshInterval = Duration(minutes: 5);
  static const Duration pullToRefreshDuration = Duration(seconds: 2);

  // Performance
  static const int maxCachedImages = 100;
  static const Duration cacheExpiration = Duration(hours: 24);

  // Géolocalisation
  static const double locationAccuracy = 10.0; // mètres
  static const Duration locationTimeout = Duration(seconds: 15);
}
