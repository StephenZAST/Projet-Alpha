import 'package:flutter/material.dart';
import '../../core/models/user.dart';
import '../../core/services/user_profile_service.dart';
import '../../core/utils/storage_service.dart';

/// 👤 Provider de Profil Utilisateur - Alpha Client App
///
/// Gère l'état du profil utilisateur avec données réelles,
/// statistiques de fidélité et système de cache optimisé.
class UserProfileProvider extends ChangeNotifier {
  final UserProfileService _profileService = UserProfileService();

  User? _user;
  UserStats? _stats;
  bool _isLoading = false;
  String? _error;

  // 🔥 Cache Management
  DateTime? _lastFetch;
  bool _isInitialized = false;
  static const Duration _cacheDuration = Duration(minutes: 5); // 5 min pour profil

  // Getters
  User? get currentUser => _user;
  UserStats? get userStats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasUserData => _user != null;
  bool get hasStats =>
      _stats != null &&
      (_stats!.totalOrders > 0 ||
          _stats!.totalSpent > 0 ||
          _stats!.loyaltyPoints > 0);

  // 🔥 Cache Getters
  bool get isInitialized => _isInitialized;
  DateTime? get lastFetch => _lastFetch;
  
  bool get _shouldRefresh {
    if (_lastFetch == null) return true;
    final difference = DateTime.now().difference(_lastFetch!);
    return difference > _cacheDuration;
  }
  
  String get cacheStatus {
    if (_lastFetch == null) return 'Aucune donnée';
    final difference = DateTime.now().difference(_lastFetch!);
    final minutes = difference.inMinutes;
    if (minutes < 1) return 'À l\'instant';
    if (minutes == 1) return 'Il y a 1 minute';
    return 'Il y a $minutes minutes';
  }

  // Statistiques (avec fallback)
  int get totalOrders => _stats?.totalOrders ?? 0;
  double get totalSpent => _stats?.totalSpent ?? 0.0;
  int get loyaltyPoints => _stats?.loyaltyPoints ?? 0;
  int get addressCount => _stats?.addressCount ?? 0;

  // Getters calculés
  String get userDisplayName => _user?.fullName ?? 'Utilisateur';
  String get userInitials => _user?.initials ?? 'U';

  /// 🚀 Initialiser le provider avec système de cache
  Future<void> initialize({bool forceRefresh = false}) async {
    // 🔥 Vérifier le cache avant de charger
    if (_isInitialized && !forceRefresh && !_shouldRefresh && hasUserData) {
      debugPrint('✅ [UserProfileProvider] Cache valide - Pas de rechargement');
      debugPrint('📊 [UserProfileProvider] Dernière mise à jour: $cacheStatus');
      debugPrint('👤 [UserProfileProvider] Utilisateur: $userDisplayName');
      return;
    }

    if (forceRefresh) {
      debugPrint('🔄 [UserProfileProvider] Rechargement forcé');
    } else if (_shouldRefresh) {
      debugPrint('⏰ [UserProfileProvider] Cache expiré - Rechargement');
    } else {
      debugPrint('🆕 [UserProfileProvider] Première initialisation');
    }

    _setLoading(true);

    try {
      final startTime = DateTime.now();
      
      // 1. Recuperer l'utilisateur depuis le cache d'abord (affichage immediat)
      final cachedUser = await StorageService.getUser();
      if (cachedUser != null) {
        _user = cachedUser;
        debugPrint('[UserProfileProvider] OK Utilisateur depuis cache: ${_user!.fullName}');
        notifyListeners(); // Afficher immediatement
      }

      // 2. Essayer de recuperer les donnees depuis l'API
      try {
        _user = await _profileService.getUserProfile();
        debugPrint('[UserProfileProvider] OK Profil utilisateur recupere depuis API');
      } catch (e) {
        debugPrint('[UserProfileProvider] WARN API profil indisponible: $e');
        // Continuer avec l'utilisateur en cache
      }

      // 3. Recuperer les statistiques
      try {
        debugPrint('🔄 [UserProfileProvider] Chargement des stats...');
        _stats = await _profileService.getUserStats();
        debugPrint('✅ [UserProfileProvider] Stats récupérées:');
        debugPrint('   💰 Points: ${_stats!.loyaltyPoints}');
        debugPrint('   📦 Commandes: ${_stats!.totalOrders}');
        debugPrint('   💵 Total dépensé: ${_stats!.totalSpent}');
        debugPrint('   📍 Adresses: ${_stats!.addressCount}');
        debugPrint('   🏆 Tier: ${_stats!.loyaltyTier}');
      } catch (e) {
        debugPrint('❌ [UserProfileProvider] Erreur stats: $e');
        // Statistiques par defaut
        _stats = UserStats(
          totalOrders: 0,
          totalSpent: 0.0,
          loyaltyPoints: 0,
          addressCount: 0,
        );
        debugPrint('⚠️ [UserProfileProvider] Stats par défaut appliquées');
      }

      // Marquer comme initialise
      _isInitialized = true;
      _lastFetch = DateTime.now();
      
      final duration = DateTime.now().difference(startTime);
      debugPrint('OK [UserProfileProvider] Chargement termine en ${duration.inMilliseconds}ms');
      
      _clearError();
      notifyListeners();
      
    } catch (e) {
      debugPrint('❌ [UserProfileProvider] Erreur: $e');

      // En cas d'erreur totale, essayer de charger depuis le cache
      if (_user == null) {
        final cachedUser = await StorageService.getUser();
        if (cachedUser != null) {
          _user = cachedUser;
          _stats = UserStats(
            totalOrders: 0,
            totalSpent: 0.0,
            loyaltyPoints: 0,
            addressCount: 0,
          );
          debugPrint('[UserProfileProvider] ✅ Fallback vers le cache réussi');
          _isInitialized = true;
          _lastFetch = DateTime.now();
          _clearError();
          notifyListeners();
        } else {
          _setError('Aucun profil utilisateur disponible. Veuillez vous reconnecter.');
        }
      }
    } finally {
      _setLoading(false);
    }
  }

