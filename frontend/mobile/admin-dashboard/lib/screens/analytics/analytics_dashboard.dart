import 'package:flutter/material.dart';
import 'components/revenue_chart.dart';
import 'components/orders_chart.dart';
import 'components/top_services.dart';
import 'components/customer_stats.dart';

class AnalyticsDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: [
        RevenueChart(),
        OrdersChart(),
        TopServices(),
        CustomerStats(),
      ],
    );
  }
}
