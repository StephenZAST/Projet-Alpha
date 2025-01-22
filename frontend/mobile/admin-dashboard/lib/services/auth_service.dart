import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user.dart';
import 'api_service.dart';
import '../constants.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  static final _storage = GetStorage();

  // Base URL for all auth endpoints
  static const String baseAuthPath = 'auth';

  static String? get token => _storage.read(_tokenKey);
  static User? get currentUser {
    final userData = _storage.read(_userKey);
    if (userData != null) {
      return User.fromJson(json.decode(userData));
    }
    return null;
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      print('[AuthService] Attempting login with email: $email');
      final response = await ApiService.post(
        '$baseAuthPath/admin/login',
        {
          'email': email,
          'password': password,
        },
      );

      if (response['success'] && response['data'] != null) {
        print('[AuthService] Login successful');

        // Sauvegarder le token
        final token = response['data']['token'];
        await _storage.write(_tokenKey, token);

        // Sauvegarder les données utilisateur
        final user = response['data']['user'];
        await _storage.write(_userKey, json.encode(user));

        return response;
      }

      print('[AuthService] Login failed: ${response['message']}');
      return response;
    } catch (e) {
      print('[AuthService] Login error: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<User?> getCurrentUser() async {
    try {
      if (token == null) return null;

      print('[AuthService] Getting current user data');
      final response = await ApiService.get('$baseAuthPath/admin/me');

      if (response['success'] && response['data'] != null) {
        final user = User.fromJson(response['data']);
        await _storage.write(_userKey, json.encode(user.toJson()));
        return user;
      }
      return null;
    } catch (e) {
      print('[AuthService] Get current user error: $e');
      handleAuthError('Impossible de récupérer les données utilisateur');
      return null;
    }
  }

  static Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await ApiService.post(
        '$baseAuthPath/admin/change-password',
        {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      return response;
    } catch (e) {
      print('[AuthService] Change password error: $e');
      return {
        'success': false,
        'message': 'Erreur lors du changement de mot de passe',
      };
    }
  }

  static Future<void> logout() async {
    try {
      // Essayer de faire un logout côté serveur
      await ApiService.post('$baseAuthPath/logout', {});
    } catch (e) {
      print('[AuthService] Logout error: $e');
    } finally {
      // Toujours effacer les données locales
      clearSession();
    }
  }

  static void clearSession() {
    _storage.remove(_tokenKey);
    _storage.remove(_userKey);
  }

  static void handleAuthError(String message) {
    print('[AuthService] Auth Error: $message');
    Get.snackbar(
      'Erreur d\'authentification',
      message,
      backgroundColor: AppColors.error,
      colorText: AppColors.textLight,
      snackPosition: SnackPosition.TOP,
      padding: AppSpacing.paddingMD,
      margin: AppSpacing.marginMD,
      borderRadius: AppRadius.sm,
      duration: Duration(seconds: 4),
    );
  }
}
