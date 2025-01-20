import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/log_controller.dart';
import '../../controllers/export_controller.dart';
import 'components/log_list.dart';
import 'components/log_filters.dart';
import '../components/export_button.dart';

class LogsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logController = Get.put(LogController());
    final exportController = Get.put(ExportController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Logs'),
        actions: [
          ExportButton(
            data: logController.logs,
            type: 'logs',
          ),
        ],
      ),
      body: Column(
        children: [
          LogFilters(),
          Expanded(
            child: Obx(
              () => logController.isLoading.value
                  ? Center(child: CircularProgressIndicator())
                  : LogList(logs: logController.logs),
            ),
          ),
        ],
      ),
    );
  }
}
