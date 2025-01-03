import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:prima/providers/auth_data_provider.dart';

class RealAuthProvider implements AuthDataProvider {
  final String baseUrl = 'http://localhost:3001/api';
  final http.Client client;

  RealAuthProvider({
    http.Client? httpClient,
  }) : client = httpClient ?? http.Client();

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          return data['data'];
        }
        throw Exception('Invalid response format: ${response.body}');
      }

      throw HttpException(response.statusCode, 'Failed to login');
    } on HttpException {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'firstName': name,
          'email': email,
          'password': password,
          'lastName': ''
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          return data['data'];
        }
        throw Exception('Invalid response format');
      }

      throw HttpException(response.statusCode, 'Failed to register');
    } on HttpException {
      rethrow;
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
