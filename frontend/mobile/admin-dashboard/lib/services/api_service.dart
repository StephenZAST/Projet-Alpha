import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3001/api',
    contentType: 'application/json',
  ));

  static void _configureInterceptors() {
    _dio.interceptors.clear();
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = GetStorage().read('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioError e, handler) {
        if (e.response?.statusCode == 401) {
          // Gérer l'expiration du token
          GetStorage().remove('token');
          Get.offAllNamed('/login');
        }
        return handler.next(e);
      },
    ));
  }

  static Future<dynamic> get(String path) async {
    _configureInterceptors();
    try {
      final response = await _dio.get(path);
      return response.data;
    } catch (e) {
      _handleError(e);
    }
  }

  static Future<dynamic> post(String path, dynamic data) async {
    _configureInterceptors();
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } catch (e) {
      _handleError(e);
    }
  }

  static Future<dynamic> put(String path, dynamic data) async {
    _configureInterceptors();
    try {
      final response = await _dio.put(path, data: data);
      return response.data;
    } catch (e) {
      _handleError(e);
    }
  }

  static Future<dynamic> patch(String path, dynamic data) async {
    _configureInterceptors();
    try {
      final response = await _dio.patch(path, data: data);
      return response.data;
    } catch (e) {
      _handleError(e);
    }
  }

  static Future<dynamic> delete(String path) async {
    _configureInterceptors();
    try {
      final response = await _dio.delete(path);
      return response.data;
    } catch (e) {
      _handleError(e);
    }
  }

  static void _handleError(dynamic error) {
    if (error is DioError) {
      throw error.response?.data?['error'] ?? 'Network error occurred';
    }
    throw error.toString();
  }
}
