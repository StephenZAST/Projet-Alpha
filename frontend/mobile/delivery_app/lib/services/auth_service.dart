import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';

import '../constants.dart';
import '../models/user.dart';
import 'api_service.dart';

/// 🔐 Service d'Authentification - Alpha Delivery App
///
/// Gère l'authentification des livreurs avec JWT,
/// la persistance de session et la synchronisation avec le backend.
class AuthService extends GetxService {
  // ==========================================================================
  // 📦 PROPRIÉTÉS
  // ==========================================================================

  final GetStorage _storage = GetStorage();
  ApiService get _apiService => Get.find<ApiService>();

  // États observables
  final _isAuthenticated = false.obs;
  final _currentUser = Rxn<DeliveryUser>();
  final _isLoading = false.obs;
  final _token = RxnString();

  // ==========================================================================
  // 🎯 GETTERS
  // ==========================================================================

  bool get isAuthenticated => _isAuthenticated.value;
  DeliveryUser? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  String? get token => _token.value;

  // Getters observables pour les widgets
  RxBool get isAuthenticatedRx => _isAuthenticated;
  Rxn<DeliveryUser> get currentUserRx => _currentUser;
  RxBool get isLoadingRx => _isLoading;

  // ==========================================================================
  // 👤 GESTION UTILISATEUR
  // ==========================================================================

  /// Met à jour l'utilisateur actuel
  void setCurrentUser(DeliveryUser? user) {
    _currentUser.value = user;
    debugPrint('👤 Utilisateur mis à jour: ${user?.email}');
  }

  // ==========================================================================
  // 🚀 INITIALISATION
  // ==========================================================================

  @override
  Future<void> onInit() async {
    super.onInit();
    debugPrint('🔐 Initialisation AuthService...');

    // Charge la session sauvegardée
    await _loadSavedSession();

    debugPrint('✅ AuthService initialisé');
  }

  /// Charge la session sauvegardée depuis le stockage local
  Future<void> _loadSavedSession() async {
    try {
      final savedToken = _storage.read<String>(StorageKeys.authToken);
      final savedUserData =
          _storage.read<Map<String, dynamic>>(StorageKeys.userProfile);

      if (savedToken != null && savedUserData != null) {
        _token.value = savedToken;
        _currentUser.value = DeliveryUser.fromJson(savedUserData);
        _isAuthenticated.value = true;

        // Configure le token dans ApiService
        _apiService.setAuthToken(savedToken);

        debugPrint('✅ Session restaurée pour: ${_currentUser.value?.email}');

        // Vérifie la validité du token
        await _validateToken();
      }
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement de la session: $e');
      await logout();
    }
  }

  /// Vérifie la validité du token auprès du serveur
  Future<void> _validateToken() async {
    try {
      final response = await _apiService.get('/auth/validate');

      if (response.statusCode != 200) {
        debugPrint('⚠️ Token invalide, déconnexion...');
        await logout();
      }
    } catch (e) {
      debugPrint('⚠️ Impossible de valider le token: $e');
      // On garde la session locale mais on marque comme non validée
    }
  }

  // ==========================================================================
  // 🔑 MÉTHODES D'AUTHENTIFICATION
  // ==========================================================================

