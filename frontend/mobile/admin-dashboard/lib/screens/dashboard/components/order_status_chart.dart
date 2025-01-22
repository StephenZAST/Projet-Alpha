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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statut des commandes',
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

            if (controller.orderStatusCount.isEmpty) {
              return Center(
                child: Text(
                  'Aucune donnée disponible',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }

            final data = controller.orderStatusCount.entries.map((entry) {
              final status = entry.key.toOrderStatus();
              return _ChartData(
                status.label,
                entry.value.toDouble(),
                status.color,
              );
            }).toList();

            final total = data.fold<double>(0, (sum, item) => sum + item.value);

            return Column(
              children: [
                SizedBox(
                  height: 200,
                  child: SfCircularChart(
                    legend: Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                      orientation: LegendItemOrientation.horizontal,
                      overflowMode: LegendItemOverflowMode.wrap,
                      textStyle: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CircularSeries>[
                      DoughnutSeries<_ChartData, String>(
                        dataSource: data,
                        xValueMapper: (_ChartData data, _) => data.label,
                        yValueMapper: (_ChartData data, _) => data.value,
                        pointColorMapper: (_ChartData data, _) => data.color,
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
                  children: data
                      .map((item) => _LegendItem(
                            color: item.color,
                            label: item.label,
                            value: item.value.toInt(),
                          ))
                      .toList(),
                ),
              ],
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

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
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
          SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4),
          Text(
            '($value)',
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
