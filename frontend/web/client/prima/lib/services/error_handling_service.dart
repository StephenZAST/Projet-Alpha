import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ErrorHandlingService {
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connexion impossible, veuillez vérifier votre connexion internet';
        case DioExceptionType.receiveTimeout:
          return 'Le serveur met trop de temps à répondre';
        case DioExceptionType.badResponse:
          return error.response?.data?['message'] ?? 'Une erreur est survenue';
        default:
          return 'Une erreur inattendue est survenue';
      }
    }
    return error.toString();
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
