import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../controllers/dashboard_controller.dart';

class StatisticsCards extends StatelessWidget {
  final currencyFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'FCFA',
    decimalDigits: 0,
  );

  double _calculateGrowth(DashboardController controller) {
    final data = controller.chartData;
    if (data.length < 2) return 0;

    final currentValue = data.last;
    final previousValue = data[data.length - 2];
    if (previousValue == 0) return 0;

    return ((currentValue - previousValue) / previousValue) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Chargement des statistiques...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }

      final revenueGrowth = _calculateGrowth(controller);

      return GridView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          crossAxisSpacing: defaultPadding,
          mainAxisSpacing: defaultPadding,
          childAspectRatio: _getChildAspectRatio(context),
        ),
        children: [
          _StatCard(
            title: 'Revenus Totaux',
            value: currencyFormat.format(controller.totalRevenue.value),
            icon: Icons.monetization_on_outlined,
            iconColor: AppColors.success,
            change: revenueGrowth,
            isDark: isDark,
          ),
          _StatCard(
            title: 'Commandes',
            value: controller.totalOrders.toString(),
            icon: Icons.shopping_cart_outlined,
            iconColor: AppColors.primary,
            change: 0,
            isDark: isDark,
            showChange: false,
          ),
          _StatCard(
            title: 'Clients',
            value: controller.totalCustomers.toString(),
            icon: Icons.people_outline,
            iconColor: AppColors.accent,
            change: 0,
            isDark: isDark,
            showChange: false,
          ),
          _StatCard(
            title: 'En cours',
            value: controller.getOrderCountByStatus('PROCESSING').toString(),
            icon: Icons.pending_actions_outlined,
            iconColor: AppColors.warning,
            change: 0,
            isDark: isDark,
            showChange: false,
          ),
        ],
      );
    });
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 2;
    return 1;
  }

  double _getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 1.5;
    if (width > 800) return 1.8;
    return 1.6;
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final double change;
  final bool isDark;
  final bool showChange;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.change,
    required this.isDark,
    this.showChange = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: AppRadius.radiusSM,
                ),
                child: Icon(icon, color: iconColor),
              ),
              if (showChange && change != 0)
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: (change >= 0 ? AppColors.success : AppColors.error)
                        .withOpacity(0.1),
                    borderRadius: AppRadius.radiusSM,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        change >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                        color:
                            change >= 0 ? AppColors.success : AppColors.error,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${change.abs().toStringAsFixed(1)}%',
                        style: AppTextStyles.bodySmall.copyWith(
                          color:
                              change >= 0 ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
