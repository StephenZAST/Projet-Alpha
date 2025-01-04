import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class AuthProvider extends ChangeNotifier {
  final String baseUrl = 'http://localhost:3001/api';
  bool _isAuthenticated = false;
  String? _token;
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;
  final Dio _dio = Dio();

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final cookieJar = PersistCookieJar(
      storage: FileStorage(appDocDir.path),
    );
    _dio.interceptors.add(CookieManager(cookieJar));
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _dio.post(
        '$baseUrl/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data;

      if (response.statusCode == 200 && data['data'] != null) {
        _token = data['data']['token'];
        _user = data['data']['user'];
        _isAuthenticated = true;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = data['error'] ?? 'Une erreur est survenue';
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      _error = 'Erreur de connexion: ${e.message}';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, String firstName,
      String lastName, String? phone) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _dio.post(
        '$baseUrl/auth/register',
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
        },
      );

      final data = response.data;

      if (response.statusCode == 200 && data['data'] != null) {
        _token = data['data']['token'];
        _user = data['data']['user'];
        _isAuthenticated = true;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = data['error'] ?? 'Une erreur est survenue';
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      _error = 'Erreur d\'inscription: ${e.message}';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Appel simple au backend
      await _dio.post(
        '$baseUrl/auth/logout',
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );
    } catch (e) {
      print('Logout error: $e');
    } finally {
      // Nettoyage local dans tous les cas
      _token = null;
      _user = null;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
    }
  }
}
