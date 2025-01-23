import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../responsive.dart';
import '../../controllers/dashboard_controller.dart';
import 'components/header.dart';
import 'components/statistics_cards.dart';
import 'components/revenue_chart.dart';
import 'components/recent_orders.dart';
import 'components/order_status_metrics.dart';
import 'components/order_status_chart.dart';

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
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Material(
            type: MaterialType.transparency,
            child: RefreshIndicator(
              onRefresh: controller.refreshDashboard,
              child: Obx(() {
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
                          'Chargement du tableau de bord...',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.hasError.value) {
                  return Center(
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
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSpacing.md),
                        ElevatedButton.icon(
                          onPressed: controller.fetchDashboardData,
                          icon: Icon(Icons.refresh),
                          label: Text('Réessayer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textLight,
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.sm,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Stack(
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.all(defaultPadding),
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          Header(title: "Tableau de bord"),
                          SizedBox(height: defaultPadding),
                          StatisticsCards(),
                          SizedBox(height: defaultPadding),
                          RevenueChart(),
                          SizedBox(height: defaultPadding),
                          OrderStatusMetrics(),
                          SizedBox(height: defaultPadding),
                          _buildMainContent(context),
                        ],
                      ),
                    ),
                    Positioned(
                      right: defaultPadding,
                      bottom: defaultPadding,
                      child: FloatingActionButton(
                        onPressed: controller.refreshDashboard,
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.refresh, color: AppColors.textLight),
                        tooltip: 'Rafraîchir les données',
                      ),
                    ),
                  ],
                );
              }),
            )),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                RecentOrders(),
                SizedBox(height: defaultPadding),
              ],
            ),
          ),
          SizedBox(width: defaultPadding),
          Expanded(
            flex: 1,
            child: OrderStatusChart(),
          ),
        ],
      );
    }

    return Column(
      children: [
        OrderStatusChart(),
        SizedBox(height: defaultPadding),
        RecentOrders(),
      ],
    );
  }

  @override
  void dispose() {
    print('[DashboardScreen] Disposing');
    super.dispose();
  }
}
