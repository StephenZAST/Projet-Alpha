import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late final Dio _dio;
  final _storage = GetStorage();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:3001/api',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      contentType: 'application/json',
      validateStatus: (status) {
        return status! < 500;
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Ajouter le token d'authentification s'il existe
          final token = _storage.read('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) {
          print('[ApiService] Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(String path,
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

  Future<Response> post(String path, {dynamic data}) async {
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

  Future<Response> put(String path, {dynamic data}) async {
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

  Future<Response> patch(String path, {dynamic data}) async {
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

  Future<Response> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      _handleResponse(response);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  void _handleResponse(Response response) {
    if (response.statusCode == 401) {
      // Token expiré ou invalide
      _storage.remove('token');
      throw 'Session expirée. Veuillez vous reconnecter.';
    }
  }

  String _handleError(dynamic error) {
    if (error is DioError) {
      switch (error.type) {
        case DioErrorType.connectionTimeout:
        case DioErrorType.sendTimeout:
        case DioErrorType.receiveTimeout:
          return 'Délai d\'attente dépassé';
        case DioErrorType.badResponse:
          return error.response?.data['message'] ?? 'Erreur serveur';
        default:
          return 'Une erreur est survenue';
      }
    }
    return error.toString();
  }
}
