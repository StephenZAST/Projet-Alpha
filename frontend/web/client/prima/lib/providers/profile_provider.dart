import 'package:flutter/material.dart';
import 'package:prima/providers/profile_data_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:prima/providers/auth_provider.dart';

class ProfileProvider extends ChangeNotifier {
  final AuthProvider _authProvider;
  final SharedPreferences _prefs;
  final ProfileDataProvider _dataProvider;
  Map<String, dynamic>? _cachedProfile;
  bool _isLoading = false;
  String? _error;

  ProfileProvider(this._authProvider, this._prefs, {required bool useMockData})
      : _dataProvider = useMockData
            ? MockProfileProvider(_prefs)
            : RealProfileProvider(_prefs) {
    _loadProfile();
  }

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get profile => _cachedProfile;
  String? get error => _error;

  Future<void> _loadProfile() async {
    if (_authProvider.isAuthenticated) {
      try {
        final response = await Dio().get('/profile');
        final profileData = response.data['data'];
        await _prefs.setString('profile_data', json.encode(profileData));
        // Update state and notify
        notifyListeners();
      } catch (e) {
        // Handle error
      }
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _cachedProfile = await _dataProvider.getProfile();
      return _cachedProfile!;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> profile) async {
    try {
      await _dataProvider.updateProfile(profile);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }
}
