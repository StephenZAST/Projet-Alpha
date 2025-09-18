import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../widgets/shared/glass_container.dart';

class ArticleStatsGrid extends StatelessWidget {
  final int totalArticles;
  final int activeArticles;
  final int categoriesCount;
  final double averagePrice;
  final bool isLoading;

  const ArticleStatsGrid({
    Key? key,
    required this.totalArticles,
    required this.activeArticles,
    required this.categoriesCount,
    required this.averagePrice,
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
          title: 'Total Articles',
          value: totalArticles.toString(),
          subtitle: 'Tous les articles',
          icon: Icons.article_outlined,
          color: AppColors.primary,
          trend: '+$totalArticles',
        ),
        _buildStatCard(
          context,
          isDark,
          title: 'Articles Actifs',
          value: activeArticles.toString(),
          subtitle: 'Disponibles',
          icon: Icons.check_circle_outline,
          color: AppColors.success,
          trend: '+$activeArticles',
        ),
        _buildStatCard(
          context,
          isDark,
          title: 'Catégories',
          value: categoriesCount.toString(),
          subtitle: 'Types d\'articles',
          icon: Icons.category_outlined,
          color: AppColors.info,
          trend: '+$categoriesCount',
        ),
        _buildStatCard(
          context,
          isDark,
          title: 'Prix Moyen',
          value: '${averagePrice.toStringAsFixed(0)} FCFA',
          subtitle: 'Prix moyen',
          icon: Icons.monetization_on_outlined,
          color: AppColors.warning,
          trend: '${averagePrice.toStringAsFixed(0)} FCFA',
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