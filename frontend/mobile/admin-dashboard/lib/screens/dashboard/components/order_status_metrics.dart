import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../models/enums.dart';

class OrderStatusMetrics extends StatelessWidget {
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
      child: Obx(() {
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
                  'Chargement des statuts...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color:
                        isDark ? AppColors.textLight : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        final List<OrderStatus> displayedStatuses = [
          OrderStatus.PENDING,
          OrderStatus.PROCESSING,
          OrderStatus.DELIVERING,
          OrderStatus.DELIVERED,
        ];

        final totalOrders = controller.totalOrders.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Statuts des commandes',
                  style: AppTextStyles.h3.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.refresh_outlined,
                    color:
                        isDark ? AppColors.textLight : AppColors.textSecondary,
                  ),
                  onPressed: controller.refreshDashboard,
                  tooltip: 'Actualiser',
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(context),
                crossAxisSpacing: defaultPadding,
                mainAxisSpacing: defaultPadding,
                childAspectRatio: _getChildAspectRatio(context),
              ),
              itemCount: displayedStatuses.length,
              itemBuilder: (context, index) {
                final status = displayedStatuses[index];
                final count = controller.getOrderCountByStatus(status.name);
                final percentage =
                    totalOrders > 0 ? (count / totalOrders * 100) : 0.0;

                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _StatusCard(
                    status: status,
                    count: count,
                    percentage: percentage,
                    isDark: isDark,
                  ),
                );
              },
            ),
          ],
        );
      }),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 2;
    return 2;
  }

  double _getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 1.3;
    if (width > 800) return 1.6;
    return 1.2;
  }
}

class _StatusCard extends StatelessWidget {
  final OrderStatus status;
  final int count;
  final double percentage;
  final bool isDark;

  const _StatusCard({
    required this.status,
    required this.count,
    required this.percentage,
    required this.isDark,
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
            color: status.color.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: status.color.withOpacity(0.1),
                  borderRadius: AppRadius.radiusSM,
                ),
                child: Icon(status.icon, color: status.color),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: status.color.withOpacity(0.1),
                  borderRadius: AppRadius.radiusSM,
                ),
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: status.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            count.toString(),
            style: AppTextStyles.h2.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            status.label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppRadius.radiusFull,
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: status.color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(status.color),
            ),
          ),
        ],
      ),
    );
  }
}
