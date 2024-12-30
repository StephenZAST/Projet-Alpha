import 'package:flutter/material.dart';
import 'mock_profile_provider.dart';
import 'real_profile_provider.dart';
import 'package:prima/providers/profile_data_provider.dart';

class ProfileProvider extends ChangeNotifier {
  final bool useMockData;
  late final ProfileDataProvider _dataProvider;

  ProfileProvider({required this.useMockData}) {
    _dataProvider = useMockData ? MockProfileProvider() : RealProfileProvider();
  }

  Future<Map<String, dynamic>> getProfile() async {
    return await _dataProvider.getProfile();
  }

  Future<void> updateProfile(Map<String, dynamic> profile) async {
    await _dataProvider.updateProfile(profile);
    notifyListeners();
  }
}