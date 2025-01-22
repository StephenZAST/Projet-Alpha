import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import '../../../models/enums.dart';

class OrderStatusMetrics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();
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
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        final List<OrderStatus> displayedStatuses = [
          OrderStatus.PENDING,
          OrderStatus.PROCESSING,
          OrderStatus.DELIVERING,
          OrderStatus.DELIVERED,
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statuts des commandes',
              style: AppTextStyles.h3.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
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
                final count = controller.getOrderCountByStatus(status);
                final percentage =
                    controller.getOrderPercentageByStatus(status);

                return _StatusCard(
                  status: status,
                  count: count,
                  percentage: percentage,
                  isDark: isDark,
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
    return 1;
  }

  double _getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 1.3;
    if (width > 800) return 1.6;
    return 1.5;
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
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.radiusSM,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
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
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: status.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            '$count',
            style: AppTextStyles.h2.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            status.label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
