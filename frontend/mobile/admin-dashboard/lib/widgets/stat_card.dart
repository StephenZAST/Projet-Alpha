import 'package:flutter/material.dart';
import '../constants.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String? subtitle;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: isDark ? color.withOpacity(0.1) : color.withOpacity(0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusMD,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 24),
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.gray200 : AppColors.gray700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                value,
                style: AppTextStyles.h2.copyWith(color: color),
              ),
              if (subtitle != null) ...[
                SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.gray600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
