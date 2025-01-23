import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../constants.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../models/enums.dart';

class OrderStatusChart extends StatelessWidget {
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
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Répartition des commandes',
                style: AppTextStyles.h3.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: controller.refreshDashboard,
                tooltip: 'Actualiser',
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

            if (controller.orderStatusCount.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
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

            final displayedStatuses = [
              OrderStatus.PENDING,
              OrderStatus.PROCESSING,
              OrderStatus.DELIVERING,
              OrderStatus.DELIVERED,
              OrderStatus.CANCELLED,
            ];

            final data = displayedStatuses
                .map((status) {
                  final count = controller.getOrderCountByStatus(status.name);
                  return _ChartData(
                    status.label,
                    count.toDouble(),
                    status.color,
                  );
                })
                .where((item) => item.value > 0)
                .toList();

            final total = data.fold<double>(0, (sum, item) => sum + item.value);

            return AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: Column(
                children: [
                  SizedBox(
                    height: 250,
                    child: SfCircularChart(
                      legend: Legend(
                        isVisible: false,
                      ),
                      annotations: [
                        CircularChartAnnotation(
                          widget: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                total.toInt().toString(),
                                style: AppTextStyles.h2.copyWith(
                                  color: isDark
                                      ? AppColors.textLight
                                      : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Total',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      series: <CircularSeries>[
                        DoughnutSeries<_ChartData, String>(
                          dataSource: data,
                          xValueMapper: (_ChartData data, _) => data.label,
                          yValueMapper: (_ChartData data, _) => data.value,
                          pointColorMapper: (_ChartData data, _) => data.color,
                          animationDuration: 1500,
                          innerRadius: '70%',
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            labelPosition: ChartDataLabelPosition.outside,
                            textStyle: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            builder:
                                (data, point, series, pointIndex, seriesIndex) {
                              final chartData = data as _ChartData;
                              final percentage = (chartData.value / total * 100)
                                  .toStringAsFixed(1);
                              return Text(
                                '$percentage%',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    alignment: WrapAlignment.center,
                    children: data
                        .map((item) => _LegendItem(
                              color: item.color,
                              label: item.label,
                              value: item.value.toInt(),
                              total: total,
                            ))
                        .toList(),
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

class _ChartData {
  final String label;
  final double value;
  final Color color;

  _ChartData(this.label, this.value, this.color);
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  final double total;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value / total * 100).toStringAsFixed(1);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4),
          Text(
            '($value · $percentage%)',
            style: AppTextStyles.bodySmall.copyWith(
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
