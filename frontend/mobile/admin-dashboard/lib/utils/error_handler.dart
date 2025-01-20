import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ErrorHandler {
  static void handleError(dynamic error) {
    Get.snackbar(
      'Error',
      _getErrorMessage(error),
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }

  static String _getErrorMessage(dynamic error) {
    // TODO: Implement error message extraction logic
    return error.toString();
  }
}
