import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/admin_log.dart';
import '../services/log_service.dart';

class LogController extends GetxController {
  final logs = <AdminLog>[].obs;
  final isLoading = false.obs;
  final dateRange = Rx<DateTimeRange?>(null);
  final selectedAction = ''.obs;
  final selectedUserId = ''.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLogs();
  }

  Future<void> fetchLogs({bool append = false}) async {
    isLoading.value = true;
    try {
      final page = append ? currentPage.value + 1 : 1;
      final result = await LogService.getLogs(
        startDate: dateRange.value?.start,
        endDate: dateRange.value?.end.add(const Duration(days: 1)),
        action: selectedAction.value,
        userId: selectedUserId.value,
        page: page,
      );
      currentPage.value = result.page;
      totalPages.value = result.totalPages;
      logs.value = append ? [...logs, ...result.logs] : result.logs;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!isLoading.value && currentPage.value < totalPages.value) {
      await fetchLogs(append: true);
    }
  }

  Future<void> exportLogs() async {
    // TODO: Implement export logic
  }
}
