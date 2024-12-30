import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:prima/providers/profile_data_provider.dart';

class RealProfileProvider implements ProfileDataProvider {
  final String baseUrl = 'https://api.example.com';

  @override
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/profile'));
      if (response.statusCode == 200) {
        return json.decode(response.body)['data'];
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> profile) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(profile),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}