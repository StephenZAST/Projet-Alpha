import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'constants.dart';
import 'theme/mobile_theme.dart';
import 'routes/app_routes.dart';
import 'bindings/initial_binding.dart';

/// 📱 Application principale Alpha Delivery
///
/// Configuration mobile-first avec GetX, thème glassmorphism,
/// et navigation optimisée pour les livreurs.
class DeliveryApp extends StatelessWidget {
  const DeliveryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // Configuration de base
      title: 'Alpha Delivery',
      debugShowCheckedModeBanner: false,

      // Thème mobile-first
      theme: MobileTheme.lightTheme,
      darkTheme: MobileTheme.darkTheme,
      themeMode: _getThemeMode(),

      // Navigation et routes
      initialRoute: _getInitialRoute(),
      getPages: AppRoutes.routes,
      initialBinding: InitialBinding(),

      // Configuration mobile
      builder: (context, child) {
        return _buildAppWrapper(context, child);
      },

      // Localisation
      locale: const Locale('fr', 'FR'),
      fallbackLocale: const Locale('en', 'US'),

      // Transitions
      defaultTransition: Transition.cupertino,
      transitionDuration: AppAnimations.medium,

      // Configuration GetX
      enableLog: true,
      logWriterCallback: _logWriter,
    );
  }

  /// Détermine le thème à utiliser selon les préférences
  ThemeMode _getThemeMode() {
    final storage = GetStorage();
    final savedTheme = storage.read(StorageKeys.themeMode);

    switch (savedTheme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Détermine la route initiale selon l'état d'authentification
  String _getInitialRoute() {
    try {
      final storage = GetStorage();
      final token = storage.read<String>(StorageKeys.authToken);
      
      debugPrint('🔍 Vérification du token au démarrage: ${token != null ? "présent" : "absent"}');
      
      // Si un token existe, on va directement au dashboard
      // Le middleware vérifiera sa validité
      if (token != null && token.isNotEmpty) {
        debugPrint('✅ Token trouvé - Redirection vers dashboard');
        return AppRoutes.dashboard;
      }
      
      debugPrint('❌ Pas de token - Redirection vers login');
      return AppRoutes.login;
    } catch (e) {
      debugPrint('❌ Erreur lors de la vérification du token: $e');
      return AppRoutes.login;
    }
  }

  /// Wrapper pour les configurations mobile globales
  Widget _buildAppWrapper(BuildContext context, Widget? child) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _getSystemUiOverlayStyle(context),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          // Force la taille de texte pour éviter les problèmes d'accessibilité
          textScaleFactor:
              MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
        ),
        child: GestureDetector(
          // Ferme le clavier quand on tape en dehors d'un champ
          onTap: () {
            final currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }

  /// Configuration de la barre de statut selon le thème
  SystemUiOverlayStyle _getSystemUiOverlayStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: isDark ? AppColors.gray900 : AppColors.gray50,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    );
  }

  /// Logger personnalisé pour GetX
  void _logWriter(String text, {bool isError = false}) {
    if (isError) {
      debugPrint('🔴 [GetX Error] $text');
    } else {
      debugPrint('🟢 [GetX] $text');
    }
  }
}

/// 🚀 Initialisation de l'application
///
/// Configure tous les services nécessaires avant le démarrage
class AppInitializer {
  static Future<void> initialize() async {
    try {
      // Assure que les widgets Flutter sont initialisés
      WidgetsFlutterBinding.ensureInitialized();

      // Initialise GetStorage pour la persistance locale
      await GetStorage.init();

      // Initialise les timezones pour les notifications programmées
      tz.initializeTimeZones();
      tz.setLocalLocation(
          tz.getLocation('Africa/Dakar')); // Timezone du Sénégal

      // Configure l'orientation (portrait uniquement pour mobile)
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // Configure la barre de statut
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
      );

      // Initialise les services de base
      await _initializeServices();

      debugPrint('✅ Application initialisée avec succès');
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur lors de l\'initialisation: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Initialise tous les services nécessaires
  static Future<void> _initializeServices() async {
    // Les services seront initialisés par InitialBinding
    // Cette méthode peut être utilisée pour des initialisations spéciales
    debugPrint('🔧 Préparation des services...');
  }
}

/// 🎯 Configuration des erreurs globales
///
/// Gère les erreurs non capturées de l'application
class AppErrorHandler {
  static void initialize() {
    // Capture les erreurs Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('🔴 [Flutter Error] ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');

      // En production, envoyer à un service de monitoring
      // FirebaseCrashlytics.instance.recordFlutterError(details);
    };

    // Capture les erreurs Dart non gérées
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('🔴 [Dart Error] $error');
      debugPrint('Stack trace: $stack');

      // En production, envoyer à un service de monitoring
      // FirebaseCrashlytics.instance.recordError(error, stack);

      return true;
    };
  }
}

/// 📊 Configuration des performances
///
/// Optimise les performances pour mobile
class AppPerformanceConfig {
  static void configure() {
    // Limite le nombre de frames par seconde si nécessaire
    // SchedulerBinding.instance.addPostFrameCallback((_) {
    //   SchedulerBinding.instance.scheduleWarmUpFrame();
    // });

    // Configuration du cache d'images
    PaintingBinding.instance.imageCache.maximumSize =
        AppDefaults.maxCachedImages;
    PaintingBinding.instance.imageCache.maximumSizeBytes =
        50 * 1024 * 1024; // 50MB

    debugPrint('⚡ Configuration des performances appliquée');
  }
}
