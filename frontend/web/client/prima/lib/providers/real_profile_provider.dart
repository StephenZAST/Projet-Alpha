import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:prima/providers/profile_data_provider.dart';

class RealProfileProvider implements ProfileDataProvider {
  final String baseUrl = 'http://localhost:3001/api';
  final http.Client client;

  RealProfileProvider({
    http.Client? httpClient,
  }) : client = httpClient ?? http.Client();

  @override
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/profile'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          return data['data'];
        }
        throw Exception('Invalid response format');
      }

      throw HttpException(response.statusCode, 'Failed to load profile');
    } on HttpException {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> profile) async {
    try {
      final response = await client.put(
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

class HttpException implements Exception {
  final int statusCode;
  final String message;
  HttpException(this.statusCode, this.message);

  @override
  String toString() => 'HttpException: $message (Status: $statusCode)';
}