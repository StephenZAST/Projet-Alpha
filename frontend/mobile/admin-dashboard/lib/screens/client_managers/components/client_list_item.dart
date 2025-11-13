import 'package:flutter/material.dart';
import 'package:admin/constants.dart';
import 'package:admin/models/client_manager.dart';

/// Widget affichant un client dans une liste
class ClientListItem extends StatelessWidget {
  final ClientInfo client;
  final VoidCallback? onTap;
  final bool isDark;

  const ClientListItem({
    Key? key,
    required this.client,
    this.onTap,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusMD,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.gray800.withOpacity(0.3)
                : Colors.white.withOpacity(0.5),
            borderRadius: AppRadius.radiusMD,
            border: Border.all(
              color: isDark
                  ? AppColors.gray700.withOpacity(0.3)
                  : AppColors.gray200.withOpacity(0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec nom et badge inactif
              _buildHeader(),
              SizedBox(height: AppSpacing.sm),

              // Email
              _buildEmailRow(),
              SizedBox(height: AppSpacing.sm),

              // Stats
              _buildStatsRow(),
              SizedBox(height: AppSpacing.sm),

              // Dernière commande
              _buildLastOrderRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            client.name,
            style: AppTextStyles.bodyBold.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        if (client.isInactive)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.2),
              borderRadius: AppRadius.radiusSM,
            ),
            child: Text(
              'Inactif',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmailRow() {
    return Row(
      children: [
        Icon(
          Icons.email_outlined,
          size: 16,
          color: isDark ? AppColors.gray300 : AppColors.textSecondary,
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            client.email,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatChip(
          '${client.totalOrders}',
          'Commandes',
          Icons.shopping_cart_outlined,
          AppColors.primary,
        ),
        _buildStatChip(
          '${(client.totalSpent / 1000).toStringAsFixed(0)}k',
          'Dépensé',
          Icons.trending_up_outlined,
          AppColors.success,
        ),
      ],
    );
  }

  Widget _buildStatChip(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: AppSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: color.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLastOrderRow() {
    final daysAgo = client.daysSinceLastOrder ?? 0;
    final lastOrderText = daysAgo == 0
        ? 'Aujourd\'hui'
        : daysAgo == 1
            ? 'Hier'
            : 'Il y a $daysAgo jours';

    return Row(
      children: [
        Icon(
          Icons.history_outlined,
          size: 16,
          color: isDark ? AppColors.gray300 : AppColors.textSecondary,
        ),
        SizedBox(width: AppSpacing.sm),
        Text(
          'Dernière commande : $lastOrderText',
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark ? AppColors.gray300 : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
