import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  final String baseUrl = 'http://localhost:3001/api';
  bool _isAuthenticated = false;
  String? _token;
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

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
    } catch (e) {
      _error = 'Erreur de connexion: $e';
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

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
        }),
      );

      final data = json.decode(response.body);

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
    } catch (e) {
      _error = 'Erreur d\'inscription: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _token = null;
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
