import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../constants.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';

/// 🎮 Contrôleur Principal - Alpha Delivery App
/// 
/// Gère l'état global de l'application, les paramètres utilisateur,
/// et la coordination entre les différents services.
class AppController extends GetxController {
  
  // ==========================================================================
  // 📦 SERVICES
  // ==========================================================================
  
  late final AuthService _authService;
  late final LocationService _locationService;
  late final NotificationService _notificationService;
  late final GetStorage _storage;
  
  // ==========================================================================
  // 🎯 ÉTATS OBSERVABLES
  // ==========================================================================
  
  // Thème et apparence
  final _themeMode = ThemeMode.system.obs;
  final _isDarkMode = false.obs;
  
  // Navigation
  final _currentIndex = 0.obs;
  final _previousIndex = 0.obs;
  
  // État de l'application
  final _isOnline = true.obs;
  final _isAppActive = true.obs;
  final _lastActivityTime = DateTime.now().obs;
  
  // Paramètres utilisateur
  final _notificationsEnabled = true.obs;
  final _locationTrackingEnabled = true.obs;
  final _autoRefreshEnabled = true.obs;
  final _soundEnabled = true.obs;
  final _vibrationEnabled = true.obs;
  
  // Statistiques de session
  final _sessionStartTime = DateTime.now().obs;
  final _totalSessionTime = Duration.zero.obs;
  
  // ==========================================================================
  // 🎯 GETTERS
  // ==========================================================================
  
  // Thème
  ThemeMode get themeMode => _themeMode.value;
  bool get isDarkMode => _isDarkMode.value;
  
  // Navigation
  int get currentIndex => _currentIndex.value;
  int get previousIndex => _previousIndex.value;
  
  // État
  bool get isOnline => _isOnline.value;
  bool get isAppActive => _isAppActive.value;
  DateTime get lastActivityTime => _lastActivityTime.value;
  
  // Paramètres
  bool get notificationsEnabled => _notificationsEnabled.value;
  bool get locationTrackingEnabled => _locationTrackingEnabled.value;
  bool get autoRefreshEnabled => _autoRefreshEnabled.value;
  bool get soundEnabled => _soundEnabled.value;
  bool get vibrationEnabled => _vibrationEnabled.value;
  
  // Session
  DateTime get sessionStartTime => _sessionStartTime.value;
  Duration get totalSessionTime => _totalSessionTime.value;
  Duration get currentSessionDuration => DateTime.now().difference(_sessionStartTime.value);
  
  // Getters observables
  Rx<ThemeMode> get themeModeRx => _themeMode;
  RxBool get isDarkModeRx => _isDarkMode;
  RxInt get currentIndexRx => _currentIndex;
  RxBool get isOnlineRx => _isOnline;
  
  // ==========================================================================
  // 🚀 INITIALISATION
  // ==========================================================================
  
  @override
  Future<void> onInit() async {
    super.onInit();
    debugPrint('🎮 Initialisation AppController...');
    
    // Initialise les services
    _initializeServices();
    
    // Charge les paramètres sauvegardés
    await _loadSettings();
    
    // Configure les listeners
    _setupListeners();
    
    // Démarre la session
    _startSession();
    
    debugPrint('✅ AppController initialisé');
  }
  
  @override
  void onClose() {
    _endSession();
    super.onClose();
  }
  
  /// Initialise les références aux services
  void _initializeServices() {
    _authService = Get.find<AuthService>();
    _locationService = Get.find<LocationService>();
    _notificationService = Get.find<NotificationService>();
    _storage = GetStorage();
  }
  
  /// Charge les paramètres sauvegardés
  Future<void> _loadSettings() async {
    try {
      final settings = _storage.read<Map<String, dynamic>>(StorageKeys.appSettings) ?? {};
      
      // Thème
      final themeString = settings['theme_mode'] as String?;
      if (themeString != null) {
        _themeMode.value = _parseThemeMode(themeString);
      }
      
      // Paramètres
      _notificationsEnabled.value = settings['notifications_enabled'] as bool? ?? true;
      _locationTrackingEnabled.value = settings['location_tracking_enabled'] as bool? ?? true;
      _autoRefreshEnabled.value = settings['auto_refresh_enabled'] as bool? ?? true;
      _soundEnabled.value = settings['sound_enabled'] as bool? ?? true;
      _vibrationEnabled.value = settings['vibration_enabled'] as bool? ?? true;
      
      debugPrint('✅ Paramètres chargés');
      
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement des paramètres: $e');
    }
  }
  
