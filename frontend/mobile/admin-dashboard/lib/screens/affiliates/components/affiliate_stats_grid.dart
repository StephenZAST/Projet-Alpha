import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../controllers/affiliates_controller.dart';
import '../../../widgets/shared/glass_container.dart';

class AffiliateStatsGrid extends StatelessWidget {
  const AffiliateStatsGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AffiliatesController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.isLoadingStats.value) {
        return _buildLoadingGrid(isDark);
      }

      final stats = controller.stats.value;
      if (stats == null) {
        return _buildErrorGrid(isDark);
      }

      return GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.2,
        children: [
          _buildStatCard(
            context,
            isDark,
            title: 'Total Affiliés',
            value: stats.totalAffiliates.toString(),
            subtitle: '${stats.activeAffiliates} actifs',
            icon: Icons.handshake_outlined,
            color: AppColors.primary,
            trend:
                stats.totalAffiliates > 0 ? '+${stats.totalAffiliates}' : '0',
          ),
          _buildStatCard(
            context,
            isDark,
            title: 'En Attente',
            value: stats.pendingAffiliates.toString(),
            subtitle: 'Demandes à traiter',
            icon: Icons.hourglass_empty,
            color: AppColors.warning,
            trend: stats.pendingAffiliates > 0 ? 'Action requise' : 'Aucune',
          ),
          _buildStatCard(
            context,
            isDark,
            title: 'Commissions Totales',
            value: stats.formattedTotalCommissions,
            subtitle: 'Ce mois: ${stats.formattedMonthlyCommissions}',
            icon: Icons.account_balance_wallet_outlined,
            color: AppColors.success,
            trend: '+${stats.formattedMonthlyCommissions}',
          ),
          _buildStatCard(
            context,
            isDark,
            title: 'Taux Moyen',
            value: stats.formattedAverageRate,
            subtitle: '${stats.totalReferrals} référencements',
            icon: Icons.trending_up,
            color: AppColors.info,
            trend: stats.formattedAverageRate,
          ),
        ],
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
                    size: 24,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: AppRadius.radiusXS,
                  ),
                  child: Text(
                    trend,
                    style: AppTextStyles.caption.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: AppTextStyles.h2.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.textMuted,
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
              ? AppColors.gray700.withOpacity(0.3)
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
                    color: AppColors.gray300.withOpacity(0.3),
                    borderRadius: AppRadius.radiusSM,
                  ),
                ),
                Container(
                  width: 50,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.gray300.withOpacity(0.3),
                    borderRadius: AppRadius.radiusXS,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Container(
              width: 80,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.gray300.withOpacity(0.3),
                borderRadius: AppRadius.radiusXS,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Container(
              width: 120,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.gray300.withOpacity(0.3),
                borderRadius: AppRadius.radiusXS,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Container(
              width: 100,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.gray300.withOpacity(0.3),
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
              color: AppColors.error,
              size: 48,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Erreur de chargement des statistiques',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () =>
                  Get.find<AffiliatesController>().fetchAffiliateStats(),
              child: Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
