import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../widgets/shared/glass_container.dart';

class NotificationStatsGrid extends StatelessWidget {
  final int totalNotifications;
  final int unreadNotifications;
  final int highPriorityNotifications;
  final int todayNotifications;
  final bool isLoading;

  const NotificationStatsGrid({
    Key? key,
    required this.totalNotifications,
    required this.unreadNotifications,
    required this.highPriorityNotifications,
    required this.todayNotifications,
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
          title: 'Total',
          value: totalNotifications.toString(),
          subtitle: 'Toutes notifications',
          icon: Icons.notifications_outlined,
          color: AppColors.primary,
          trend: '+$totalNotifications',
        ),
        _buildStatCard(
          context,
          isDark,
          title: 'Non lues',
          value: unreadNotifications.toString(),
          subtitle: 'À traiter',
          icon: Icons.mark_email_unread_outlined,
          color: AppColors.error,
          trend: unreadNotifications > 0 ? '$unreadNotifications' : '0',
        ),
        _buildStatCard(
          context,
          isDark,
          title: 'Priorité haute',
          value: highPriorityNotifications.toString(),
          subtitle: 'Urgentes',
          icon: Icons.priority_high_outlined,
          color: AppColors.warning,
          trend: highPriorityNotifications > 0
              ? '$highPriorityNotifications'
              : '0',
        ),
        _buildStatCard(
          context,
          isDark,
          title: 'Aujourd\'hui',
          value: todayNotifications.toString(),
          subtitle: 'Nouvelles aujourd\'hui',
          icon: Icons.today_outlined,
          color: AppColors.success,
          trend: '+$todayNotifications',
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
                // Pulse animation pour les notifications non lues
                if (title == 'Non lues' && int.parse(value) > 0)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: AppRadius.radiusXS,
                    ),
                    child: Text(
                      'Urgent',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
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
