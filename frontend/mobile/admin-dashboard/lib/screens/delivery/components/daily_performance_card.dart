import 'package:admin/widgets/shared/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/delivery_controller.dart';
import '../../../constants.dart';
import '../../../models/delivery.dart';

class DailyPerformanceCard extends StatelessWidget {
  const DailyPerformanceCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DeliveryController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Obx(() {
        final stats = controller.globalStats.value;
        if (controller.isLoadingStats.value || stats == null) {
          return Center(child: CircularProgressIndicator());
        }

        final total = stats.totalOrdersToday;
        final completed = stats.completedOrdersToday;
        final completionRate = total > 0 ? completed / total : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: AppSpacing.lg),
            _buildProgressIndicators(completionRate, completed, total, isDark),
            SizedBox(height: AppSpacing.lg),
            _buildStats(stats, isDark),
          ],
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Performance du jour',
      style: AppTextStyles.h4,
    );
  }

  Widget _buildProgressIndicators(
      double completionRate, int completed, int total, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${(completionRate * 100).toStringAsFixed(0)}% complété',
          style: AppTextStyles.h3.copyWith(color: AppColors.success),
        ),
        SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: AppRadius.radiusSM,
          child: LinearProgressIndicator(
            value: completionRate,
            backgroundColor: isDark ? AppColors.gray700 : AppColors.gray200,
            color: AppColors.success,
            minHeight: 10,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          '$completed sur $total livraisons',
          style: AppTextStyles.bodySmallSecondary,
        ),
      ],
    );
  }

  Widget _buildStats(GlobalDeliveryStats stats, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          'Livreurs actifs',
          '${stats.activeDeliverers}',
          Icons.person_outline,
          AppColors.info,
          isDark,
        ),
        _buildStatItem(
          'Commandes en attente',
          '${stats.pendingOrders}',
          Icons.hourglass_empty_outlined,
          AppColors.warning,
          isDark,
        ),
        _buildStatItem(
          'Temps moyen',
          '${stats.averageDeliveryTime.toStringAsFixed(0)} min',
          Icons.timer_outlined,
          AppColors.primary,
          isDark,
        ),
      ],
    );
  }

  Widget _buildStatItem(
      String title, String value, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}