  /// Connexion avec email et mot de passe
  Future<AuthResult> login(String email, String password) async {
    try {
      _isLoading.value = true;

      debugPrint('🔐 Tentative de connexion pour: $email');

      final response = await _apiService.post(
        '/auth/admin/login', // Utilise le même endpoint que l'admin
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // Vérifie la structure de la réponse
        if (responseData['success'] != true || responseData['data'] == null) {
          return AuthResult.error('Réponse invalide du serveur');
        }
        
        final data = responseData['data'] as Map<String, dynamic>;

        // Vérifie que l'utilisateur a un rôle autorisé (DELIVERY, ADMIN, SUPER_ADMIN)
        final userRole = data['user']['role'] as String;
        final allowedRoles = ['DELIVERY', 'ADMIN', 'SUPER_ADMIN'];

        if (!allowedRoles.contains(userRole)) {
          return AuthResult.error('Accès non autorisé pour ce rôle');
        }

        debugPrint('✅ Connexion autorisée pour le rôle: $userRole');

        // Sauvegarde les données d'authentification
        final token = data['token'] as String;
        final userData = data['user'] as Map<String, dynamic>;

        await _saveSession(token, userData);

        debugPrint('✅ Connexion réussie');
        return AuthResult.success();
      } else {
        final message = response.data['message'] ?? 'Erreur de connexion';
        return AuthResult.error(message);
      }
    } on DioException catch (e) {
      debugPrint('❌ Erreur Dio lors de la connexion: ${e.message}');

      if (e.response?.statusCode == 401) {
        return AuthResult.error('Email ou mot de passe incorrect');
      } else if (e.response?.statusCode == 403) {
        return AuthResult.error('Accès non autorisé');
      } else {
        return AuthResult.error('Erreur de connexion au serveur');
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la connexion: $e');
      return AuthResult.error('Une erreur inattendue s\'est produite');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    try {
      debugPrint('🚪 Déconnexion en cours...');

      // Vérifier si on est déjà en cours de déconnexion pour éviter les boucles
      if (!_isAuthenticated.value) {
        debugPrint('⚠️ Déjà déconnecté, arrêt du processus');
        return;
      }

      // Marquer comme déconnecté immédiatement pour éviter les boucles
      _isAuthenticated.value = false;

      // Appel au serveur pour invalider le token (optionnel)
      try {
        // Seulement si on a un token valide
        if (_token.value != null && _token.value!.isNotEmpty) {
          await _apiService.post('/auth/logout');
        }
      } catch (e) {
        debugPrint('⚠️ Erreur lors de la déconnexion serveur: $e');
        // Ne pas relancer d'erreur, continuer le nettoyage local
      }

      // Nettoyage local
      await _clearSession();

      debugPrint('✅ Déconnexion terminée');
    } catch (e) {
      debugPrint('❌ Erreur lors de la déconnexion: $e');
      // Force le nettoyage même en cas d'erreur
      await _clearSession();
    }
  }

  /// Actualise le token d'authentification
  Future<bool> refreshToken() async {
    try {
      debugPrint('🔄 Actualisation du token...');

      final response = await _apiService.post('/auth/refresh');

      if (response.statusCode == 200) {
        final newToken = response.data['token'] as String;

        _token.value = newToken;
        await _storage.write(StorageKeys.authToken, newToken);
        _apiService.setAuthToken(newToken);

        debugPrint('✅ Token actualisé');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'actualisation du token: $e');
      return false;
    }
  }

  // ==========================================================================
  // 💾 GESTION DE SESSION
  // ==========================================================================

  /// Sauvegarde la session d'authentification
  Future<void> _saveSession(String token, Map<String, dynamic> userData) async {
    try {
      // Sauvegarde en local
      await _storage.write(StorageKeys.authToken, token);
      await _storage.write(StorageKeys.userProfile, userData);

      // Met à jour l'état
      _token.value = token;
      _currentUser.value = DeliveryUser.fromJson(userData);
      _isAuthenticated.value = true;

      // Configure ApiService
      _apiService.setAuthToken(token);
    } catch (e) {
      debugPrint('❌ Erreur lors de la sauvegarde de session: $e');
      rethrow;
    }
  }

  /// Efface la session d'authentification
  Future<void> _clearSession() async {
    try {
      // Nettoyage du stockage local
      await _storage.remove(StorageKeys.authToken);
      await _storage.remove(StorageKeys.userProfile);

      // Reset de l'état
      _token.value = null;
      _currentUser.value = null;
      _isAuthenticated.value = false;

      // Nettoyage ApiService
      _apiService.clearAuthToken();
    } catch (e) {
      debugPrint('❌ Erreur lors du nettoyage de session: $e');
    }
  }

  // ==========================================================================
  // 👤 GESTION DU PROFIL
  // ==========================================================================

  /// Met à jour le profil utilisateur
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      debugPrint('👤 Mise à jour du profil...');

      final response = await _apiService.put(
        '/users/profile',
        data: profileData,
      );

      if (response.statusCode == 200) {
        final updatedUserData = response.data['user'] as Map<String, dynamic>;

        // Met à jour localement
        _currentUser.value = DeliveryUser.fromJson(updatedUserData);
        await _storage.write(StorageKeys.userProfile, updatedUserData);

        debugPrint('✅ Profil mis à jour');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Erreur lors de la mise à jour du profil: $e');
      return false;
    }
  }

  /// Change le mot de passe
  Future<AuthResult> changePassword(
      String currentPassword, String newPassword) async {
    try {
      debugPrint('🔒 Changement de mot de passe...');

      final response = await _apiService.put(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Mot de passe changé');
        return AuthResult.success();
      } else {
        final message = response.data['message'] ?? 'Erreur lors du changement';
        return AuthResult.error(message);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return AuthResult.error('Mot de passe actuel incorrect');
      } else {
        return AuthResult.error('Erreur lors du changement de mot de passe');
      }
    } catch (e) {
      debugPrint('❌ Erreur lors du changement de mot de passe: $e');
      return AuthResult.error('Une erreur inattendue s\'est produite');
    }
  }

  // ==========================================================================
  // 🔧 MÉTHODES UTILITAIRES
  // ==========================================================================

  /// Vérifie si l'utilisateur a un rôle spécifique
  bool hasRole(String role) {
    return _currentUser.value?.role == role;
  }

  /// Vérifie si l'utilisateur est un livreur
  bool get isDeliveryUser => hasRole('DELIVERY');

  /// Vérifie si l'utilisateur est un admin
  bool get isAdmin => hasRole('ADMIN');

  /// Vérifie si l'utilisateur est un super admin
  bool get isSuperAdmin => hasRole('SUPER_ADMIN');

  /// Vérifie si l'utilisateur a des privilèges admin (ADMIN ou SUPER_ADMIN)
  bool get hasAdminPrivileges => isAdmin || isSuperAdmin;

  /// Vérifie si l'utilisateur peut accéder aux fonctionnalités de livraison
  bool get canAccessDeliveryFeatures => isDeliveryUser || hasAdminPrivileges;

  /// Obtient le niveau de privilège de l'utilisateur
  int get privilegeLevel {
    if (isSuperAdmin) return 3;
    if (isAdmin) return 2;
    if (isDeliveryUser) return 1;
    return 0;
  }

  /// Obtient le nom d'affichage du rôle
  String get roleDisplayName {
    switch (_currentUser.value?.role) {
      case 'SUPER_ADMIN':
        return 'Super Administrateur';
      case 'ADMIN':
        return 'Administrateur';
      case 'DELIVERY':
        return 'Livreur';
      default:
        return 'Utilisateur';
    }
  }

  /// Obtient la couleur associée au rôle
  Color get roleColor {
    switch (_currentUser.value?.role) {
      case 'SUPER_ADMIN':
        return const Color(0xFF9C27B0); // Purple
      case 'ADMIN':
        return const Color(0xFF2196F3); // Blue
      case 'DELIVERY':
        return const Color(0xFF4CAF50); // Green
      default:
        return const Color(0xFF757575); // Grey
    }
  }

  /// Obtient l'icône associée au rôle
  IconData get roleIcon {
    switch (_currentUser.value?.role) {
      case 'SUPER_ADMIN':
        return Icons.admin_panel_settings;
      case 'ADMIN':
        return Icons.manage_accounts;
      case 'DELIVERY':
        return Icons.delivery_dining;
      default:
        return Icons.person;
    }
  }

  /// Obtient les headers d'authentification
  Map<String, String> get authHeaders {
    if (_token.value != null) {
      return {'Authorization': 'Bearer ${_token.value}'};
    }
    return {};
  }
}

/// 📊 Résultat d'une opération d'authentification
class AuthResult {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;

  AuthResult._({
    required this.success,
    this.message,
    this.data,
  });

  factory AuthResult.success({String? message, Map<String, dynamic>? data}) {
    return AuthResult._(
      success: true,
      message: message,
      data: data,
    );
  }

  factory AuthResult.error(String message) {
    return AuthResult._(
      success: false,
      message: message,
    );
  }
}
