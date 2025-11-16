import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../utils/storage_service.dart';
import '../../constants.dart';

/// 🔐 Service d'Authentification - Alpha Client App
///
/// Gère l'authentification utilisateur avec le backend Alpha Pressing
/// Integration avec les endpoints /api/auth selon REFERENCE_FEATURES.md
class AuthService {
  /// 🔑 Connexion utilisateur
  /// Endpoint: POST /api/auth/login
  Future<AuthResult> login(String email, String password) async {
    try {
      debugPrint('[AuthService] POST ${ApiConfig.url('/auth/login')}');
      debugPrint('[AuthService] Payload: identifier=$email, password=***');
      final response = await http
          .post(
            Uri.parse(ApiConfig.url('/auth/login')),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'identifier': email,
              'password': password,
            }),
          )
          .timeout(ApiConfig.timeout);

      debugPrint('[AuthService] Status: ${response.statusCode}');
      debugPrint('[AuthService] Response: ${response.body}');

      final data = jsonDecode(response.body);
      debugPrint('[AuthService] Parsed data: $data');

      if (response.statusCode == 200) {
        try {
          // Gérer les deux formats de réponse possibles du backend
          Map<String, dynamic> responseData;
          if (data.containsKey('success') && data['success'] == true) {
            // Nouveau format: { "success": true, "data": { "user": ..., "token": ... } }
            responseData = data['data'];
            debugPrint('[AuthService] Format nouveau détecté');
          } else if (data.containsKey('data')) {
            // Ancien format: { "data": { "user": ..., "token": ... } }
            responseData = data['data'];
            debugPrint('[AuthService] Format ancien détecté');
          } else {
            debugPrint('[AuthService] Format de réponse inattendu: $data');
            return AuthResult.error('Format de réponse inattendu du serveur');
          }

          debugPrint('[AuthService] Response data: $responseData');

          if (!responseData.containsKey('user') ||
              !responseData.containsKey('token')) {
            debugPrint(
                '[AuthService] Données manquantes - user: ${responseData.containsKey('user')}, token: ${responseData.containsKey('token')}');
            return AuthResult.error('Données utilisateur ou token manquants');
          }

          debugPrint('[AuthService] User data: ${responseData['user']}');
          final user = User.fromJson(responseData['user']);
          final token = responseData['token'];

          // Sauvegarder les données utilisateur
          await StorageService.saveUser(user);
          await StorageService.saveToken(token);

          debugPrint('[AuthService] Connexion réussie, userId=${user.id}');
          return AuthResult.success(user, token);
        } catch (e, stack) {
          debugPrint('[AuthService] Erreur lors du parsing des données: $e');
          debugPrint('[AuthService] Stack trace: $stack');
          return AuthResult.error(
              'Erreur lors du traitement des données: ${e.toString()}');
        }
      } else {
        final errorMessage =
            data['error'] ?? data['message'] ?? 'Erreur de connexion';
        debugPrint('[AuthService] Erreur backend: $errorMessage');
        return AuthResult.error(errorMessage);
      }
    } catch (e, stack) {
      debugPrint('[AuthService] Exception: $e');
      debugPrint(stack.toString());
      return AuthResult.error('Erreur de connexion: ${e.toString()}');
    }
  }

  /// 📝 Inscription utilisateur
  /// Endpoint: POST /api/auth/register
  Future<AuthResult> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.url('/auth/register')),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'password': password,
              'firstName': firstName,
              'lastName': lastName,
              'phone': phone,
              'role': 'CLIENT', // Rôle client par défaut
            }),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final user = User.fromJson(data['data']['user']);
        final token = data['data']['token'];

        // Sauvegarder les données utilisateur
        await StorageService.saveUser(user);
        await StorageService.saveToken(token);

        return AuthResult.success(user, token);
      } else {
        return AuthResult.error(data['message'] ?? 'Erreur d\'inscription');
      }
    } catch (e) {
      return AuthResult.error('Erreur d\'inscription: ${e.toString()}');
    }
  }

  /// 🔄 Vérification du token
  /// Endpoint: GET /api/auth/verify
  Future<bool> verifyToken() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse(ApiConfig.url('/auth/verify')),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConfig.timeout);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// 🚪 Déconnexion
  Future<void> logout() async {
    await StorageService.clearUser();
    await StorageService.clearToken();
  }

  /// 👤 Récupérer l'utilisateur actuel
  Future<User?> getCurrentUser() async {
    return await StorageService.getUser();
  }

  /// 🔑 Récupérer le token actuel
  Future<String?> getCurrentToken() async {
    return await StorageService.getToken();
  }

  /// 📧 Mot de passe oublié
  /// Endpoint: POST /api/auth/forgot-password
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.url('/auth/forgot-password')),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'email': email,
            }),
          )
          .timeout(ApiConfig.timeout);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

/// 📊 Résultat d'authentification
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? token;
  final String? error;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.token,
    this.error,
  });

  factory AuthResult.success(User user, String token) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      token: token,
    );
  }

  factory AuthResult.error(String error) {
    return AuthResult._(
      isSuccess: false,
      error: error,
    );
  }
}
