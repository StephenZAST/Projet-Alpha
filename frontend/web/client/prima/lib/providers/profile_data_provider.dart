import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ProfileDataProvider {
  Future<Map<String, dynamic>> getProfile();
  Future<void> updateProfile(Map<String, dynamic> profile);
  Future<List<Map<String, dynamic>>> getUserAddresses();
  Future<void> saveUserAddresses(List<Map<String, dynamic>> addresses);
  Future<void> clearUserData();
}

class ProfileDataProviderImpl implements ProfileDataProvider {
  final SharedPreferences _prefs;
  static const String _addressesKey = 'user_addresses';
  static const String _profileKey = 'user_profile';

  ProfileDataProviderImpl(this._prefs);

  @override
  Future<List<Map<String, dynamic>>> getUserAddresses() async {
    final String? addressesJson = _prefs.getString(_addressesKey);
    if (addressesJson != null) {
      final List<dynamic> addresses = json.decode(addressesJson);
      return addresses.cast<Map<String, dynamic>>();
    }
    return [];
  }

  @override
  Future<void> saveUserAddresses(List<Map<String, dynamic>> addresses) async {
    await _prefs.setString(_addressesKey, json.encode(addresses));
  }

  @override
  Future<void> clearUserData() async {
    await _prefs.remove(_addressesKey);
  }

  @override
  Future<Map<String, dynamic>> getProfile() async {
    final String? profileJson = _prefs.getString(_profileKey);
    if (profileJson != null) {
      return json.decode(profileJson);
    }
    return {};
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> profile) async {
    await _prefs.setString(_profileKey, json.encode(profile));
  }
}

class MockProfileProvider extends ProfileDataProviderImpl {
  MockProfileProvider(SharedPreferences prefs) : super(prefs);
}

class RealProfileProvider extends ProfileDataProviderImpl {
  RealProfileProvider(SharedPreferences prefs) : super(prefs);
}
