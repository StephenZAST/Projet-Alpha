import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/log_controller.dart';
import '../../controllers/export_controller.dart';
import 'components/log_list.dart';
import 'components/log_filters.dart';
import '../components/export_button.dart';
import '../../constants.dart';

class LogsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logController = Get.put(LogController());
    Get.put(ExportController());

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Journal d’activité',
                          style: AppTextStyles.h2.copyWith(
                            color: isDark
                                ? AppColors.textLight
                                : AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          'Suivez les actions réalisées dans le tableau de bord.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.gray400
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ExportButton(
                    data: logController.logs
                        .map((log) => {
                              'id': log.id,
                              'adminName': log.adminName,
                              'action': log.action,
                              'entityType': log.entityType,
                              'entityId': log.entityId,
                              'timestamp': log.createdAt.toIso8601String(),
                            })
                        .toList(),
                    type: 'logs',
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              LogFilters(),
              SizedBox(height: AppSpacing.lg),
              Expanded(
                child: Obx(
                  () => logController.isLoading.value
                      ? Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            Expanded(child: LogList(logs: logController.logs)),
                            if (logController.currentPage.value <
                                logController.totalPages.value)
                              TextButton.icon(
                                onPressed: logController.loadMore,
                                icon: Icon(Icons.expand_more),
                                label: Text('Charger plus'),
                              ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
