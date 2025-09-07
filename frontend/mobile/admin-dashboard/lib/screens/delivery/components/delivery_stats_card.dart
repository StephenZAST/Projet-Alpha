import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/delivery_controller.dart';
import '../../../constants.dart';

class DeliveryStatsCard extends StatelessWidget {
  const DeliveryStatsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DeliveryController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusMD,
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Obx(() {
          final stats = controller.globalStats.value;
          final total = stats?.totalOrdersToday ?? 0;
          final completed = stats?.completedOrdersToday ?? 0;
          final avgTime = stats?.averageDeliveryTime ?? 0.0;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                icon: Icons.local_shipping_outlined,
                title: 'Livraisons du jour',
                valueText: '$total',
                color: AppColors.primary,
                isDark: isDark,
              ),
              _buildStatItem(
                context,
                icon: Icons.check_circle_outline,
                title: 'Complétées',
                valueText: '$completed',
                color: AppColors.success,
                isDark: isDark,
              ),
              _buildStatItem(
                context,
                icon: Icons.timer_outlined,
                title: 'Temps moyen',
                valueText: '${avgTime.toStringAsFixed(0)} min',
                color: AppColors.warning,
                isDark: isDark,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String valueText,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: AppRadius.radiusSM,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.gray300 : AppColors.gray600,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          valueText,
          style: AppTextStyles.h3.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
