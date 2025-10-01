import 'package:flutter/material.dart';
import '../../core/models/user.dart' as model;
import '../../core/services/user_profile_service.dart' as ups;

/// 👤 Provider de Profil Utilisateur - Alpha Client App
///
/// Gère l'état du profil utilisateur avec synchronisation backend
/// et gestion des préférences et statistiques.
class UserProfileProvider extends ChangeNotifier {
  final ups.UserProfileService _userProfileService = ups.UserProfileService();

  // État du profil utilisateur
  model.User? _currentUser;
  ups.UserStats? _userStats;
  model.NotificationPreferences? _notificationPreferences;

  // États de chargement et d'erreur
  bool _isLoading = false;
  bool _isUpdating = false;
  bool _isChangingPassword = false;
  String? _error;

  // Getters
  model.User? get currentUser => _currentUser;
  ups.UserStats? get userStats => _userStats;
  model.NotificationPreferences? get notificationPreferences =>
      _notificationPreferences;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get isChangingPassword => _isChangingPassword;
  String? get error => _error;

  // Getters calculés
  bool get hasUserData => _currentUser != null;
  String get userDisplayName => _currentUser?.fullName ?? 'Utilisateur';
  String get userInitials => _currentUser?.initials ?? 'U';
  bool get hasStats => _userStats != null;