  /// 🔄 Actualiser les données (force le rechargement)
  Future<void> refresh() async {
    debugPrint('🔄 [UserProfileProvider] Rafraîchissement manuel');
    await initialize(forceRefresh: true);
  }
  
  /// 🗑️ Invalider le cache (pour forcer un rechargement au prochain accès)
  void invalidateCache() {
    debugPrint('🗑️ [UserProfileProvider] Cache invalidé');
    _isInitialized = false;
    _lastFetch = null;
  }
  
  /// 📝 Mettre à jour le profil utilisateur (invalide le cache)
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _profileService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
      );

      if (success) {
        debugPrint('[UserProfileProvider] ✅ Profil mis à jour');
        // Invalider le cache et recharger
        invalidateCache();
        await initialize(forceRefresh: true);
        return true;
      }

      _setError('Erreur lors de la mise à jour du profil');
      return false;
    } catch (e) {
      debugPrint('[UserProfileProvider] ❌ Erreur updateProfile: $e');
      final message = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      _setError('Erreur de mise à jour: $message');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 🔒 Changer le mot de passe
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _profileService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (success) {
        // Clear any previous error and notify
        print('[UserProfileProvider] changePassword succeeded');
        _clearError();
        notifyListeners();
        return true;
      }

      // If not success and no detailed error was provided, set a generic one
      _setError('Erreur lors du changement de mot de passe');
      return false;
    } catch (e) {
      print('[UserProfileProvider] Erreur changePassword: $e');
      // Use the exception message if available to provide better feedback
      final message = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      _setError('Erreur lors du changement de mot de passe: $message');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 📈 Calculer la complétude du profil
  double get profileCompleteness {
    if (_user == null) return 0.0;

    int completedFields = 0;
    int totalFields = 5;

    if (_user!.firstName.isNotEmpty) completedFields++;
    if (_user!.lastName.isNotEmpty) completedFields++;
    if (_user!.email.isNotEmpty) completedFields++;
    if (_user!.phone?.isNotEmpty == true) completedFields++;
    if (addressCount > 0) completedFields++;

    return completedFields / totalFields;
  }

  /// 💡 Suggestions d'amélioration du profil
  List<String> get profileSuggestions {
    if (_user == null) return [];

    List<String> suggestions = [];

    if (_user!.phone?.isEmpty != false) {
      suggestions.add('Ajoutez votre numéro de téléphone');
    }
    if (addressCount == 0) {
      suggestions.add('Ajoutez une adresse de livraison');
    }
    if (totalOrders == 0) {
      suggestions.add('Passez votre première commande');
    }
    if (loyaltyPoints < 100) {
      suggestions.add('Gagnez plus de points de fidélité');
    }

    return suggestions;
  }

  /// 🏆 Niveau de fidélité
  String get loyaltyTier {
    return _stats?.loyaltyTier ?? 'BRONZE';
  }

  /// 🎨 Couleur du niveau de fidélité
  Color get loyaltyTierColor {
    final tierColorHex = _stats?.loyaltyTierColor ?? '#F59E0B';
    return Color(int.parse(tierColorHex.replaceFirst('#', '0xFF')));
  }

  /// 💰 Montant total formaté en FCFA
  String get formattedTotalSpent {
    return _stats?.formattedTotalSpent ?? '0 FCFA';
  }

  /// 🎯 Informations de fidélité
  Map<String, dynamic> get loyaltyInfo {
    if (_stats != null) {
      return {
        'points': _stats!.loyaltyPoints,
        'tier': _stats!.loyaltyTier,
        'totalSpent': _stats!.totalSpent,
        'totalOrders': _stats!.totalOrders,
      };
    }
    return {
      'points': 0,
      'tier': 'BRONZE',
      'totalSpent': 0.0,
      'totalOrders': 0,
    };
  }

  /// 🔧 Méthodes privées
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
