import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/loyalty_controller.dart';
import '../../../widgets/shared/glass_container.dart';

class LoyaltyStatsGrid extends StatelessWidget {
  const LoyaltyStatsGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoyaltyController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.isLoadingStats.value) {
        return _buildLoadingGrid(context, isDark);
      }

      final stats = controller.stats.value;
      if (stats == null) {
        return _buildErrorGrid(context, isDark);
      }

      return _buildStatsGrid(context, isDark, stats);
    });
  }

  Widget _buildLoadingGrid(BuildContext context, bool isDark) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.2,
      children: List.generate(
        6,
        (index) => GlassContainer(
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorGrid(BuildContext context, bool isDark) {
    return GlassContainer(
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

  Widget _buildStatsGrid(BuildContext context, bool isDark, stats) {
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
          'Utilisateurs Actifs',
          stats.activeUsers.toString(),
          Icons.people_outline,
          AppColors.primary,
          subtitle: 'sur ${stats.totalUsers} utilisateurs',
        ),
        _buildStatCard(
          context,
          isDark,
          'Points Distribués',
          stats.formattedTotalPointsDistributed,
          Icons.stars_outlined,
          AppColors.success,
          subtitle: 'au total',
        ),
        _buildStatCard(
          context,
          isDark,
          'Points Échangés',
          stats.formattedTotalPointsRedeemed,
          Icons.redeem_outlined,
          AppColors.warning,
          subtitle: 'utilisés',
        ),
        _buildStatCard(
          context,
          isDark,
          'Taux d\'Échange',
          stats.formattedRedemptionRate,
          Icons.trending_up_outlined,
          AppColors.info,
          subtitle: 'des points distribués',
        ),
        _buildStatCard(
          context,
          isDark,
          'Moyenne par Utilisateur',
          stats.formattedAveragePoints,
          Icons.person_outline,
          AppColors.violet,
          subtitle: 'points moyens',
        ),
        _buildStatCard(
          context,
          isDark,
          'Demandes en Attente',
          stats.pendingClaims.toString(),
          Icons.hourglass_empty_outlined,
          AppColors.orange,
          subtitle: 'à traiter',
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    bool isDark,
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return GlassContainer(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color:
                          isDark ? AppColors.gray300 : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.h2.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
