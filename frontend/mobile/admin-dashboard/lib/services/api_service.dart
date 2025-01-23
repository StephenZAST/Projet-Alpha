import 'package:dio/dio.dart' as dio;
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import '../routes/admin_routes.dart';
import '../constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late final dio.Dio _dio;
  final _storage = GetStorage();

  static const String _tokenKey = 'token';

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: 'http://localhost:3001/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
      validateStatus: (status) {
        return status! < 500;
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) {
          print('[ApiService] Making request to: ${options.path}');
          // Ajouter le token d'authentification s'il existe
          final token = _storage.read(_tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('[ApiService] Response from: ${response.requestOptions.path}');
          print('[ApiService] Status code: ${response.statusCode}');

          if (response.statusCode == 401) {
            print('[ApiService] Unauthorized access, clearing session');
            _handleUnauthorized();
            return handler.reject(
              dio.DioError(
                requestOptions: response.requestOptions,
                error: 'Session expirée. Veuillez vous reconnecter.',
                type: dio.DioErrorType.badResponse,
                response: response,
              ),
            );
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          print(
              '[ApiService] Error on ${error.requestOptions.path}: ${error.message}');

          if (error.response?.statusCode == 401) {
            print('[ApiService] Unauthorized error, clearing session');
            _handleUnauthorized();
          }

          return handler.next(error);
        },
      ),
    );
  }

  void _handleUnauthorized() {
    _storage.remove(_tokenKey);
    _storage.remove('user');
    // Rediriger vers la page de connexion
    if (Get.currentRoute != AdminRoutes.login) {
      Get.offAllNamed(AdminRoutes.login);
    }
  }

  Future<dio.Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      _handleResponse(response);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dio.Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
      );
      _handleResponse(response);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dio.Response> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
      );
      _handleResponse(response);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dio.Response> patch(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
      );
      _handleResponse(response);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dio.Response> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      _handleResponse(response);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  void _handleResponse(dio.Response response) {
    if (response.statusCode == 401) {
      _handleUnauthorized();
      throw 'Session expirée. Veuillez vous reconnecter.';
    }
  }

  String _handleError(dynamic error) {
    if (error is dio.DioError) {
      print('[ApiService] DioError: ${error.type} - ${error.message}');
      switch (error.type) {
        case dio.DioErrorType.connectionTimeout:
        case dio.DioErrorType.sendTimeout:
        case dio.DioErrorType.receiveTimeout:
          return 'La connexion au serveur a échoué. Veuillez vérifier votre connexion internet.';
        case dio.DioErrorType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data['message'] ?? 'Erreur serveur';

          if (statusCode == 401) {
            return 'Session expirée. Veuillez vous reconnecter.';
          } else if (statusCode == 403) {
            return 'Accès refusé. Vous n\'avez pas les permissions nécessaires.';
          }
          return message;
        case dio.DioErrorType.cancel:
          return 'La requête a été annulée';
        default:
          return 'Une erreur est survenue lors de la communication avec le serveur';
      }
    }
    return error.toString();
  }
}
