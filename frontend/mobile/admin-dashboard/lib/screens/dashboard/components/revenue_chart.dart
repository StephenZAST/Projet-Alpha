import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../constants.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../models/revenue_data.dart';

class RevenueChart extends StatelessWidget {
  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'fcfa',
    decimalDigits: 0,
  );

  List<RevenueData> _prepareChartData(
      List<String> labels, List<double> values) {
    final data = <RevenueData>[];
    for (var i = 0; i < labels.length; i++) {
      data.add(RevenueData(
        period: labels[i],
        amount: values[i],
        previousAmount: i > 0 ? values[i - 1] : null,
      ));
    }
    return data;
  }

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
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        final revenueData = _prepareChartData(
          controller.revenueChartLabels,
          controller.revenueChartData,
        );

        if (revenueData.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.show_chart,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: AppSpacing.md),
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

        return Column(
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
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'week',
                      child: Text('Cette semaine'),
                    ),
                    PopupMenuItem(
                      value: 'month',
                      child: Text('Ce mois'),
                    ),
                    PopupMenuItem(
                      value: 'year',
                      child: Text('Cette année'),
                    ),
                  ],
                  onSelected: (value) {
                    // TODO: Implémenter le filtrage par période
                  },
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  majorGridLines: MajorGridLines(width: 0),
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  axisLine: AxisLine(
                    width: 1,
                    color: isDark ? AppColors.gray700 : AppColors.gray200,
                  ),
                  majorTickLines: MajorTickLines(size: 0),
                ),
                primaryYAxis: NumericAxis(
                  numberFormat: currencyFormat,
                  majorGridLines: MajorGridLines(
                    width: 1,
                    color: isDark ? AppColors.gray700 : AppColors.gray200,
                    dashArray: [5, 5],
                  ),
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  axisLine: AxisLine(width: 0),
                  majorTickLines: MajorTickLines(size: 0),
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  color: Theme.of(context).cardColor,
                  textStyle: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                zoomPanBehavior: ZoomPanBehavior(
                  enablePinching: true,
                  enableDoubleTapZooming: true,
                  enableMouseWheelZooming: true,
                  zoomMode: ZoomMode.x,
                ),
                series: <ChartSeries>[
                  SplineAreaSeries<RevenueData, String>(
                    name: 'Revenus',
                    dataSource: revenueData,
                    xValueMapper: (RevenueData data, _) => data.period,
                    yValueMapper: (RevenueData data, _) => data.amount,
                    color: AppColors.primary.withOpacity(0.2),
                    borderColor: AppColors.primary,
                    borderWidth: 3,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withOpacity(0.3),
                        AppColors.primary.withOpacity(0.05),
                      ],
                    ),
                    markerSettings: MarkerSettings(
                      isVisible: true,
                      color: AppColors.primary,
                      borderColor: Theme.of(context).cardColor,
                      borderWidth: 2,
                    ),
                    animationDuration: 1500,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      currencyFormat.format(revenueData.last.amount),
                      style: AppTextStyles.h3.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Croissance',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          revenueData.last.isPositiveGrowth
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: revenueData.last.isPositiveGrowth
                              ? AppColors.success
                              : AppColors.error,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${revenueData.last.growth.abs().toStringAsFixed(1)}%',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: revenueData.last.isPositiveGrowth
                                ? AppColors.success
                                : AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
