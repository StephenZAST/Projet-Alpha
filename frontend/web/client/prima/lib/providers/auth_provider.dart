import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      _error = null;
      notifyListeners();

      await _dio.post(
        '$baseUrl/auth/logout',
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );
    } on DioException catch (e) {
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

  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final AuthResponse response =
          (await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo:
            kIsWeb ? null : 'io.supabase.flutterquickstart://login-callback/',
      )) as AuthResponse;

      // Vérifier si l'authentification a réussi
      if (response.session != null) {
        final User? user = response.session?.user;

        if (user != null) {
          _token = response.session?.accessToken;
          _user = {
            'id': user.id,
            'email': user.email,
            'name': user.userMetadata?['full_name'],
          };
          _isAuthenticated = true;
          notifyListeners();
          return true;
        }
      }

      _error = 'Échec de la connexion avec Google';
      return false;
    } catch (e) {
      _error = 'Erreur de connexion Google: $e';
      print('Google Sign In Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