  /// Sauvegarde les paramètres
  Future<void> _saveSettings() async {
    try {
      final settings = {
        'theme_mode': _themeMode.value.toString(),
        'notifications_enabled': _notificationsEnabled.value,
        'location_tracking_enabled': _locationTrackingEnabled.value,
        'auto_refresh_enabled': _autoRefreshEnabled.value,
        'sound_enabled': _soundEnabled.value,
        'vibration_enabled': _vibrationEnabled.value,
        'last_updated': DateTime.now().toIso8601String(),
      };
      
      await _storage.write(StorageKeys.appSettings, settings);
      debugPrint('💾 Paramètres sauvegardés');
      
    } catch (e) {
      debugPrint('❌ Erreur lors de la sauvegarde: $e');
    }
  }
  
  /// Configure les listeners d'événements
  void _setupListeners() {
    // Écoute les changements d'authentification
    ever(_authService.isAuthenticatedRx, (bool isAuthenticated) {
      if (isAuthenticated) {
        _onUserLoggedIn();
      } else {
        _onUserLoggedOut();
      }
    });
    
    // Écoute les changements de thème système
    ever(_isDarkMode, (bool isDark) {
      if (_themeMode.value == ThemeMode.system) {
        Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
      }
    });
  }
  
  // ==========================================================================
  // 🎨 GESTION DU THÈME
  // ==========================================================================
  
  /// Change le mode de thème
  void changeThemeMode(ThemeMode mode) {
    _themeMode.value = mode;
    Get.changeThemeMode(mode);
    _saveSettings();
    
    debugPrint('🎨 Thème changé: $mode');
  }
  
  /// Bascule entre thème clair et sombre
  void toggleTheme() {
    final newMode = _themeMode.value == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    changeThemeMode(newMode);
  }
  
  /// Met à jour l'état du mode sombre
  void updateDarkMode(bool isDark) {
    _isDarkMode.value = isDark;
  }
  
  /// Parse le mode de thème depuis une chaîne
  ThemeMode _parseThemeMode(String themeString) {
    switch (themeString) {
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.system':
      default:
        return ThemeMode.system;
    }
  }
  
  // ==========================================================================
  // 🧭 GESTION DE LA NAVIGATION
  // ==========================================================================
  
  /// Change l'index de navigation
  void changeTabIndex(int index) {
    if (index != _currentIndex.value) {
      _previousIndex.value = _currentIndex.value;
      _currentIndex.value = index;
      _updateLastActivity();
      
      debugPrint('🧭 Navigation: tab $index');
    }
  }
  
  /// Retourne au tab précédent
  void goToPreviousTab() {
    changeTabIndex(_previousIndex.value);
  }
  
  /// Réinitialise la navigation au dashboard
  void resetToHome() {
    changeTabIndex(0);
  }
  
  // ==========================================================================
  // ⚙️ GESTION DES PARAMÈTRES
  // ==========================================================================
  
  /// Active/désactive les notifications
  void toggleNotifications(bool enabled) {
    _notificationsEnabled.value = enabled;
    _saveSettings();
    
    if (!enabled) {
      _notificationService.cancelAllNotifications();
    }
    
    debugPrint('🔔 Notifications: $enabled');
  }
  
  /// Active/désactive le suivi de localisation
  void toggleLocationTracking(bool enabled) {
    _locationTrackingEnabled.value = enabled;
    _saveSettings();
    
    if (enabled) {
      _locationService.startTracking();
    } else {
      _locationService.stopTracking();
    }
    
    debugPrint('📍 Suivi localisation: $enabled');
  }
  
  /// Active/désactive l'actualisation automatique
  void toggleAutoRefresh(bool enabled) {
    _autoRefreshEnabled.value = enabled;
    _saveSettings();
    
    debugPrint('🔄 Actualisation auto: $enabled');
  }
  
  /// Active/désactive le son
  void toggleSound(bool enabled) {
    _soundEnabled.value = enabled;
    _saveSettings();
    
    debugPrint('🔊 Son: $enabled');
  }
  
  /// Active/désactive les vibrations
  void toggleVibration(bool enabled) {
    _vibrationEnabled.value = enabled;
    _saveSettings();
    
    debugPrint('📳 Vibration: $enabled');
  }
  
  // ==========================================================================
  // 🔄 GESTION DE L'ÉTAT DE L'APPLICATION
  // ==========================================================================
  
