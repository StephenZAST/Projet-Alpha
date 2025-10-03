import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import 'navigation_service.dart';

/// 🌐 Service API - Alpha Affiliate App
///
/// Client HTTP centralisé avec gestion automatique des tokens JWT,
/// retry automatique, logging et gestion d'erreurs.

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _authToken;

  /// Initialisation du service
  Future<void> initialize() async {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.timeout,
      receiveTimeout: ApiConfig.timeout,
      sendTimeout: ApiConfig.timeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Intercepteurs
    _dio.interceptors.add(_AuthInterceptor());
    _dio.interceptors.add(_LoggingInterceptor());
    _dio.interceptors.add(_RetryInterceptor());

    // Charger le token depuis le stockage
    await _loadAuthToken();
  }

  /// Charger le token d'authentification
  Future<void> _loadAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString(StorageKeys.authToken);

      if (_authToken != null) {
        _dio.options.headers['Authorization'] = 'Bearer $_authToken';
      }
    } catch (e) {
      print('Erreur lors du chargement du token: $e');
    }
  }

  /// Définir le token d'authentification
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.authToken, token);
    } catch (e) {
      print('Erreur lors de la sauvegarde du token: $e');
    }
  }

  /// Supprimer le token d'authentification
  Future<void> clearAuthToken() async {
    _authToken = null;
    _dio.options.headers.remove('Authorization');

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.authToken);
    } catch (e) {
      print('Erreur lors de la suppression du token: $e');
    }
  }

  /// Gestion centralisée d'un token expiré.
  /// Appelée par l'intercepteur lorsque le backend renvoie 401.
  Future<void> handleTokenExpired() async {
    try {
      print('Le token d\'authentification a expiré — nettoyage en cours.');
      await clearAuthToken();
      
      // Ne pas rediriger automatiquement, laisser l'application gérer
      // NavigationService().navigateToLogin();
    } catch (e) {
      print('Erreur lors du traitement du token expiré: $e');
    }
  }

  /// Getter pour vérifier si authentifié
  bool get isAuthenticated => _authToken != null;

  /// GET Request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error(ApiError.unknown(e.toString()));
    }
  }

  /// POST Request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error(ApiError.unknown(e.toString()));
    }
  }

  /// PUT Request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error(ApiError.unknown(e.toString()));
    }
  }

  /// PATCH Request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error(ApiError.unknown(e.toString()));
    }
  }

  /// DELETE Request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error(ApiError.unknown(e.toString()));
    }
  }

  /// Gestion des erreurs Dio
  ApiError _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiError.timeout();

      case DioExceptionType.connectionError:
        return ApiError.network();

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final message = _extractErrorMessage(error.response?.data);

        switch (statusCode) {
          case 400:
            return ApiError.badRequest(message);
          case 401:
            return ApiError.unauthorized(message);
          case 403:
            return ApiError.forbidden(message);
          case 404:
            return ApiError.notFound(message);
          case 409:
            return ApiError.conflict(message);
          case 422:
            return ApiError.validation(message);
          case 500:
            return ApiError.server(message);
          default:
            return ApiError.http(statusCode, message);
        }

      case DioExceptionType.cancel:
        return ApiError.cancelled();

      default:
        return ApiError.unknown(error.message ?? 'Erreur inconnue');
    }
  }

  /// Extraire le message d'erreur de la réponse
  String _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] ?? data['error'] ?? 'Erreur inconnue';
    }
    return data?.toString() ?? 'Erreur inconnue';
  }
}

/// 🔐 Intercepteur d'authentification
class _AuthInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expiré, déconnecter l'utilisateur
      ApiService().handleTokenExpired();
    }
    handler.next(err);
  }

  // Note: token expiry is handled centrally by ApiService.handleTokenExpired().
}

/// 📝 Intercepteur de logging
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🌐 ${options.method} ${options.uri}');
    if (options.data != null) {
      print('📤 Body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ ${err.response?.statusCode} ${err.requestOptions.uri}');
    print('Error: ${err.message}');
    handler.next(err);
  }
}

/// 🔄 Intercepteur de retry
class _RetryInterceptor extends Interceptor {
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

      if (retryCount < maxRetries) {
        err.requestOptions.extra['retryCount'] = retryCount + 1;

        await Future.delayed(retryDelay * (retryCount + 1));

        try {
          final response = await Dio().fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // Continue avec l'erreur originale
        }
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}

/// 📦 Réponse API générique
class ApiResponse<T> {
  final T? data;
  final ApiError? error;
  final bool isSuccess;

  ApiResponse.success(this.data)
      : error = null,
        isSuccess = true;

  ApiResponse.error(this.error)
      : data = null,
        isSuccess = false;

  /// Mapper les données avec une fonction
  ApiResponse<R> map<R>(R Function(T data) mapper) {
    if (isSuccess && data != null) {
      try {
        return ApiResponse.success(mapper(data!));
      } catch (e) {
        return ApiResponse.error(ApiError.unknown('Erreur de mapping: $e'));
      }
    }
    return ApiResponse.error(error!);
  }

  /// Exécuter une action si succès
  void onSuccess(void Function(T data) action) {
    if (isSuccess && data != null) {
      action(data!);
    }
  }

  /// Exécuter une action si erreur
  void onError(void Function(ApiError error) action) {
    if (!isSuccess && error != null) {
      action(error!);
    }
  }
}

/// ❌ Erreur API
class ApiError {
  final String message;
  final int? statusCode;
  final String type;

  ApiError._(this.message, this.statusCode, this.type);

  factory ApiError.network() =>
      ApiError._('Erreur de connexion réseau', null, 'network');
  factory ApiError.timeout() =>
      ApiError._('Délai d\'attente dépassé', null, 'timeout');
  factory ApiError.badRequest(String message) =>
      ApiError._(message, 400, 'bad_request');
  factory ApiError.unauthorized(String message) =>
      ApiError._(message, 401, 'unauthorized');
  factory ApiError.forbidden(String message) =>
      ApiError._(message, 403, 'forbidden');
  factory ApiError.notFound(String message) =>
      ApiError._(message, 404, 'not_found');
  factory ApiError.conflict(String message) =>
      ApiError._(message, 409, 'conflict');
  factory ApiError.validation(String message) =>
      ApiError._(message, 422, 'validation');
  factory ApiError.server(String message) => ApiError._(message, 500, 'server');
  factory ApiError.http(int statusCode, String message) =>
      ApiError._(message, statusCode, 'http');
  factory ApiError.cancelled() =>
      ApiError._('Requête annulée', null, 'cancelled');
  factory ApiError.unknown(String message) =>
      ApiError._(message, null, 'unknown');

  bool get isNetworkError => type == 'network' || type == 'timeout';
  bool get isAuthError => type == 'unauthorized' || type == 'forbidden';
  bool get isValidationError => type == 'validation' || type == 'bad_request';
  bool get isServerError => statusCode != null && statusCode! >= 500;

  @override
  String toString() => 'ApiError($type): $message';
}
