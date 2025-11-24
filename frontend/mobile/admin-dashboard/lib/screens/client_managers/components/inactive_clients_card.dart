import 'package:flutter/material.dart';
import 'package:admin/constants.dart';
import 'package:admin/models/client_manager.dart';
import 'package:admin/widgets/shared/glass_container.dart';

/// Card affichant les clients inactifs d'un agent
class InactiveClientsCard extends StatelessWidget {
  final List<InactiveClient> inactiveClients;
  final bool isDark;
  final VoidCallback? onViewAll;

  const InactiveClientsCard({
    Key? key,
    required this.inactiveClients,
    required this.isDark,
    this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (inactiveClients.isEmpty) {
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

          // Liste des clients inactifs
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: inactiveClients.length > 3 ? 3 : inactiveClients.length,
            separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final client = inactiveClients[index];
              return _buildInactiveClientItem(client);
            },
          ),

          // Voir tous les clients inactifs
          if (inactiveClients.length > 3) ...[
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
                color: AppColors.warning.withOpacity(0.2),
                borderRadius: AppRadius.radiusMD,
              ),
              child: Icon(
                Icons.warning_outlined,
                color: AppColors.warning,
                size: 20,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clients Inactifs',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Aucune commande depuis 7 jours',
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
            color: AppColors.warning.withOpacity(0.2),
            borderRadius: AppRadius.radiusSM,
          ),
          child: Text(
            '${inactiveClients.length}',
            style: AppTextStyles.bodyBold.copyWith(
              color: AppColors.warning,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInactiveClientItem(InactiveClient client) {
    final daysAgo = client.daysSinceLastOrder ?? 0;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.gray900.withOpacity(0.5)
            : AppColors.gray50.withOpacity(0.5),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: AppColors.warning.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nom et badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  '$daysAgo j',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),

          // Email
          Row(
            children: [
              Icon(
                Icons.email_outlined,
                size: 14,
                color: isDark ? AppColors.gray300 : AppColors.textSecondary,
              ),
              SizedBox(width: AppSpacing.xs),
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
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllButton() {
    return Center(
      child: TextButton(
        onPressed: onViewAll,
        child: Text(
          'Voir tous les clients inactifs',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
