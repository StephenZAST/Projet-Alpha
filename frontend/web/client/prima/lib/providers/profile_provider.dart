import 'package:flutter/material.dart';
import 'mock_profile_provider.dart';
import 'real_profile_provider.dart';
import 'package:prima/providers/profile_data_provider.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileDataProvider _dataProvider;
  Map<String, dynamic>? _cachedProfile;
  bool _isLoading = false;
  String? _error;

  ProfileProvider({required bool useMockData})
      : _dataProvider = useMockData
            ? MockProfileProvider()
            : RealProfileProvider();

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get profile => _cachedProfile;
  String? get error => _error;

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