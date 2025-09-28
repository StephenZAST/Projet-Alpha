import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';

/// ⚙️ Contrôleur Paramètres - Alpha Delivery App
///
/// Gère la logique métier des paramètres de l'application.
/// Fonctionnalités : notifications, thème, langue, cache, confidentialité.
class SettingsController extends GetxController {
  // ==========================================================================
  // ⚙️ PROPRIÉTÉS RÉACTIVES
  // ==========================================================================

  final isLoading = false.obs;

  // Notifications
  final pushNotificationsEnabled = true.obs;
  final notificationSoundsEnabled = true.obs;
  final vibrationsEnabled = true.obs;
  final notificationStartHour = 8.obs;
  final notificationEndHour = 20.obs;

  // Apparence
  final themeMode = AppThemeMode.system.obs;
  final language = AppLanguage.french.obs;
  final animationsEnabled = true.obs;

  // Carte et GPS
  final gpsPrecision = GpsPrecision.high.obs;
  final locationTrackingEnabled = true.obs;
  final defaultNavigationApp = NavigationApp.googleMaps.obs;

  // Données et cache
  final offlineModeEnabled = false.obs;
  final cacheSize = 0.0.obs;
  final syncFrequency = SyncFrequency.realTime.obs;

  // Confidentialité
  final analyticsEnabled = true.obs;
  final crashReportsEnabled = true.obs;

  // À propos
  final appVersion = '1.0.0'.obs;

  // ==========================================================================
  // 🚀 INITIALISATION
  // ==========================================================================

  @override
  void onInit() {
    super.onInit();
    debugPrint('⚙️ Initialisation SettingsController...');

    // Charger les paramètres sauvegardés
    loadSettings();
  }

