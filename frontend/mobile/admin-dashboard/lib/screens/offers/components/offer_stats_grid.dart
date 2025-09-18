import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../widgets/shared/glass_container.dart';

class OfferStatsGrid extends StatelessWidget {
  final int totalOffers;
  final int activeOffers;
  final int expiredOffers;
  final double totalDiscountValue;
  final bool isLoading;

  const OfferStatsGrid({
    Key? key,
    required this.totalOffers,
    required this.activeOffers,
    required this.expiredOffers,
    required this.totalDiscountValue,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return _buildLoadingGrid(isDark);
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
          title: 'Total Offres',
          value: totalOffers.toString(),
          subtitle: 'Toutes les offres',
          icon: Icons.local_offer_outlined,
          color: AppColors.primary,
          trend: '+$totalOffers',
        ),
        _buildStatCard(
          context,
          isDark,
          title: 'Offres Actives',
          value: activeOffers.toString(),
          subtitle: 'Actuellement disponibles',
          icon: Icons.check_circle_outline,
          color: AppColors.success,
          trend: '+$activeOffers',
        ),
        _buildStatCard(
          context,
          isDark,
          title: 'Offres Expirées',
          value: expiredOffers.toString(),
          subtitle: 'Non disponibles',
          icon: Icons.schedule_outlined,
          color: AppColors.warning,
          trend: expiredOffers > 0 ? '$expiredOffers' : '0',
        ),
        _buildStatCard(
          context,
          isDark,
          title: 'Valeur Totale',
          value: '${totalDiscountValue.toStringAsFixed(0)} FCFA',
          subtitle: 'Réduction totale',
          icon: Icons.monetization_on_outlined,
          color: AppColors.info,
          trend: '${totalDiscountValue.toStringAsFixed(0)} FCFA',
        ),
      ],
    );
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
}
