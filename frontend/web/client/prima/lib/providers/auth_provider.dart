import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:prima/models/address.dart';
import 'package:prima/providers/address_provider.dart';
import 'package:prima/providers/auth_data_provider.dart';
import 'package:prima/providers/profile_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final AuthDataProvider _authDataProvider;
  final ProfileDataProvider _profileDataProvider;
  final SharedPreferences _prefs;
  final Dio _dio;

  final String baseUrl = 'http://localhost:3001/api';
  bool _isAuthenticated = false;
  String? _token;
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;
  BuildContext? _context; // Changer late BuildContext? à BuildContext? simple

  String? _tempEmail;
  String? _tempPassword;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Ajouter les getters publics
  String? get tempEmail => _tempEmail;
  String? get tempPassword => _tempPassword;

  AuthProvider({
    required AuthDataProvider authDataProvider,
    required ProfileDataProvider profileDataProvider,
    required SharedPreferences prefs,
  })  : _authDataProvider = authDataProvider,
        _profileDataProvider = profileDataProvider,
        _prefs = prefs,
        _dio = Dio(BaseOptions(
          baseUrl: 'http://localhost:3001/api',
          headers: {'Accept': 'application/json'},
        )) {
    _setupDio();
    _init();
    _loadStoredData();
  }

  Dio _setupDio() {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {'Accept': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          _handleUnauthorized();
        }
        return handler.next(error);
      },
    ));

    return dio;
  }

  Future<void> _loadStoredData() async {
    _token = await _prefs.getString('auth_token');
    final userData = await _prefs.getString('user_data');
    if (userData != null) {
      _user = json.decode(userData);
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  void _handleUnauthorized() {
    logout();
    notifyListeners();
  }

  Future<void> _init() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final cookieJar = PersistCookieJar(
      storage: FileStorage(appDocDir.path),
    );
    _dio.interceptors.add(CookieManager(cookieJar));
  }

  void setTempCredentials(String email, String password) {
    _tempEmail = email;
    _tempPassword = password;
    notifyListeners();
  }

  void clearTempCredentials() {
    _tempEmail = null;
    _tempPassword = null;
    notifyListeners();
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Attempting login with email: $email'); // Debug log

      final response = await _dio.post(
        '$baseUrl/auth/login',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) =>
              true, // Accept all status codes for debugging
        ),
        data: {
          'email': email,
          'password': password,
        },
      );

      print('Login response status: ${response.statusCode}'); // Debug log
      print('Login response data: ${response.data}'); // Debug log

      if (response.statusCode == 200 && response.data['data'] != null) {
        final userData = response.data['data'];
        _token = userData['token'];
        _user = userData['user'];

        // Sauvegarder les données
        await _authDataProvider.saveToken(_token!);
        await _authDataProvider.saveUserData(_user!);

        // Ne charger que les adresses de l'utilisateur connecté
        if (_context != null) {
          try {
            final addressProvider =
                Provider.of<AddressProvider>(_context!, listen: false);
            final userAddresses = userData['addresses'] as List<dynamic>;
            final filteredAddresses = userAddresses
                .where((addr) => addr['user_id'] == _user!['id'])
                .toList();

            await _profileDataProvider.saveUserAddresses(
                filteredAddresses.cast<Map<String, dynamic>>());

            // Convertir la liste filtrée en une liste d'objets Address
            List<Address> addressList = filteredAddresses
                .map((addr) => Address.fromJson(addr))
                .toList();

            // Utiliser la méthode setAddresses de AddressProvider pour mettre à jour les adresses
            addressProvider.setAddresses(_context!, addressList);
          } catch (e) {
            print('Error setting addresses after login: $e');
          }
        }

        _isAuthenticated = true;
        notifyListeners();
        return true;
      }

      _error = response.data['error'] ?? 'Authentication failed';
      print('Login error: $_error'); // Debug log
      return false;
    } catch (e) {
      print('Login exception: $e'); // Debug log
      _error = 'Connection error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, String firstName,
      String lastName, String? phone, String? affiliateCode) async {
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
          'affiliateCode': affiliateCode,
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

      await _dio.post('$baseUrl/auth/logout',
          options: Options(validateStatus: (status) => status! < 500));
      await _authDataProvider.clearStoredData();
      await _profileDataProvider.clearUserData();
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
          await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo:
            kIsWeb ? null : 'io.supabase.flutterquickstart://login-callback/',
      ) as AuthResponse;

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

  // Assurez-vous que cette méthode est appelée après une connexion réussie
  void setToken(String token) {
    _token = token;
    notifyListeners();
  }
}
