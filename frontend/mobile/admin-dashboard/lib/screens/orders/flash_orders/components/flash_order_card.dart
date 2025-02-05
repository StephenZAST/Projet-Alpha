import 'package:flutter/material.dart';
import '../../../../models/order.dart';
import '../../../../constants.dart';

class FlashOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const FlashOrderCard({
    Key? key,
    required this.order,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.gray800 : AppColors.white;
    final textColor = isDark ? AppColors.textLight : AppColors.textPrimary;
    final secondaryTextColor =
        isDark ? AppColors.gray400 : AppColors.textSecondary;

    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: defaultPadding),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusMD,
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusMD,
        child: Padding(
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Commande #${order.id.substring(0, 8)}',
                    style: AppTextStyles.h4.copyWith(color: textColor),
                  ),
                  _buildStatusBadge(),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              if (order.user != null) ...[
                Text(
                  'Client: ${order.user!.firstName} ${order.user!.lastName}',
                  style: AppTextStyles.bodyMedium.copyWith(color: textColor),
                ),
                SizedBox(height: AppSpacing.sm),
              ],
              if (order.note != null || order.metadata?.note != null) ...[
                Text(
                  'Note: ${order.note ?? order.metadata?.note}',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: secondaryTextColor),
                ),
                SizedBox(height: AppSpacing.sm),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule,
                          size: 16, color: _getStatusColor(order.status)),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        'Status: ${_getStatusLabel(order.status)}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: _getStatusColor(order.status),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: secondaryTextColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: AppRadius.radiusSM,
      ),
      child: Text(
        'FLASH',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DRAFT':
        return AppColors.info;
      case 'PENDING':
        return AppColors.warning;
      case 'COLLECTING':
        return AppColors.primary;
      case 'PROCESSING':
        return AppColors.accent;
      case 'COMPLETED':
        return AppColors.success;
      case 'CANCELLED':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }

  String _getStatusLabel(String status) {
    // Convertir le status en format plus lisible
    return status.substring(0, 1).toUpperCase() +
        status.substring(1).toLowerCase();
  }
}
