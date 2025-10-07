import 'package:flutter/material.dart';
import '../../core/models/user.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/storage_service.dart';

/// 🔐 Provider d'Authentification - Alpha Client App
///
/// Gère l'état d'authentification global de l'application
/// avec persistance et synchronisation automatique.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 🚀 Initialisation du provider
  Future<void> initialize() async {
    _setLoading(true);

    try {
      // Vérifier si un utilisateur est déjà connecté
      final user = await StorageService.getUser();
      final token = await StorageService.getToken();

      if (user != null && token != null) {
        // Vérifier la validité du token
        final isValidToken = await _authService.verifyToken();

        if (isValidToken) {
          _currentUser = user;
          _isAuthenticated = true;
          _clearError();
        } else {
          // Token invalide, nettoyer les données
          await _clearUserData();
        }
      }
    } catch (e) {
      _setError('Erreur d\'initialisation: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 🔑 Connexion
  Future<bool> login(String email, String password) async {
    debugPrint('[AuthProvider] Tentative de connexion pour $email');
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.login(email, password);
      debugPrint(
          '[AuthProvider] Résultat login: isSuccess=${result.isSuccess}, erreur=${result.error}');
      if (result.isSuccess && result.user != null) {
        _currentUser = result.user;
        _isAuthenticated = true;
        _clearError();
        notifyListeners();
        debugPrint('[AuthProvider] Connexion réussie pour $email');
        return true;
      } else {
        _setError(result.error ?? 'Erreur de connexion');
        debugPrint('[AuthProvider] Connexion échouée: ${result.error}');
        return false;
      }
    } catch (e, stack) {
      _setError('Erreur de connexion: ${e.toString()}');
      debugPrint('[AuthProvider] Exception lors de la connexion: $e');
      debugPrint(stack.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 📝 Inscription
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );

      if (result.isSuccess) {
        _currentUser = result.user;
        _isAuthenticated = true;
        _clearError();
        notifyListeners();
        return true;
      } else {
        _setError(result.error ?? 'Erreur d\'inscription');
        return false;
      }
    } catch (e) {
      _setError('Erreur d\'inscription: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 🚪 Déconnexion
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
      await _clearUserData();
    } catch (e) {
      _setError('Erreur de déconnexion: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 🔄 Actualiser les données utilisateur
  Future<void> refreshUser() async {
    if (!_isAuthenticated) return;

    try {
      final user = await StorageService.getUser();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    } catch (e) {
      _setError('Erreur de rafraîchissement: ${e.toString()}');
    }
  }

  /// 👤 Mettre à jour le profil utilisateur
  Future<bool> updateUserProfile(User updatedUser) async {
    _setLoading(true);

    try {
      await StorageService.saveUser(updatedUser);
      _currentUser = updatedUser;
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur de mise à jour: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 📧 Mot de passe oublié
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _authService.forgotPassword(email);

      if (!success) {
        _setError('Erreur lors de l\'envoi de l\'email');
      }

      return success;
    } catch (e) {
      _setError('Erreur: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 🎯 Vérifications utilitaires
  bool get canMakeFlashOrders {
    // Vérifier l'authentification et l'adresse par défaut
    return isAuthenticated && hasDefaultAddress;
  }

  bool get hasDefaultAddress => _currentUser?.defaultAddress != null;

  bool get hasDefaultPaymentMethod =>
      _currentUser?.defaultPaymentMethod != null;

  String get userDisplayName => _currentUser?.fullName ?? 'Utilisateur';

  String get userInitials => _currentUser?.initials ?? 'U';

  /// 🎁 Informations de fidélité
  int get loyaltyPoints => _currentUser?.profile?.loyaltyInfo?.points ?? 0;

  String get loyaltyTier =>
      _currentUser?.profile?.loyaltyInfo?.tier ?? 'Bronze';

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

  Future<void> _clearUserData() async {
    _currentUser = null;
    _isAuthenticated = false;
    await StorageService.clearUser();
    await StorageService.clearToken();
    notifyListeners();
  }

  /// 🧹 Nettoyage des ressources
  @override
  void dispose() {
    super.dispose();
  }
}
