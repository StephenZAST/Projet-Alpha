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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              context,
              icon: Icons.local_shipping_outlined,
              title: 'Livraisons du jour',
              value: controller.totalDeliveries as RxNum,
              color: AppColors.primary,
              isDark: isDark,
            ),
            _buildStatItem(
              context,
              icon: Icons.check_circle_outline,
              title: 'Complétées',
              value: controller.completedDeliveries as RxNum,
              color: AppColors.success,
              isDark: isDark,
            ),
            _buildStatItem(
              context,
              icon: Icons.route_outlined,
              title: 'Distance totale',
              value: controller.totalDistance as RxNum,
              suffix: 'km',
              color: AppColors.warning,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required RxNum value,
    String? suffix,
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
        Obx(() => Text(
              '${value.value.toString()}${suffix ?? ''}',
              style: AppTextStyles.h3.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            )),
      ],
    );
  }
}
