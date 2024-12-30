import 'package:flutter/material.dart';
import 'package:prima/providers/profile_data_provider.dart';

class MockProfileProvider implements ProfileDataProvider {
  Future<Map<String, dynamic>> getProfile() async {
    return {
      'id': '123',
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'phone': '123-456-7890',
      'address': '123 Main St, Anytown, USA',
    };
  }

  Future<void> updateProfile(Map<String, dynamic> profile) async {
    // Simulate an update
    print('Profile updated: $profile');
  }
}