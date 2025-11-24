import 'package:flutter/material.dart';
import 'package:admin/constants.dart';
import 'package:admin/models/client_manager.dart';
import 'package:admin/widgets/shared/glass_container.dart';

/// Card affichant les top clients d'un agent
class TopClientsCard extends StatelessWidget {
  final List<TopClient> topClients;
  final bool isDark;
  final VoidCallback? onViewAll;

  const TopClientsCard({
    Key? key,
    required this.topClients,
    required this.isDark,
    this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (topClients.isEmpty) {
      return SizedBox.shrink();
    }

    return GlassContainer(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          SizedBox(height: AppSpacing.md),

          // Liste des top clients
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topClients.length > 5 ? 5 : topClients.length,
            separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final client = topClients[index];
              return _buildTopClientItem(client, index + 1);
            },
          ),

          // Voir tous les top clients
          if (topClients.length > 5) ...[
            SizedBox(height: AppSpacing.md),
            _buildViewAllButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.2),
                borderRadius: AppRadius.radiusMD,
              ),
              child: Icon(
                Icons.trending_up_outlined,
                color: AppColors.success,
                size: 20,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Clients',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Meilleurs clients par revenu',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.2),
            borderRadius: AppRadius.radiusSM,
          ),
          child: Text(
            '${topClients.length}',
            style: AppTextStyles.bodyBold.copyWith(
              color: AppColors.success,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopClientItem(TopClient client, int rank) {
    final rankColor = _getRankColor(rank);
    final rankIcon = _getRankIcon(rank);

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.gray900.withOpacity(0.5)
            : AppColors.gray50.withOpacity(0.5),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: rankColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Rang
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.2),
              borderRadius: AppRadius.radiusMD,
            ),
            child: Center(
              child: Icon(rankIcon, color: rankColor, size: 18),
            ),
          ),
          SizedBox(width: AppSpacing.md),

          // Infos client
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name,
                  style: AppTextStyles.bodyBold.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 12,
                      color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      '${client.totalOrders} commandes',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Revenu
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.2),
              borderRadius: AppRadius.radiusSM,
            ),
            child: Text(
              '${(client.totalSpent / 1000).toStringAsFixed(0)}k FCFA',
              style: AppTextStyles.bodySmall.copyWith(
                color: rankColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Or
      case 2:
        return const Color(0xFFC0C0C0); // Argent
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.primary;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events; // Trophée
      case 2:
        return Icons.star_half; // Demi-étoile
      case 3:
        return Icons.star_outline; // Étoile vide
      default:
        return Icons.trending_up;
    }
  }

  Widget _buildViewAllButton() {
    return Center(
      child: TextButton(
        onPressed: onViewAll,
        child: Text(
          'Voir tous les top clients',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
