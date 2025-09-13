import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../widgets/shared/glass_container.dart';

class NotificationStatsGrid extends StatelessWidget {
  final int totalNotifications;
  final int unreadNotifications;
  final int highPriorityNotifications;
  final int todayNotifications;

  const NotificationStatsGrid({
    Key? key,
    required this.totalNotifications,
    required this.unreadNotifications,
    required this.highPriorityNotifications,
    required this.todayNotifications,
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
              'Total',
              totalNotifications.toString(),
              Icons.notifications_outlined,
              AppColors.primary,
              AppColors.primaryLight,
            ),
            _buildStatCard(
              context,
              isDark,
              'Non lues',
              unreadNotifications.toString(),
              Icons.mark_email_unread_outlined,
              AppColors.error,
              AppColors.errorLight,
            ),
            _buildStatCard(
              context,
              isDark,
              'Priorité haute',
              highPriorityNotifications.toString(),
              Icons.priority_high_outlined,
              AppColors.warning,
              AppColors.warningLight,
            ),
            _buildStatCard(
              context,
              isDark,
              'Aujourd\'hui',
              todayNotifications.toString(),
              Icons.today_outlined,
              AppColors.success,
              AppColors.successLight,
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
                  // Pulse animation pour les notifications non lues
                  if (title == 'Non lues' && int.parse(value) > 0)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: AnimatedContainer(
                        duration: Duration(seconds: 1),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
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