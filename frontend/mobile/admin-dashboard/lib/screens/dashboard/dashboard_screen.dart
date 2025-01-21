import 'package:admin/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants.dart';
import 'components/header.dart';
import 'components/statistics_cards.dart';
import 'components/revenue_chart.dart';
import 'components/recent_files.dart';
import 'components/storage_details.dart';
import 'components/recent_orders.dart';
import 'components/order_status_metrics.dart';
import 'components/order_status_chart.dart';
import '../../controllers/dashboard_controller.dart';
import '../../widgets/loading_overlay.dart';
import '../../controllers/orders_controller.dart';

class DashboardScreen extends StatelessWidget {
  final ordersController = Get.put(OrdersController());

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return SafeArea(
      child: LoadingOverlay(
        isLoading: controller.isLoading.value,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              Header(title: "Dashboard"),
              SizedBox(height: defaultPadding),
              StatisticsCards(),
              SizedBox(height: defaultPadding),
              RevenueChart(),
              SizedBox(height: defaultPadding),
              OrderStatusMetrics(),
              SizedBox(height: defaultPadding),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        RecentFiles(),
                        SizedBox(height: defaultPadding),
                        RecentOrders(),
                      ],
                    ),
                  ),
                  if (!Responsive.isMobile(context))
                    SizedBox(width: defaultPadding),
                  if (!Responsive.isMobile(context))
                    Expanded(
                      flex: 2,
                      child: StorageDetails(),
                    ),
                ],
              ),
              SizedBox(height: defaultPadding),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: RecentOrders(),
                  ),
                  if (!Responsive.isMobile(context))
                    SizedBox(width: defaultPadding),
                  if (!Responsive.isMobile(context))
                    Expanded(
                      flex: 2,
                      child: OrderStatusChart(),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
