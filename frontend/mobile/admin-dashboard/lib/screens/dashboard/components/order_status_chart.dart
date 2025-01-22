import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import 'package:get/get.dart';

class OrderStatusChart extends GetView<OrdersController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.secondaryBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order Status Distribution",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: defaultPadding),
          Obx(() => SizedBox(
                height: 200,
                child: controller.ordersByStatus.isEmpty
                    ? Center(child: Text('No data available'))
                    : PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 40,
                          sections: _getChartSections(),
                          startDegreeOffset: -90,
                        ),
                      ),
              )),
          Obx(() => ChartLegend(ordersByStatus: controller.ordersByStatus)),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getChartSections() {
    if (controller.ordersByStatus.isEmpty) return [];

    final total =
        controller.ordersByStatus.values.fold(0, (sum, count) => sum + count);

    return controller.ordersByStatus.entries.map((entry) {
      final percentage = total > 0 ? (entry.value / total) * 100 : 0.0;

      return PieChartSectionData(
        color: _getStatusColor(entry.key),
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return AppColors.warning;
      case 'PROCESSING':
        return AppColors.primary;
      case 'DELIVERED':
        return AppColors.success;
      case 'CANCELLED':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

class ChartLegend extends StatelessWidget {
  final Map<String, int> ordersByStatus;

  const ChartLegend({Key? key, required this.ordersByStatus}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ordersByStatus.entries
          .map((entry) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getStatusColor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Text(
                      '${entry.value}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return AppColors.warning;
      case 'PROCESSING':
        return AppColors.primary;
      case 'DELIVERED':
        return AppColors.success;
      case 'CANCELLED':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
