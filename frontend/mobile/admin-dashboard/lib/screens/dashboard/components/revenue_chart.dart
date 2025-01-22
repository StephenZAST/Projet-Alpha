import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../constants.dart';
import '../../../controllers/dashboard_controller.dart';

class RevenueChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenus',
            style: AppTextStyles.h3.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }

            if (controller.revenueChartData.isEmpty) {
              return Center(
                child: Text(
                  'Aucune donnée disponible',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }

            final labels =
                controller.revenueChartData['labels'] as List<String>? ?? [];
            final data = controller.revenueChartData['data'] as List? ?? [];

            if (labels.isEmpty || data.isEmpty) {
              return Center(
                child: Text(
                  'Aucune donnée disponible',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }

            return SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  majorGridLines: MajorGridLines(width: 0),
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                primaryYAxis: NumericAxis(
                  numberFormat: NumberFormat.compact(),
                  majorGridLines: MajorGridLines(
                    width: 1,
                    color: AppColors.borderLight.withOpacity(0.5),
                  ),
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <ChartSeries>[
                  AreaSeries<_RevenueData, String>(
                    dataSource: List.generate(
                      labels.length,
                      (index) => _RevenueData(
                        labels[index],
                        (data[index] as num).toDouble(),
                      ),
                    ),
                    xValueMapper: (_RevenueData revenue, _) => revenue.date,
                    yValueMapper: (_RevenueData revenue, _) => revenue.amount,
                    name: 'Revenus',
                    color: AppColors.primary.withOpacity(0.5),
                    borderColor: AppColors.primary,
                    borderWidth: 2,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _RevenueData {
  final String date;
  final double amount;

  _RevenueData(this.date, this.amount);
}
