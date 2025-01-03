import 'package:flutter/material.dart';
import 'package:prima/providers/auth_data_provider.dart';

class MockAuthProvider implements AuthDataProvider {
  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (email == 'test@example.com' && password == 'password') {
      return {
        'token': 'fake_token',
        'user': {
          'id': '123',
          'name': 'Test User',
          'email': 'test@example.com',
          'phone': '123-456-7890',
          'address': '123 Main St, Anytown, USA',
        }
      };
    } else {
      throw Exception('Invalid credentials');
    }
  }

  @override
  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    return {
      'token': 'fake_token',
      'user': {
        'id': '123',
        'name': name,
        'email': email,
        'phone': '123-456-7890',
        'address': '123 Main St, Anytown, USA',
      }
    };
  }
}