  /// 🚀 Initialisation du provider
  Future<void> initialize() async {
    _setLoading(true);

    try {
      // Charger le profil utilisateur
      await loadUserProfile();

      // Charger les statistiques
      await loadUserStats();

      _clearError();
    } catch (e) {
      _setError('Erreur d\'initialisation: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 👤 Charger le profil utilisateur
  Future<void> loadUserProfile() async {
    try {
      _currentUser = await _userProfileService.getUserProfile();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Erreur de chargement du profil: ${e.toString()}');
    }
  }

  /// 📊 Charger les statistiques utilisateur
  Future<void> loadUserStats() async {
    try {
      _userStats = await _userProfileService.getUserStats();
      notifyListeners();
    } catch (e) {
      // Erreur silencieuse pour les statistiques
    }
  }

  /// ✏️ Mettre à jour le profil utilisateur
  Future<bool> updateUserProfile(ups.UpdateUserProfileRequest request) async {
    _isUpdating = true;
    _clearError();
    notifyListeners();

    try {
      final result = await _userProfileService.updateUserProfile(request);

      if (result.isSuccess && result.user != null) {
        _currentUser = result.user;
        _clearError();
        notifyListeners();
        return true;
      } else {
        _setError(result.error ?? 'Erreur lors de la mise à jour du profil');
        return false;
      }
    } catch (e) {
      _setError('Erreur de connexion: ${e.toString()}');
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  /// 🔒 Changer le mot de passe
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isChangingPassword = true;
    _clearError();
    notifyListeners();

    try {
      final result = await _userProfileService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (result.isSuccess) {
        _clearError();
        return true;
      } else {
        _setError(result.error ?? 'Erreur lors du changement de mot de passe');
        return false;
      }
    } catch (e) {
      _setError('Erreur de connexion: ${e.toString()}');
      return false;
    } finally {
      _isChangingPassword = false;
      notifyListeners();
    }
  }

  /// 🔔 Mettre à jour les préférences de notification
  Future<bool> updateNotificationPreferences(
      model.NotificationPreferences preferences) async {
    try {
      // Convert model.NotificationPreferences -> service.NotificationPreferences
      final ups.NotificationPreferences upsPrefs = ups.NotificationPreferences(
        emailNotifications: preferences.newsletter,
        pushNotifications: preferences.push,
        smsNotifications: preferences.sms,
        orderUpdates: preferences.orderUpdates,
        promotionalOffers: preferences.promotions,
        loyaltyUpdates: false,
      );

      final result =
          await _userProfileService.updateNotificationPreferences(upsPrefs);

      if (result.isSuccess) {
        // Keep provider state as the model type
        _notificationPreferences = preferences;
        _clearError();
        notifyListeners();
        return true;
      } else {
        _setError(
            result.error ?? 'Erreur lors de la mise à jour des préférences');
        return false;
      }
    } catch (e) {
      _setError('Erreur de connexion: ${e.toString()}');
      return false;
    }
  }

  /// 🗑️ Supprimer le compte utilisateur
  Future<bool> deleteAccount(String password) async {
    _setLoading(true);
    _clearError();
    notifyListeners();

    try {
      final result = await _userProfileService.deleteAccount(password);

      if (result.isSuccess) {
        // Nettoyer les données locales
        _currentUser = null;
        _userStats = null;
        _notificationPreferences = null;
        _clearError();
        notifyListeners();
        return true;
      } else {
        _setError(result.error ?? 'Erreur lors de la suppression du compte');
        return false;
      }
    } catch (e) {
      _setError('Erreur de connexion: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// 🔄 Actualiser toutes les données
  Future<void> refresh() async {
    await initialize();
  }

  /// 👤 Mettre à jour les données utilisateur localement
  void updateLocalUser(model.User user) {
    _currentUser = user;
    notifyListeners();
  }

  /// 🔧 Méthodes utilitaires privées
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

  /// 🧹 Nettoyage des ressources
  @override
  void dispose() {
    super.dispose();
  }

  /// 🎯 Méthodes utilitaires pour l'UI

  /// Obtenir les informations de fidélité
  Map<String, dynamic> get loyaltyInfo {
    if (_userStats != null) {
      return {
        'points': _userStats!.loyaltyPoints,
        'tier': _userStats!.loyaltyTier,
        'totalSpent': _userStats!.totalSpent,
        'totalOrders': _userStats!.totalOrders,
      };
    }
    return {
      'points': _currentUser?.profile?.loyaltyInfo?.points ?? 0,
      'tier': _currentUser?.profile?.loyaltyInfo?.tier ?? 'Bronze',
      'totalSpent': 0.0,
      'totalOrders': 0,
    };
  }

  /// Vérifier si l'utilisateur peut modifier son profil
  bool get canEditProfile => _currentUser != null && !_isUpdating;

  /// Obtenir le niveau de complétude du profil
  double get profileCompleteness {
    if (_currentUser == null) return 0.0;

    int completedFields = 0;
    int totalFields = 6;

    if (_currentUser!.firstName.isNotEmpty) completedFields++;
    if (_currentUser!.lastName.isNotEmpty) completedFields++;
    if (_currentUser!.email.isNotEmpty) completedFields++;
    if (_currentUser!.phone?.isNotEmpty == true) completedFields++;
    if (_currentUser!.profile?.dateOfBirth != null) completedFields++;
    if (_currentUser!.profile?.defaultAddress != null) completedFields++;

    return completedFields / totalFields;
  }

  /// Obtenir les suggestions d'amélioration du profil
  List<String> get profileSuggestions {
    if (_currentUser == null) return [];

    List<String> suggestions = [];

    if (_currentUser!.profile?.dateOfBirth == null) {
      suggestions.add('Ajoutez votre date de naissance');
    }
    if (_currentUser!.profile?.defaultAddress == null) {
      suggestions.add('Configurez une adresse par défaut');
    }
    if (_currentUser!.profile?.defaultPaymentMethod == null) {
      suggestions.add('Ajoutez un moyen de paiement');
    }
    if (_notificationPreferences == null) {
      suggestions.add('Configurez vos préférences de notification');
    }

    return suggestions;
  }

  /// Vérifier si l'utilisateur a des données sensibles
  bool get hasSensitiveData {
    return _currentUser != null &&
        ((_currentUser!.profile?.defaultPaymentMethod != null) ||
            _userStats?.totalSpent != null && _userStats!.totalSpent > 0);
  }
}
