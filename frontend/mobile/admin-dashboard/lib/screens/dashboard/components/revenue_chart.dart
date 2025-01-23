import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../constants.dart';
import '../../../controllers/dashboard_controller.dart';

class RevenueChart extends StatelessWidget {
  final currencyFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'FCFA',
    decimalDigits: 0,
  );

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Revenus',
                style: AppTextStyles.h3.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: AppColors.textSecondary),
                onPressed: controller.refreshDashboard,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Chargement des données...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            final labels = controller.chartLabels;
            final data = controller.chartData;

            if (labels.isEmpty || data.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.show_chart,
                      size: 48,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Aucune donnée disponible',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return SizedBox(
              height: 300,
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  majorGridLines: MajorGridLines(width: 0),
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  labelRotation: -45,
                  interval: 1,
                ),
                primaryYAxis: NumericAxis(
                  numberFormat: currencyFormat,
                  majorGridLines: MajorGridLines(
                    width: 1,
                    color: AppColors.borderLight.withOpacity(0.5),
                  ),
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  format: 'point.x : {point.y}FCFA',
                  color: isDark ? AppColors.gray800 : AppColors.white,
                  textStyle: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
                series: <ChartSeries>[
                  AreaSeries<_RevenueData, String>(
                    dataSource: List.generate(
                      labels.length,
                      (index) => _RevenueData(labels[index], data[index]),
                    ),
                    xValueMapper: (_RevenueData revenue, _) => revenue.date,
                    yValueMapper: (_RevenueData revenue, _) => revenue.amount,
                    name: 'Revenus',
                    color: AppColors.primary.withOpacity(0.2),
                    borderColor: AppColors.primary,
                    borderWidth: 2,
                    animationDuration: 1500,
                    enableTooltip: true,
                    markerSettings: MarkerSettings(
                      isVisible: true,
                      shape: DataMarkerType.circle,
                      borderWidth: 2,
                      borderColor: AppColors.primary,
                      color: Theme.of(context).cardColor,
                    ),
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
