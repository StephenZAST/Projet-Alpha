import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3001/api',
    contentType: 'application/json',
    validateStatus: (status) => true, // Pour gérer nous-mêmes les status codes
  ));

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('Login response: $data'); // Debug log
        return data;
      } else {
        throw 'Invalid credentials';
      }
    } catch (e) {
      print('Login error: $e'); // Debug log
      throw e.toString();
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
