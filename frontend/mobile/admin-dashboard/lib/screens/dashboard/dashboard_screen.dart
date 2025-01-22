import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/dashboard_controller.dart';
import 'components/header.dart';
import 'components/statistics_cards.dart';
import 'components/revenue_chart.dart';
import 'components/recent_files.dart';
import 'components/storage_details.dart';
import 'components/recent_orders.dart';
import 'components/order_status_metrics.dart';
import 'components/order_status_chart.dart';
import '../../widgets/loading_overlay.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController controller = Get.find<DashboardController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        if (controller.isLoading.value) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          );
        }

        if (controller.hasError.value) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    controller.errorMessage.value,
                    style: TextStyle(color: AppColors.error),
                  ),
                  SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: controller.fetchDashboardData,
                    child: Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: SingleChildScrollView(
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
                    if (!_isMobile(context)) SizedBox(width: defaultPadding),
                    if (!_isMobile(context))
                      Expanded(
                        flex: 2,
                        child: OrderStatusChart(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 850;
  }

  @override
  void dispose() {
    print('[DashboardScreen] Disposing');
    super.dispose();
  }
}
