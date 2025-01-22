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
  static final _api = ApiService();

  static const String baseAuthPath = '/auth';

  static String? get token => _storage.read(_tokenKey);
  static User? get currentUser {
    final userData = _storage.read(_userKey);
    if (userData != null) {
      try {
        final Map<String, dynamic> jsonData = json.decode(userData);
        print('[AuthService] Stored user data: $jsonData');
        return User.fromJson(jsonData);
      } catch (e) {
        print('[AuthService] Error parsing stored user data: $e');
        return null;
      }
    }
    return null;
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      print('[AuthService] Attempting login with email: $email');
      final response = await _api.post(
        '$baseAuthPath/admin/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final responseData = response.data;
      print('[AuthService] Raw login response: $responseData');

      if (responseData['success'] == true && responseData['data'] != null) {
        final userData = responseData['data']['user'];
        final token = responseData['data']['token'];

        if (token == null || userData == null) {
          throw 'Missing token or user data';
        }

        print('[AuthService] User data before parsing: $userData');

        // S'assurer que les données requises sont présentes
        if (userData['id'] == null ||
            userData['email'] == null ||
            userData['role'] == null) {
          throw 'Missing required user data fields';
        }

        // Sauvegarder le token
        await _storage.write(_tokenKey, token);
        // Sauvegarder les données utilisateur
        await _storage.write(_userKey, json.encode(userData));

        print('[AuthService] Login successful');
        print('[AuthService] Token saved: $token');
        print('[AuthService] User data saved: $userData');

        // Tester la création de l'objet User avant de retourner
        try {
          final user = User.fromJson(userData);
          print(
              '[AuthService] User object created successfully: ${user.toJson()}');

          return {
            'success': true,
            'data': {
              'user': userData,
              'token': token,
            }
          };
        } catch (e) {
          print('[AuthService] Error creating user object: $e');
          throw 'Error parsing user data';
        }
      }

      return {
        'success': false,
        'message': responseData['error'] ?? 'Login failed',
      };
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
      final response = await _api.get('$baseAuthPath/admin/me');
      final responseData = response.data;

      print('[AuthService] Current user response: $responseData');

      if (responseData['success'] == true && responseData['data'] != null) {
        final userData = responseData['data'];

        print('[AuthService] User data before parsing: $userData');

        try {
          // S'assurer que les données requises sont présentes
          if (userData['id'] == null ||
              userData['email'] == null ||
              userData['role'] == null) {
            throw 'Missing required user data fields';
          }

          final user = User.fromJson(userData);
          await _storage.write(_userKey, json.encode(userData));
          print(
              '[AuthService] Current user data fetched and saved successfully: ${user.toJson()}');
          return user;
        } catch (e) {
          print('[AuthService] Error parsing user data: $e');
          throw 'Invalid user data format';
        }
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
      final response = await _api.post(
        '$baseAuthPath/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      return response.data;
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
      await _api.post(
        '$baseAuthPath/logout',
        data: {},
      );
    } catch (e) {
      print('[AuthService] Logout error: $e');
    } finally {
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
