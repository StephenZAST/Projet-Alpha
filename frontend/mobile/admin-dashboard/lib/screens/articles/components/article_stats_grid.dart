import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../widgets/shared/glass_container.dart';

class ArticleStatsGrid extends StatelessWidget {
  final int totalArticles;
  final int activeArticles;
  final int categoriesCount;
  final double averagePrice;

  const ArticleStatsGrid({
    Key? key,
    required this.totalArticles,
    required this.activeArticles,
    required this.categoriesCount,
    required this.averagePrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid: 4 colonnes sur desktop, 2 sur tablette, 1 sur mobile
        int crossAxisCount = 4;
        if (constraints.maxWidth < 1200) crossAxisCount = 2;
        if (constraints.maxWidth < 600) crossAxisCount = 1;

        return GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.8,
          children: [
            _buildStatCard(
              context,
              isDark,
              'Total Articles',
              totalArticles.toString(),
              Icons.article_outlined,
              AppColors.primary,
              AppColors.primaryLight,
            ),
            _buildStatCard(
              context,
              isDark,
              'Articles Actifs',
              activeArticles.toString(),
              Icons.check_circle_outline,
              AppColors.success,
              AppColors.successLight,
            ),
            _buildStatCard(
              context,
              isDark,
              'Catégories',
              categoriesCount.toString(),
              Icons.category_outlined,
              AppColors.info,
              AppColors.infoLight,
            ),
            _buildStatCard(
              context,
              isDark,
              'Prix Moyen',
              '${averagePrice.toStringAsFixed(0)} FCFA',
              Icons.monetization_on_outlined,
              AppColors.warning,
              AppColors.warningLight,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    bool isDark,
    String title,
    String value,
    IconData icon,
    Color primaryColor,
    Color lightColor,
  ) {
    return GlassContainer(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Stack(
        children: [
          // Gradient background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor.withOpacity(0.1),
                    lightColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: AppRadius.radiusMD,
              ),
            ),
          ),
          
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.15),
                      borderRadius: AppRadius.radiusSM,
                    ),
                    child: Icon(
                      icon,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  // Trend indicator (placeholder for future implementation)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: AppRadius.radiusSM,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 12,
                          color: AppColors.success,
                        ),
                        SizedBox(width: 2),
                        Text(
                          '+3%',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
                      fontSize: 28,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}