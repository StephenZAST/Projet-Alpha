import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static const String _baseUrl = 'http://localhost:3001/api';

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'token': data['token'],
          'expiry': DateTime.now().add(Duration(hours: 24)).toIso8601String(),
          'user': data['user'],
        };
      }
      throw _handleError(response);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  static Future<User> getCurrentUser() async {
    try {
      final response = await ApiService.get('auth/admin/me');
      return User.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  static Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      await ApiService.post('auth/admin/change-password', {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  static Exception _handleError(http.Response response) {
    switch (response.statusCode) {
      case 401:
        return Exception('Invalid credentials');
      case 403:
        return Exception('Access denied');
      default:
        return Exception('Server error: ${response.statusCode}');
    }
  }
}
