import 'package:get/get.dart';
import '../models/admin_log.dart';
import '../services/log_service.dart';

class LogController extends GetxController {
  final logs = <AdminLog>[].obs;
  final isLoading = false.obs;
  final dateRange = Rx<DateTimeRange?>(null);
  final selectedAction = ''.obs;

  Future<void> fetchLogs() async {
    isLoading.value = true;
    try {
      logs.value = await LogService.getLogs(
        startDate: dateRange.value?.start,
        endDate: dateRange.value?.end,
        action: selectedAction.value,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportLogs() async {
    // TODO: Implement export logic
  }
}
