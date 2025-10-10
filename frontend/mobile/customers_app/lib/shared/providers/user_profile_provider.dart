import 'package:flutter/material.dart';
import '../../core/models/user.dart';
import '../../core/services/user_profile_service.dart';
import '../../core/utils/storage_service.dart';

/// 👤 Provider de Profil Utilisateur - Alpha Client App
///
/// Gère l'état du profil utilisateur avec données réelles
/// et statistiques de fidélité depuis le backend.
class UserProfileProvider extends ChangeNotifier {
  final UserProfileService _profileService = UserProfileService();

  User? _user;
  UserStats? _stats;
  bool _isLoading = false;
  String? _error;

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

  // Statistiques (avec fallback)
  int get totalOrders => _stats?.totalOrders ?? 0;
  double get totalSpent => _stats?.totalSpent ?? 0.0;
  int get loyaltyPoints => _stats?.loyaltyPoints ?? 0;
  int get addressCount => _stats?.addressCount ?? 0;

  // Getters calculés
  String get userDisplayName => _user?.fullName ?? 'Utilisateur';
  String get userInitials => _user?.initials ?? 'U';

  /// 🚀 Initialiser le provider
  Future<void> initialize() async {
    _setLoading(true);

    try {
      // Récupérer l'utilisateur depuis le cache d'abord
      final cachedUser = await StorageService.getUser();
      if (cachedUser != null) {
        _user = cachedUser;
        print(
            '[UserProfileProvider] Utilisateur chargé depuis le cache: ${_user!.fullName}');
        notifyListeners();
      }

      // Essayer de récupérer les données depuis l'API (profil depuis cache)
      try {
        _user = await _profileService.getUserProfile();
        print('[UserProfileProvider] Profil utilisateur récupéré');
      } catch (e) {
        print(
            '[UserProfileProvider] Impossible de récupérer le profil depuis l\'API: $e');
        // Continuer avec l'utilisateur en cache
      }

      // Récupérer les statistiques (peut échouer silencieusement)
      try {
        _stats = await _profileService.getUserStats();
        print(
            '[UserProfileProvider] Statistiques récupérées: ${_stats!.loyaltyPoints} points');
      } catch (e) {
        print(
            '[UserProfileProvider] Impossible de récupérer les statistiques: $e');
        // Statistiques par défaut
        _stats = UserStats(
          totalOrders: 0,
          totalSpent: 0.0,
          loyaltyPoints: 0,
          addressCount: 0,
        );
      }

      _clearError();
      notifyListeners();
    } catch (e) {
      print('[UserProfileProvider] Erreur initialize: $e');

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
          print('[UserProfileProvider] Fallback vers le cache réussi');
          _clearError();
          notifyListeners();
        } else {
          _setError(
              'Aucun profil utilisateur disponible. Veuillez vous reconnecter.');
        }
      }
    } finally {
      _setLoading(false);
    }
  }

  /// 🔄 Actualiser les données
  Future<void> refresh() async {
    await initialize();
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
