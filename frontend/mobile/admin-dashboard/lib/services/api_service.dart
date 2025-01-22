import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants.dart';
import '../routes/admin_routes.dart';

class ApiService {
  static final dio.Dio _dio = dio.Dio(dio.BaseOptions(
    baseUrl: 'http://localhost:3001/api/',
    contentType: 'application/json',
    validateStatus: (status) =>
        true, // Pour gérer nous-mêmes les codes de statut
  ));

  static const String _tokenKey = 'auth_token';
  static final _storage = GetStorage();

  static String? get token => _storage.read(_tokenKey);
  static set token(String? value) => value != null
      ? _storage.write(_tokenKey, value)
      : _storage.remove(_tokenKey);

  static Future<bool> _refreshToken() async {
    try {
      if (token == null) return false;

      print('[API] Attempting to refresh token');
      final response = await _dio.post(
        'auth/admin/refresh',
        data: {'token': token},
        options: dio.Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data?['token'] != null) {
        token = response.data['token'];
        print('[API] Token refresh successful');
        return true;
      }
      print('[API] Token refresh failed');
      return false;
    } catch (e) {
      print('[API] Refresh token failed: $e');
      return false;
    }
  }

  static void _configureInterceptors() {
    _dio.interceptors.clear();
    _dio.interceptors.add(dio.InterceptorsWrapper(
      onRequest: (options, handler) async {
        print('[API] Request URL: ${options.uri}');

        final currentToken = token;
        if (currentToken != null) {
          options.headers['Authorization'] = 'Bearer $currentToken';
        }

        print('[API] Headers: ${options.headers}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('[API] Response status: ${response.statusCode}');
        print('[API] Response data: ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) async {
        print('[API] Error: ${error.message}');
        print('[API] Error Response: ${error.response?.data}');

        if (error.response?.statusCode == 401) {
          // Tenter de rafraîchir le token
          final isRefreshed = await _refreshToken();
          if (isRefreshed) {
            // Réessayer la requête originale avec le nouveau token
            final opts = dio.Options(
              method: error.requestOptions.method,
              headers: {'Authorization': 'Bearer ${token}'},
            );

            try {
              print('[API] Retrying request with new token');
              final retryResponse = await _dio.request(
                error.requestOptions.path,
                options: opts,
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
              );
              return handler.resolve(retryResponse);
            } catch (retryError) {
              _handleSessionExpired();
              return handler.next(error);
            }
          } else {
            _handleSessionExpired();
            return handler.next(error);
          }
        }

        // Gérer les autres erreurs
        _showErrorSnackbar(error);
        return handler.next(error);
      },
    ));
  }

  static void _handleSessionExpired() {
    token = null;
    Get.offAllNamed(AdminRoutes.login);
    Get.snackbar(
      'Session expirée',
      'Veuillez vous reconnecter',
      backgroundColor: AppColors.error,
      colorText: AppColors.textLight,
      snackPosition: SnackPosition.TOP,
      padding: AppSpacing.paddingMD,
      margin: AppSpacing.marginMD,
      borderRadius: AppRadius.sm,
      duration: Duration(seconds: 4),
    );
  }

  static void _showErrorSnackbar(dio.DioException error) {
    String message;
    if (error.response?.data?['message'] != null) {
      message = error.response?.data['message'];
    } else if (error.response?.data is String) {
      message = error.response?.data;
    } else {
      switch (error.type) {
        case dio.DioExceptionType.connectionTimeout:
        case dio.DioExceptionType.sendTimeout:
        case dio.DioExceptionType.receiveTimeout:
          message = 'Délai d\'attente dépassé';
          break;
        case dio.DioExceptionType.badResponse:
          message = 'Erreur serveur (${error.response?.statusCode})';
          break;
        case dio.DioExceptionType.cancel:
          message = 'Requête annulée';
          break;
        default:
          message = 'Une erreur est survenue';
      }
    }

    Get.snackbar(
      'Erreur',
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

  static Future<Map<String, dynamic>> get(String path) async {
    _configureInterceptors();
    try {
      print('[API] GET request to: $path');
      final response = await _dio.get(path);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> post(String path, dynamic data) async {
    _configureInterceptors();
    try {
      print('[API] POST request to: $path');
      print('[API] Request data: $data');
      final response = await _dio.post(path, data: data);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> put(String path, dynamic data) async {
    _configureInterceptors();
    try {
      print('[API] PUT request to: $path');
      print('[API] Request data: $data');
      final response = await _dio.put(path, data: data);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> patch(String path, dynamic data) async {
    _configureInterceptors();
    try {
      print('[API] PATCH request to: $path');
      print('[API] Request data: $data');
      final response = await _dio.patch(path, data: data);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> delete(String path) async {
    _configureInterceptors();
    try {
      print('[API] DELETE request to: $path');
      final response = await _dio.delete(path);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Map<String, dynamic> _handleResponse(dio.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        'success': true,
        'data': response.data,
      };
    }
    return {
      'success': false,
      'message': response.data?['message'] ?? 'Une erreur est survenue',
    };
  }

  static Map<String, dynamic> _handleError(dynamic error) {
    if (error is dio.DioException) {
      return {
        'success': false,
        'message': error.response?.data?['message'] ?? 'Erreur réseau',
      };
    }
    return {
      'success': false,
      'message': error.toString(),
    };
  }
}