  /// Met à jour l'état en ligne/hors ligne
  void updateOnlineStatus(bool isOnline) {
    if (_isOnline.value != isOnline) {
      _isOnline.value = isOnline;
      
      if (isOnline) {
        debugPrint('🌐 Application en ligne');
        _onAppBackOnline();
      } else {
        debugPrint('📴 Application hors ligne');
        _onAppGoesOffline();
      }
    }
  }
  
  /// Met à jour l'état actif de l'application
  void updateAppActiveStatus(bool isActive) {
    _isAppActive.value = isActive;
    
    if (isActive) {
      _updateLastActivity();
      debugPrint('👁️ Application active');
    } else {
      debugPrint('😴 Application en arrière-plan');
    }
  }
  
  /// Met à jour l'heure de dernière activité
  void _updateLastActivity() {
    _lastActivityTime.value = DateTime.now();
  }
  
  // ==========================================================================
  // 📊 GESTION DE SESSION
  // ==========================================================================
  
  /// Démarre une nouvelle session
  void _startSession() {
    _sessionStartTime.value = DateTime.now();
    debugPrint('🚀 Session démarrée: ${_sessionStartTime.value}');
  }
  
  /// Termine la session actuelle
  void _endSession() {
    final sessionDuration = DateTime.now().difference(_sessionStartTime.value);
    _totalSessionTime.value = _totalSessionTime.value + sessionDuration;
    
    debugPrint('🏁 Session terminée. Durée: ${_formatDuration(sessionDuration)}');
  }
  
  /// Formate une durée pour l'affichage
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}min ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}min ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
  
  // ==========================================================================
  // 🔐 ÉVÉNEMENTS D'AUTHENTIFICATION
  // ==========================================================================
  
  /// Appelé lors de la connexion d'un utilisateur
  void _onUserLoggedIn() {
    debugPrint('👤 Utilisateur connecté');
    
    // Démarre le suivi de localisation si activé
    if (_locationTrackingEnabled.value) {
      _locationService.startTracking();
    }
    
    // Réinitialise la navigation
    resetToHome();
  }
  
  /// Appelé lors de la déconnexion d'un utilisateur
  void _onUserLoggedOut() {
    debugPrint('👤 Utilisateur déconnecté');
    
    // Arrête le suivi de localisation
    _locationService.stopTracking();
    
    // Annule toutes les notifications
    _notificationService.cancelAllNotifications();
    
    // Réinitialise l'état
    resetToHome();
  }
  
  // ==========================================================================
  // 🌐 ÉVÉNEMENTS DE CONNECTIVITÉ
  // ==========================================================================
  
  /// Appelé quand l'application revient en ligne
  void _onAppBackOnline() {
    // Synchronise les données si nécessaire
    // TODO: Implémenter la synchronisation
  }
  
  /// Appelé quand l'application passe hors ligne
  void _onAppGoesOffline() {
    // Sauvegarde l'état local
    _saveSettings();
  }
  
  // ==========================================================================
  // 🔧 MÉTHODES UTILITAIRES
  // ==========================================================================
  
  /// Réinitialise tous les paramètres aux valeurs par défaut
  Future<void> resetToDefaults() async {
    _themeMode.value = ThemeMode.system;
    _notificationsEnabled.value = true;
    _locationTrackingEnabled.value = true;
    _autoRefreshEnabled.value = true;
    _soundEnabled.value = true;
    _vibrationEnabled.value = true;
    
    await _saveSettings();
    
    debugPrint('🔄 Paramètres réinitialisés');
  }
  
  /// Obtient un résumé de l'état de l'application
  Map<String, dynamic> getAppStatus() {
    return {
      'theme_mode': _themeMode.value.toString(),
      'is_dark_mode': _isDarkMode.value,
      'current_tab': _currentIndex.value,
      'is_online': _isOnline.value,
      'is_active': _isAppActive.value,
      'session_duration': currentSessionDuration.inMinutes,
      'last_activity': _lastActivityTime.value.toIso8601String(),
      'settings': {
        'notifications': _notificationsEnabled.value,
        'location_tracking': _locationTrackingEnabled.value,
        'auto_refresh': _autoRefreshEnabled.value,
        'sound': _soundEnabled.value,
        'vibration': _vibrationEnabled.value,
      },
    };
  }
  
  /// Vérifie si l'application est configurée correctement
  bool get isProperlyConfigured {
    return _authService.isAuthenticated &&
           _notificationService.isInitialized &&
           _locationService.isLocationEnabled;
  }
  
  /// Obtient la couleur d'accent selon le thème
  Color get accentColor {
    return _isDarkMode.value ? AppColors.primaryLight : AppColors.primary;
  }
}