  /// Charge les paramètres depuis le stockage local
  Future<void> loadSettings() async {
    try {
      isLoading.value = true;

      // Simuler le chargement des préférences
      // TODO: Implémenter SharedPreferences quand la dépendance sera ajoutée
      final Map<String, dynamic> mockPrefs = {
        'push_notifications': true,
        'notification_sounds': true,
        'vibrations': true,
        'notification_start_hour': 8,
        'notification_end_hour': 20,
        'theme_mode': 0,
        'language': 0,
        'animations': true,
        'gps_precision': 1,
        'location_tracking': true,
        'navigation_app': 0,
        'offline_mode': false,
        'sync_frequency': 0,
        'analytics': true,
        'crash_reports': true,
      };

      // Notifications
      pushNotificationsEnabled.value = mockPrefs['push_notifications'] ?? true;
      notificationSoundsEnabled.value = mockPrefs['notification_sounds'] ?? true;
      vibrationsEnabled.value = mockPrefs['vibrations'] ?? true;
      notificationStartHour.value = mockPrefs['notification_start_hour'] ?? 8;
      notificationEndHour.value = mockPrefs['notification_end_hour'] ?? 20;

      // Apparence
      final themeIndex = mockPrefs['theme_mode'] ?? 0;
      themeMode.value = AppThemeMode.values[themeIndex];

      final languageIndex = mockPrefs['language'] ?? 0;
      language.value = AppLanguage.values[languageIndex];

      animationsEnabled.value = mockPrefs['animations'] ?? true;

      // Carte et GPS
      final gpsIndex = mockPrefs['gps_precision'] ?? 1;
      gpsPrecision.value = GpsPrecision.values[gpsIndex];

      locationTrackingEnabled.value = mockPrefs['location_tracking'] ?? true;

      final navIndex = mockPrefs['navigation_app'] ?? 0;
      defaultNavigationApp.value = NavigationApp.values[navIndex];

      // Données et cache
      offlineModeEnabled.value = mockPrefs['offline_mode'] ?? false;

      final syncIndex = mockPrefs['sync_frequency'] ?? 0;
      syncFrequency.value = SyncFrequency.values[syncIndex];

      // Confidentialité
      analyticsEnabled.value = mockPrefs['analytics'] ?? true;
      crashReportsEnabled.value = mockPrefs['crash_reports'] ?? true;

      // Calculer la taille du cache
      await _calculateCacheSize();

      debugPrint('✅ Paramètres chargés');
    } catch (e) {
      debugPrint('❌ Erreur chargement paramètres: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Sauvegarde un paramètre
  Future<void> _saveSetting(String key, dynamic value) async {
    try {
      // Simuler la sauvegarde des préférences
      // TODO: Implémenter SharedPreferences quand la dépendance sera ajoutée
      debugPrint('💾 Paramètre sauvegardé: $key = $value');
    } catch (e) {
      debugPrint('❌ Erreur sauvegarde paramètre $key: $e');
    }
  }

  // ==========================================================================
  // 🔔 GESTION DES NOTIFICATIONS
  // ==========================================================================

  /// Bascule les notifications push
  Future<void> togglePushNotifications(bool enabled) async {
    pushNotificationsEnabled.value = enabled;
    await _saveSetting('push_notifications', enabled);

    if (enabled) {
      // Simuler la demande de permissions de notification
      // TODO: Implémenter NotificationService.requestPermissions()
      debugPrint('🔔 Demande de permissions de notification');
    }

    Get.snackbar(
      'Notifications',
      enabled ? 'Notifications activées' : 'Notifications désactivées',
      backgroundColor: enabled ? AppColors.success : AppColors.warning,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  /// Bascule les sons de notification
  Future<void> toggleNotificationSounds(bool enabled) async {
    notificationSoundsEnabled.value = enabled;
    await _saveSetting('notification_sounds', enabled);
  }

  /// Bascule les vibrations
  Future<void> toggleVibrations(bool enabled) async {
    vibrationsEnabled.value = enabled;
    await _saveSetting('vibrations', enabled);
  }

  /// Définit les heures de notification
  Future<void> setNotificationHours(int startHour, int endHour) async {
    notificationStartHour.value = startHour;
    notificationEndHour.value = endHour;

    await _saveSetting('notification_start_hour', startHour);
    await _saveSetting('notification_end_hour', endHour);
  }

  // ==========================================================================
  // 🎨 GESTION DE L'APPARENCE
  // ==========================================================================

  /// Définit le mode de thème
  Future<void> setThemeMode(AppThemeMode mode) async {
    themeMode.value = mode;
    await _saveSetting('theme_mode', mode.index);

    // Appliquer le thème
    switch (mode) {
      case AppThemeMode.light:
        Get.changeThemeMode(ThemeMode.light);
        break;
      case AppThemeMode.dark:
        Get.changeThemeMode(ThemeMode.dark);
        break;
      case AppThemeMode.system:
        Get.changeThemeMode(ThemeMode.system);
        break;
    }

    Get.snackbar(
      'Thème',
      'Thème ${mode.displayName} appliqué',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  /// Définit la langue
  Future<void> setLanguage(AppLanguage lang) async {
    language.value = lang;
    await _saveSetting('language', lang.index);

    // Appliquer la langue
    Get.updateLocale(lang.locale);

    Get.snackbar(
      'Langue',
      'Langue ${lang.displayName} appliquée',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  /// Bascule les animations
  Future<void> toggleAnimations(bool enabled) async {
    animationsEnabled.value = enabled;
    await _saveSetting('animations', enabled);
  }

  // ==========================================================================
  // 🗺️ GESTION CARTE ET GPS
  // ==========================================================================

  /// Définit la précision GPS
  Future<void> setGpsPrecision(GpsPrecision precision) async {
    gpsPrecision.value = precision;
    await _saveSetting('gps_precision', precision.index);

    // Simuler l'application de la nouvelle précision
    // TODO: Implémenter LocationService.updateLocationSettings()
    debugPrint('📍 Précision GPS mise à jour: ${precision.displayName}');
  }

  /// Bascule le suivi de position
  Future<void> toggleLocationTracking(bool enabled) async {
    locationTrackingEnabled.value = enabled;
    await _saveSetting('location_tracking', enabled);

    if (enabled) {
      // Simuler la demande de permissions de localisation
      // TODO: Implémenter LocationService.requestPermissions()
      debugPrint('📍 Demande de permissions de localisation');
    }

    Get.snackbar(
      'Suivi de position',
      enabled ? 'Suivi activé' : 'Suivi désactivé',
      backgroundColor: enabled ? AppColors.success : AppColors.warning,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  /// Définit l'app de navigation par défaut
  Future<void> setDefaultNavigationApp(NavigationApp app) async {
    defaultNavigationApp.value = app;
    await _saveSetting('navigation_app', app.index);
  }

  // ==========================================================================
  // 💾 GESTION DONNÉES ET CACHE
  // ==========================================================================

  /// Bascule le mode hors ligne
  Future<void> toggleOfflineMode(bool enabled) async {
    offlineModeEnabled.value = enabled;
    await _saveSetting('offline_mode', enabled);

    Get.snackbar(
      'Mode hors ligne',
      enabled ? 'Mode hors ligne activé' : 'Mode hors ligne désactivé',
      backgroundColor: enabled ? AppColors.success : AppColors.info,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  /// Vide le cache
  Future<void> clearCache() async {
    try {
      isLoading.value = true;

      // Simuler le nettoyage du cache
      await Future.delayed(const Duration(seconds: 2));

      cacheSize.value = 0.0;

      Get.snackbar(
        'Cache',
        'Cache vidé avec succès',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      debugPrint('🗑️ Cache vidé');
    } catch (e) {
      debugPrint('❌ Erreur vidage cache: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de vider le cache',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Calcule la taille du cache
  Future<void> _calculateCacheSize() async {
    try {
      // Simuler le calcul de la taille du cache
      cacheSize.value = 12.5; // MB
    } catch (e) {
      debugPrint('❌ Erreur calcul taille cache: $e');
      cacheSize.value = 0.0;
    }
  }

  /// Définit la fréquence de synchronisation
  Future<void> setSyncFrequency(SyncFrequency frequency) async {
    syncFrequency.value = frequency;
    await _saveSetting('sync_frequency', frequency.index);
  }

  // ==========================================================================
  // 🔒 GESTION CONFIDENTIALITÉ
  // ==========================================================================

  /// Bascule les analytics
  Future<void> toggleAnalytics(bool enabled) async {
    analyticsEnabled.value = enabled;
    await _saveSetting('analytics', enabled);
  }

  /// Bascule les rapports de crash
  Future<void> toggleCrashReports(bool enabled) async {
    crashReportsEnabled.value = enabled;
    await _saveSetting('crash_reports', enabled);
  }

  /// Ouvre la politique de confidentialité
  Future<void> openPrivacyPolicy() async {
    const url = 'https://alpha-laundry.com/privacy';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  /// Ouvre les conditions d'utilisation
  Future<void> openTermsOfService() async {
    const url = 'https://alpha-laundry.com/terms';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  // ==========================================================================
  // ℹ️ GESTION À PROPOS
  // ==========================================================================

  /// Vérifie les mises à jour
  Future<void> checkForUpdates() async {
    try {
      isLoading.value = true;

      // Simuler la vérification de mise à jour
      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        'Mise à jour',
        'Vous avez la dernière version',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      debugPrint('❌ Erreur vérification mise à jour: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Ouvre le support
  Future<void> openSupport() async {
    const url = 'https://alpha-laundry.com/support';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  /// Évalue l'application
  Future<void> rateApp() async {
    // URL vers l'app store (à adapter selon la plateforme)
    const url =
        'https://play.google.com/store/apps/details?id=com.alpha.delivery';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  /// Affiche les licences
  void showLicenses() {
    showLicensePage(
      context: Get.context!,
      applicationName: 'Alpha Delivery App',
      applicationVersion: appVersion.value,
      applicationLegalese: '© 2024 Alpha Laundry. Tous droits réservés.',
    );
  }
}

/// 🎨 Modes de thème
enum AppThemeMode {
  light,
  dark,
  system;

  String get displayName {
    switch (this) {
      case AppThemeMode.light:
        return 'Clair';
      case AppThemeMode.dark:
        return 'Sombre';
      case AppThemeMode.system:
        return 'Système';
    }
  }
}

/// 🌍 Langues disponibles
enum AppLanguage {
  french,
  english;

  String get displayName {
    switch (this) {
      case AppLanguage.french:
        return 'Français';
      case AppLanguage.english:
        return 'English';
    }
  }

  Locale get locale {
    switch (this) {
      case AppLanguage.french:
        return const Locale('fr', 'FR');
      case AppLanguage.english:
        return const Locale('en', 'US');
    }
  }
}

/// 📍 Précision GPS
enum GpsPrecision {
  low,
  medium,
  high,
  best;

  String get displayName {
    switch (this) {
      case GpsPrecision.low:
        return 'Faible';
      case GpsPrecision.medium:
        return 'Moyenne';
      case GpsPrecision.high:
        return 'Élevée';
      case GpsPrecision.best:
        return 'Maximale';
    }
  }

  String get description {
    switch (this) {
      case GpsPrecision.low:
        return 'Économise la batterie';
      case GpsPrecision.medium:
        return 'Équilibre batterie/précision';
      case GpsPrecision.high:
        return 'Précision élevée';
      case GpsPrecision.best:
        return 'Précision maximale';
    }
  }

  LocationAccuracy get locationAccuracy {
    switch (this) {
      case GpsPrecision.low:
        return LocationAccuracy.low;
      case GpsPrecision.medium:
        return LocationAccuracy.medium;
      case GpsPrecision.high:
        return LocationAccuracy.high;
      case GpsPrecision.best:
        return LocationAccuracy.best;
    }
  }
}

/// 🧭 Applications de navigation
enum NavigationApp {
  googleMaps,
  appleMaps,
  waze;

  String get displayName {
    switch (this) {
      case NavigationApp.googleMaps:
        return 'Google Maps';
      case NavigationApp.appleMaps:
        return 'Apple Maps';
      case NavigationApp.waze:
        return 'Waze';
    }
  }
}

/// 🔄 Fréquence de synchronisation
enum SyncFrequency {
  realTime,
  every5Minutes,
  every15Minutes,
  every30Minutes,
  hourly,
  manual;

  String get displayName {
    switch (this) {
      case SyncFrequency.realTime:
        return 'Temps réel';
      case SyncFrequency.every5Minutes:
        return 'Toutes les 5 minutes';
      case SyncFrequency.every15Minutes:
        return 'Toutes les 15 minutes';
      case SyncFrequency.every30Minutes:
        return 'Toutes les 30 minutes';
      case SyncFrequency.hourly:
        return 'Toutes les heures';
      case SyncFrequency.manual:
        return 'Manuel';
    }
  }
}
