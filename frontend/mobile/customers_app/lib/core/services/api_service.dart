import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/storage_service.dart';
import '../../constants.dart';

/// Lightweight ApiService for the customers_app
/// Provides basic get/post/patch/delete helpers that return parsed JSON as Map
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<Map<String, dynamic>> _safeRequest(
      Future<http.Response> future) async {
    try {
      final response = await future.timeout(ApiConfig.timeout);

      // Debug: log status and raw body for easier troubleshooting
      try {
        print('[ApiService] response status: ${response.statusCode}');
        print('[ApiService] response body: ${response.body}');
      } catch (_) {}

      final content =
          response.body.isNotEmpty ? jsonDecode(response.body) : null;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (content is Map<String, dynamic>) return content;
        return {'success': true, 'data': content};
      }

      // Attempt to extract error message
      if (content is Map<String, dynamic>) {
        return {
          'success': false,
          'error': content['error'] ?? content['message'] ?? content
        };
      }

      return {'success': false, 'error': 'HTTP ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    try {
      final token = await StorageService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}
    return headers;
  }

  Future<Map<String, dynamic>> get(String endpoint,
      {Map<String, dynamic>? queryParameters}) async {
    final url = ApiConfig.url(endpoint);
    final uri = Uri.parse(url).replace(
      queryParameters:
          queryParameters?.map((k, v) => MapEntry(k, v?.toString())),
    );
    final headers = await _buildHeaders();
    // Debug: outgoing request
    try {
      print('[ApiService] GET $uri');
      print('[ApiService] headers: $headers');
    } catch (_) {}

    return _safeRequest(http.get(uri, headers: headers));
  }

  Future<Map<String, dynamic>> post(String endpoint, {dynamic data}) async {
    final url = ApiConfig.url(endpoint);
    final uri = Uri.parse(url);
    final headers = await _buildHeaders();
    final body = data != null ? jsonEncode(data) : null;
    // Debug: outgoing request
    try {
      print('[ApiService] POST $uri');
      print('[ApiService] headers: $headers');
      print('[ApiService] body: $body');
    } catch (_) {}

    return _safeRequest(http.post(uri, headers: headers, body: body));
  }

  Future<Map<String, dynamic>> patch(String endpoint, {dynamic data}) async {
    final url = ApiConfig.url(endpoint);
    final uri = Uri.parse(url);
    final headers = await _buildHeaders();
    final body = data != null ? jsonEncode(data) : null;
    // Debug: outgoing request
    try {
      print('[ApiService] PATCH $uri');
      print('[ApiService] headers: $headers');
      print('[ApiService] body: $body');
    } catch (_) {}

    return _safeRequest(http.patch(uri, headers: headers, body: body));
  }

  Future<Map<String, dynamic>> delete(String endpoint, {dynamic data}) async {
    final url = ApiConfig.url(endpoint);
    final uri = Uri.parse(url);
    final headers = await _buildHeaders();
    final body = data != null ? jsonEncode(data) : null;
    // http.delete doesn't accept a body in some platforms, so use Request when needed
    try {
      final request = http.Request('DELETE', uri)
        ..headers.addAll(headers)
        ..body = body ?? '';
      final streamed = await request.send().timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamed);
      final content =
          response.body.isNotEmpty ? jsonDecode(response.body) : null;
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (content is Map<String, dynamic>) return content;
        return {'success': true, 'data': content};
      }
      if (content is Map<String, dynamic>) {
        return {
          'success': false,
          'error': content['error'] ?? content['message'] ?? content
        };
      }
      return {'success': false, 'error': 'HTTP ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
