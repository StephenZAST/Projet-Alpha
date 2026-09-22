import 'package:flutter/material.dart';
import '../../../models/admin_log.dart';
import '../../../constants.dart';

class LogListTile extends StatelessWidget {
  final AdminLog log;

  const LogListTile({Key? key, required this.log}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actionParts = log.action.split('.');
    final actionLabel = actionParts.length > 1 ? actionParts.last : log.action;
    final timeLabel =
        '${log.createdAt.day.toString().padLeft(2, '0')}/${log.createdAt.month.toString().padLeft(2, '0')}/${log.createdAt.year} ${log.createdAt.hour.toString().padLeft(2, '0')}:${log.createdAt.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      elevation: 0,
      color: isDark ? AppColors.cardBgDark : AppColors.cardBgLight,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusSM,
        side: BorderSide(
          color: isDark ? AppColors.gray700 : AppColors.gray200,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: Icon(Icons.history, color: AppColors.primary, size: 20),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                log.adminName,
                style: AppTextStyles.bodyBold.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: AppRadius.radiusSM,
              ),
              child: Text(
                actionLabel,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: AppSpacing.xs),
          child: Text(
            '${log.entityType}  •  ${log.entityId.isEmpty ? 'Système' : log.entityId}  •  $timeLabel',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
