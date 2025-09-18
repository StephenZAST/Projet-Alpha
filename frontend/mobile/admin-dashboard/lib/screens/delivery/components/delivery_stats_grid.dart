import 'package:admin/widgets/shared/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../controllers/delivery_controller.dart';
import '../../../models/enums.dart';

class DeliveryStatsGrid extends StatelessWidget {
  const DeliveryStatsGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DeliveryController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.isLoadingStats.value) {
        return _buildLoadingGrid(isDark);
      }

      final stats = controller.globalStats.value;
      if (stats == null) {
        return _buildErrorGrid(isDark);
      }

      final statusEntries = stats.ordersByStatus.entries.toList();

      return GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.2,
        children: statusEntries.map((entry) {
          final status = OrderStatus.values.firstWhere(
            (e) => e.name == entry.key,
            orElse: () => OrderStatus.DRAFT,
          );
          return _buildStatCard(
            context,
            isDark,
            title: status.label,
            value: entry.value.toString(),
            subtitle: 'Commandes ${status.label.toLowerCase()}',
            icon: status.icon,
            color: status.color,
            trend: entry.value > 0 ? '+${entry.value}' : '0',
          );
        }).toList(),
      );
    });
  }

  Widget _buildStatCard(
    BuildContext context,
    bool isDark, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
    return GlassContainer(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: AppRadius.radiusSM,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: AppRadius.radiusXS,
                  ),
                  child: Text(
                    trend,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGrid(bool isDark) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.2,
      children: List.generate(4, (index) => _buildLoadingCard(isDark)),
    );
  }

  Widget _buildLoadingCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.gray800.withOpacity(0.5)
            : Colors.white.withOpacity(0.8),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark
              ? AppColors.gray700.withOpacity(0.5)
              : AppColors.gray200.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.gray700.withOpacity(0.3)
                        : AppColors.gray300.withOpacity(0.3),
                    borderRadius: AppRadius.radiusSM,
                  ),
                ),
                Container(
                  width: 50,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.gray700.withOpacity(0.3)
                        : AppColors.gray300.withOpacity(0.3),
                    borderRadius: AppRadius.radiusXS,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Container(
              width: 60,
              height: 24,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.gray700.withOpacity(0.3)
                    : AppColors.gray300.withOpacity(0.3),
                borderRadius: AppRadius.radiusXS,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Container(
              width: 80,
              height: 16,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.gray700.withOpacity(0.3)
                    : AppColors.gray300.withOpacity(0.3),
                borderRadius: AppRadius.radiusXS,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorGrid(bool isDark) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.gray800.withOpacity(0.5)
            : Colors.white.withOpacity(0.8),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error.withOpacity(0.7),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Erreur de chargement des statistiques',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
