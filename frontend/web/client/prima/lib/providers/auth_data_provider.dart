import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthDataProvider {
  Future<String?> getStoredToken();
  Future<void> saveToken(String token);
  Future<void> clearStoredData();
  Future<Map<String, dynamic>?> getStoredUserData();
  Future<void> saveUserData(Map<String, dynamic> userData);
}

// Implémentation concrète
class AuthDataProviderImpl implements AuthDataProvider {
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  final SharedPreferences _prefs;

  AuthDataProviderImpl(this._prefs);

  @override
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  @override
  Future<String?> getStoredToken() async {
    return _prefs.getString(_tokenKey);
  }

  @override
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs.setString(_userDataKey, json.encode(userData));
  }

  @override
  Future<Map<String, dynamic>?> getStoredUserData() async {
    final String? userDataString = _prefs.getString(_userDataKey);
    if (userDataString != null) {
      return json.decode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  @override
  Future<void> clearStoredData() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userDataKey);
  }
}
