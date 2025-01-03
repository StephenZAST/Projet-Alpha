import 'package:flutter/material.dart';
import 'package:prima/providers/mock_auth_provider.dart';
import 'package:prima/providers/real_auth_provider.dart';
import 'package:prima/providers/auth_data_provider.dart';

class AuthProvider extends ChangeNotifier {
  final AuthDataProvider _authDataProvider;
  Map<String, dynamic>? _cachedUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider({required bool useMockData})
      : _authDataProvider =
            useMockData ? MockAuthProvider() : RealAuthProvider();

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _cachedUser;
  String? get error => _error;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _authDataProvider.login(email, password);
      _cachedUser = response['user'];
      return response;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _authDataProvider.register(name, email, password);
      _cachedUser = response['user'];
      return response;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
