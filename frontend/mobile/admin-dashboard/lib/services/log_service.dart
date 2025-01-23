import 'package:flutter/material.dart';
import 'api_service.dart';
import '../models/admin_log.dart';

class LogService {
  static final _api = ApiService();

  static Future<List<AdminLog>> getLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? action,
  }) async {
    try {
      final queryParams = {
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        if (action != null) 'action': action,
      };

      final response =
          await _api.get('/admin/logs', queryParameters: queryParams);

      if (response.data != null && response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((json) => AdminLog.fromJson(json))
            .toList();
      }

      throw 'Erreur lors de la récupération des logs';
    } catch (e) {
      print('[LogService] Error getting logs: $e');
      throw 'Erreur lors de la récupération des logs';
    }
  }

  static Future<void> exportLogs(DateTimeRange dateRange) async {
    try {
      final queryParams = {
        'startDate': dateRange.start.toIso8601String(),
        'endDate': dateRange.end.toIso8601String(),
      };

      await _api.get(
        '/admin/logs/export',
        queryParameters: queryParams,
      );
    } catch (e) {
      print('[LogService] Error exporting logs: $e');
      throw 'Erreur lors de l\'export des logs';
    }
  }
}
