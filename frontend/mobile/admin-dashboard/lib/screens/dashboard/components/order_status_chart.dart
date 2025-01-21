import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import '../../../models/order.dart';
import 'package:get/get.dart';

class OrderStatusChart extends StatelessWidget {
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
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: _getChartSections(),
                startDegreeOffset: -90,
              ),
            ),
          ),
          ChartLegend(),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getChartSections() {
    final controller = Get.find<OrdersController>();
    return OrderStatus.values.map((status) {
      final percentage = controller.getOrderPercentageByStatus(status.name);
      return PieChartSectionData(
        color: status.color,
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
}

class ChartLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: OrderStatus.values
          .map((status) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: status.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        status.label,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Text(
                      '${Get.find<OrdersController>().getOrderCountByStatus(status.name)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
