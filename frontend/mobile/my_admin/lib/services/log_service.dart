import 'package:flutter/material.dart';

import 'api_service.dart';
import '../models/admin_log.dart';

class LogService {
  static Future<List<AdminLog>> getLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? action,
  }) async {
    final queryParams = {
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
      if (action != null) 'action': action,
    };

    final response =
        await ApiService.get('admin/logs?${Uri(queryParameters: queryParams)}');
    return (response['data'] as List)
        .map((json) => AdminLog.fromJson(json))
        .toList();
  }

  static Future<void> exportLogs(DateTimeRange dateRange) async {
    await ApiService.get(
      'admin/logs/export?startDate=${dateRange.start.toIso8601String()}&endDate=${dateRange.end.toIso8601String()}',
    );
  }
}
