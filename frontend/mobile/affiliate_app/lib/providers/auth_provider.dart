import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../services/api_service.dart';

/// 🔐 Provider d'Authentification - Alpha Affiliate App
///
/// Provider pour la gestion de l'authentification des affiliés
/// Compatible avec le système d'auth existant du backend

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // État d'authentification
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  
  // Informations utilisateur
  String? _userId;
  String? _email;
  String? _firstName;
  String? _lastName;
  String? _role;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  String? get userId => _userId;
  String? get email => _email;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get role => _role;
  
  String get displayName => _firstName != null && _lastName != null 
      ? '$_firstName $_lastName' 
      : _email ?? 'Utilisateur';
  
  String get initials => _firstName != null && _lastName != null
      ? '${_firstName![0]}${_lastName![0]}'.toUpperCase()
      : 'U';

  /// 🚀 Initialiser le provider
  Future<void> initialize() async {
    await _loadStoredAuth();
  }

  /// 📱 Charger l'authentification stockée
  Future<void> _loadStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);
      
      if (token != null) {
        _userId = prefs.getString(StorageKeys.userId);
        _email = prefs.getString('user_email');
        _firstName = prefs.getString('user_first_name');
        _lastName = prefs.getString('user_last_name');
        _role = prefs.getString(StorageKeys.userRole);
        
        await _apiService.setAuthToken(token);
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      print('Erreur lors du chargement de l\'auth: $e');
    }
  }

  /// 🔑 Connexion
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/auth/login', // Utiliser l'endpoint client standard
        data: {
          'email': email,
          'password': password,
        },
      );

      bool success = false;
      response.onSuccess((data) async {
        if (data['success'] == true && data['data'] != null) {
          final userData = data['data'] as Map<String, dynamic>;
          final token = userData['token'] as String;
          final user = userData['user'] as Map<String, dynamic>;

          // Vérifier que l'utilisateur peut être affilié
          // (soit déjà affilié, soit client qui peut devenir affilié)
          await _saveAuthData(token, user);
          _isAuthenticated = true;
          success = true;
        }
      });

      response.onError((error) {
        _error = error.message;
      });

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Erreur de connexion: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 📝 Inscription (si nécessaire)
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    String? affiliateCode,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        affiliateCode != null 
            ? ApiConfig.registerWithCode 
            : '/auth/register',
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          if (phone != null) 'phone': phone,
          if (affiliateCode != null) 'affiliateCode': affiliateCode,
        },
      );

      bool success = false;
      response.onSuccess((data) async {
        if (data['success'] == true && data['data'] != null) {
          final userData = data['data'] as Map<String, dynamic>;
          
          // Si inscription avec code affilié, l'utilisateur est automatiquement connecté
          if (userData['token'] != null) {
            final token = userData['token'] as String;
            final user = userData['user'] as Map<String, dynamic>;
            
            await _saveAuthData(token, user);
            _isAuthenticated = true;
          }
          
          success = true;
        }
      });

      response.onError((error) {
        _error = error.message;
      });

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Erreur d\'inscription: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 💾 Sauvegarder les données d'authentification
  Future<void> _saveAuthData(String token, Map<String, dynamic> user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _userId = user['id'] as String;
      _email = user['email'] as String;
      _firstName = user['firstName'] as String?;
      _lastName = user['lastName'] as String?;
      _role = user['role'] as String?;

      await Future.wait([
        _apiService.setAuthToken(token),
        prefs.setString(StorageKeys.userId, _userId!),
        prefs.setString('user_email', _email!),
        if (_firstName != null) prefs.setString('user_first_name', _firstName!),
        if (_lastName != null) prefs.setString('user_last_name', _lastName!),
        if (_role != null) prefs.setString(StorageKeys.userRole, _role!),
      ]);
    } catch (e) {
      print('Erreur lors de la sauvegarde: $e');
    }
  }

  /// 🚪 Déconnexion
  Future<void> logout() async {
    try {
      // Appeler l'endpoint de déconnexion si disponible
      await _apiService.post('/auth/logout');
    } catch (e) {
      // Ignorer les erreurs de déconnexion côté serveur
      print('Erreur lors de la déconnexion: $e');
    }

    // Nettoyer les données locales
    await _clearAuthData();
    
    _isAuthenticated = false;
    _userId = null;
    _email = null;
    _firstName = null;
    _lastName = null;
    _role = null;
    _error = null;
    
    notifyListeners();
  }

  /// 🧹 Nettoyer les données d'authentification
  Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await Future.wait([
        _apiService.clearAuthToken(),
        prefs.remove(StorageKeys.authToken),
        prefs.remove(StorageKeys.userId),
        prefs.remove('user_email'),
        prefs.remove('user_first_name'),
        prefs.remove('user_last_name'),
        prefs.remove(StorageKeys.userRole),
      ]);
    } catch (e) {
      print('Erreur lors du nettoyage: $e');
    }
  }

  /// 🔄 Actualiser le token
  Future<bool> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(StorageKeys.refreshToken);
      
      if (refreshToken == null) return false;

      final response = await _apiService.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      bool success = false;
      response.onSuccess((data) async {
        if (data['success'] == true && data['data'] != null) {
          final token = data['data']['token'] as String;
          await _apiService.setAuthToken(token);
          success = true;
        }
      });

      return success;
    } catch (e) {
      print('Erreur lors du refresh: $e');
      return false;
    }
  }

  /// ❌ Nettoyer les erreurs
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 🔍 Vérifier si l'utilisateur peut devenir affilié
  bool get canBecomeAffiliate {
    // Logique pour déterminer si l'utilisateur peut devenir affilié
    // Par exemple, vérifier le rôle, l'état du compte, etc.
    return _role == 'CLIENT' || _role == 'AFFILIATE';
  }

  /// 📊 Informations utilisateur pour l'affichage
  Map<String, dynamic> get userInfo {
    return {
      'id': _userId,
      'email': _email,
      'firstName': _firstName,
      'lastName': _lastName,
      'displayName': displayName,
      'initials': initials,
      'role': _role,
      'canBecomeAffiliate': canBecomeAffiliate,
    };
  }
}