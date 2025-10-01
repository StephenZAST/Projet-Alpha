import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../../constants.dart';

/// 💾 Service de Stockage Local - Alpha Client App
///
/// Gère la persistance des données utilisateur et des préférences
/// avec SharedPreferences pour une expérience fluide.
class StorageService {
  static SharedPreferences? _prefs;

  /// 🚀 Initialisation du service
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 🔐 Gestion du Token JWT
  static Future<void> saveToken(String token) async {
    await _ensureInitialized();
    await _prefs!.setString(StorageKeys.userToken, token);
  }

  static Future<String?> getToken() async {
    await _ensureInitialized();
    return _prefs!.getString(StorageKeys.userToken);
  }

  static Future<void> clearToken() async {
    await _ensureInitialized();
    await _prefs!.remove(StorageKeys.userToken);
  }

  /// 👤 Gestion de l'Utilisateur
  static Future<void> saveUser(User user) async {
    await _ensureInitialized();
    final userJson = jsonEncode(user.toJson());
    await _prefs!.setString(StorageKeys.userProfile, userJson);
    await _prefs!.setString(StorageKeys.userId, user.id);
  }

  static Future<User?> getUser() async {
    await _ensureInitialized();
    final userJson = _prefs!.getString(StorageKeys.userProfile);
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return User.fromJson(userMap);
      } catch (e) {
        // Si erreur de parsing, nettoyer les données corrompues
        await clearUser();
        return null;
      }
    }
    return null;
  }

  static Future<String?> getUserId() async {
    await _ensureInitialized();
    return _prefs!.getString(StorageKeys.userId);
  }

  static Future<void> clearUser() async {
    await _ensureInitialized();
    await _prefs!.remove(StorageKeys.userProfile);
    await _prefs!.remove(StorageKeys.userId);
  }

  /// ⚙️ Paramètres de l'Application
  static Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    await _ensureInitialized();
    final settingsJson = jsonEncode(settings);
    await _prefs!.setString(StorageKeys.appSettings, settingsJson);
  }

  static Future<Map<String, dynamic>?> getAppSettings() async {
    await _ensureInitialized();
    final settingsJson = _prefs!.getString(StorageKeys.appSettings);
    if (settingsJson != null) {
      try {
        return jsonDecode(settingsJson) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// 🌓 Préférences de Thème
  static Future<void> saveThemeMode(bool isDarkMode) async {
    await _ensureInitialized();
    await _prefs!.setBool('theme_dark_mode', isDarkMode);
  }

  static Future<bool> getThemeMode() async {
    await _ensureInitialized();
    return _prefs!.getBool('theme_dark_mode') ?? false;
  }

  /// 🛍️ Brouillons de Commandes
  static Future<void> saveOrderDraft(Map<String, dynamic> orderDraft) async {
    await _ensureInitialized();
    final draftJson = jsonEncode(orderDraft);
    await _prefs!.setString(StorageKeys.orderDrafts, draftJson);
  }

  static Future<Map<String, dynamic>?> getOrderDraft() async {
    await _ensureInitialized();
    final draftJson = _prefs!.getString(StorageKeys.orderDrafts);
    if (draftJson != null) {
      try {
        return jsonDecode(draftJson) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> clearOrderDraft() async {
    await _ensureInitialized();
    await _prefs!.remove(StorageKeys.orderDrafts);
  }

  /// ⭐ Services Favoris
  static Future<void> saveFavoriteServices(List<String> serviceIds) async {
    await _ensureInitialized();
    await _prefs!.setStringList(StorageKeys.favoriteServices, serviceIds);
  }

  static Future<List<String>> getFavoriteServices() async {
    await _ensureInitialized();
    return _prefs!.getStringList(StorageKeys.favoriteServices) ?? [];
  }

  static Future<void> addFavoriteService(String serviceId) async {
    final favorites = await getFavoriteServices();
    if (!favorites.contains(serviceId)) {
      favorites.add(serviceId);
      await saveFavoriteServices(favorites);
    }
  }

  static Future<void> removeFavoriteService(String serviceId) async {
    final favorites = await getFavoriteServices();
    favorites.remove(serviceId);
    await saveFavoriteServices(favorites);
  }

  /// 🔍 Historique de Recherche
  static Future<void> saveSearchHistory(List<String> searches) async {
    await _ensureInitialized();
    // Limiter à 10 recherches récentes
    final limitedSearches = searches.take(10).toList();
    await _prefs!.setStringList('search_history', limitedSearches);
  }

  static Future<List<String>> getSearchHistory() async {
    await _ensureInitialized();
    return _prefs!.getStringList('search_history') ?? [];
  }

  static Future<void> addSearchTerm(String searchTerm) async {
    final history = await getSearchHistory();
    // Supprimer si déjà présent pour éviter les doublons
    history.remove(searchTerm);
    // Ajouter au début
    history.insert(0, searchTerm);
    await saveSearchHistory(history);
  }

  /// 🔄 Onboarding
  static Future<void> setOnboardingCompleted() async {
    await _ensureInitialized();
    await _prefs!.setBool('onboarding_completed', true);
  }

  static Future<bool> isOnboardingCompleted() async {
    await _ensureInitialized();
    return _prefs!.getBool('onboarding_completed') ?? false;
  }

  /// 🧹 Nettoyage Complet
  static Future<void> clearAll() async {
    await _ensureInitialized();
    await _prefs!.clear();
  }

  /// 🔧 Méthode utilitaire privée
  static Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await init();
    }
  }

  /// 📊 Statistiques de Stockage
  static Future<Map<String, dynamic>> getStorageStats() async {
    await _ensureInitialized();
    final keys = _prefs!.getKeys();
    
    return {
      'totalKeys': keys.length,
      'hasUser': _prefs!.containsKey(StorageKeys.userProfile),
      'hasToken': _prefs!.containsKey(StorageKeys.userToken),
      'hasSettings': _prefs!.containsKey(StorageKeys.appSettings),
      'hasDrafts': _prefs!.containsKey(StorageKeys.orderDrafts),
      'favoriteServicesCount': (await getFavoriteServices()).length,
      'searchHistoryCount': (await getSearchHistory()).length,
      'onboardingCompleted': await isOnboardingCompleted(),
    };
  }
}