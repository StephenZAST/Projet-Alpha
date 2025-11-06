import 'package:dio/dio.dart' as dio;
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import '../routes/admin_routes.dart';

class ApiService extends GetxService {
  static final ApiService _instance = ApiService._internal();
  late final dio.Dio _dio;
  final _storage = GetStorage();

  static const String _tokenKey = 'token';

  factory ApiService() {
    return _instance;
  }

  static String get baseUrl => 'https://alpha-laundry-backend.onrender.com';

  ApiService._internal() {
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
      validateStatus: (status) => true,
    ));

    // Ajouter l'intercepteur de logging
    _dio.interceptors.add(dio.LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));

    _setupInterceptors();
  }

  static String? getToken() {
    return GetStorage().read(_tokenKey);
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) {
          print('[ApiService] Making request to: ${options.path}');
          // Utiliser la nouvelle méthode getToken
          final token = getToken();
          print('[ApiService] Token available: ${token != null}');
          if (token != null) {
            print(
                '[ApiService] Adding Authorization header with token: ${token.substring(0, 20)}...');
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            print(
                '[ApiService] ⚠️ NO TOKEN FOUND - Request will fail for protected routes');
          }
          print('[ApiService] Request headers: ${options.headers}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('[ApiService] Response from: ${response.requestOptions.path}');
          print('[ApiService] Status code: ${response.statusCode}');

          if (response.statusCode == 401) {
            print('[ApiService] Unauthorized access, clearing session');
            _handleUnauthorized();
            return handler.reject(
              dio.DioException(
                requestOptions: response.requestOptions,
                error: 'Session expirée. Veuillez vous reconnecter.',
                type: dio.DioExceptionType.badResponse,
                response: response,
              ),
            );
          }

          if (response.statusCode == 500) {
            print(
                '[ApiService] Server error on ${response.requestOptions.path}: ${response.data}');
            // Retourner une réponse vide mais valide plutôt qu'une erreur
            response.data = {'data': null, 'success': false};
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
      // Ajouter /api au début du path s'il n'est pas présent
      final endpoint = path.startsWith('/api/') ? path : '/api$path';
      print('[ApiService] Making GET request to: $baseUrl$endpoint');

      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      print('[ApiService] Response status: ${response.statusCode}');
      print('[ApiService] Response data: ${response.data}');

      return response;
    } catch (e) {
      print('[ApiService] Error making GET request: $e');
      rethrow;
    }
  }

  Future<dio.Response> post(String path, {dynamic data}) async {
    try {
      // Ajouter /api au début du path s'il n'est pas présent
      final endpoint = path.startsWith('/api/') ? path : '/api$path';
      final response = await _dio.post(
        endpoint,
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
      // Ajouter /api au début du path s'il n'est pas présent
      final endpoint = path.startsWith('/api/') ? path : '/api$path';
      final response = await _dio.put(
        endpoint,
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
      // Ajouter /api au début du path s'il n'est pas présent
      final endpoint = path.startsWith('/api/') ? path : '/api$path';
      print('[ApiService] Making PATCH request to: $baseUrl$endpoint');
      print('[ApiService] Request data: $data');

      final response = await _dio.patch(
        endpoint,
        data: data,
      );

      print('[ApiService] PATCH Response status code: ${response.statusCode}');
      print('[ApiService] PATCH Response data: ${response.data}');

      // Ne pas lancer d'exception ici, laisser la méthode appelante gérer
      return response;
    } catch (e) {
      print('[ApiService] PATCH request error: $e');
      rethrow;
    }
  }

  Future<dio.Response> delete(String path) async {
    try {
      // Ajouter /api au début du path s'il n'est pas présent
      final endpoint = path.startsWith('/api/') ? path : '/api$path';
      final response = await _dio.delete(endpoint);
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
    if (error is dio.DioException) {
      print('[ApiService] DioError: ${error.type} - ${error.message}');
      switch (error.type) {
        case dio.DioExceptionType.connectionTimeout:
        case dio.DioExceptionType.sendTimeout:
        case dio.DioExceptionType.receiveTimeout:
          return 'La connexion au serveur a échoué. Veuillez vérifier votre connexion internet.';
        case dio.DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data['message'] ?? 'Erreur serveur';

          if (statusCode == 401) {
            return 'Session expirée. Veuillez vous reconnecter.';
          } else if (statusCode == 403) {
            return 'Accès refusé. Vous n\'avez pas les permissions nécessaires.';
          }
          return message;
        case dio.DioExceptionType.cancel:
          return 'La requête a été annulée';
        default:
          return 'Une erreur est survenue lors de la communication avec le serveur';
      }
    }
    return error.toString();
  }

  // Ajoutez cette méthode pour l'initialisation des services GetX
  Future<ApiService> init() async {
    return this;
  }
}
