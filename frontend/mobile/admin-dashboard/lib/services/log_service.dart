import 'package:flutter/material.dart';
import 'api_service.dart';
import '../models/admin_log.dart';

class AdminLogPage {
  final List<AdminLog> logs;
  final int page;
  final int totalPages;

  AdminLogPage({
    required this.logs,
    required this.page,
    required this.totalPages,
  });
}

class LogService {
  static final _api = ApiService();

  static Future<AdminLogPage> getLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? action,
    String? userId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = {
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        if (action != null && action.isNotEmpty) 'action': action,
        if (userId != null && userId.isNotEmpty) 'userId': userId,
        'page': page,
        'limit': limit,
      };

      final response =
          await _api.get('/admin/logs', queryParameters: queryParams);

      if (response.data != null && response.data['data'] != null) {
        final data = response.data['data'];
        final logs = data is List ? data : data['logs'];

        return AdminLogPage(
          logs: (logs as List).map((json) => AdminLog.fromJson(json)).toList(),
          page: response.data['pagination']?['page'] ?? page,
          totalPages: response.data['pagination']?['totalPages'] ?? page,
        );
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
