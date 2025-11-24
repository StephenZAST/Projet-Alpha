import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin/constants.dart';
import 'package:admin/models/client_manager.dart';
import 'package:admin/widgets/shared/glass_container.dart';
import 'package:admin/widgets/shared/glass_button.dart';

/// Dialog affichant le dashboard détaillé d'un agent
class AgentDashboardDialog extends StatelessWidget {
  final AgentDashboard dashboard;
  final bool isLoading;

  const AgentDashboardDialog({
    Key? key,
    required this.dashboard,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(AppSpacing.lg),
      child: GlassContainer(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec titre et bouton fermer
              _buildHeader(context, isDark),
              SizedBox(height: AppSpacing.lg),

              if (isLoading)
                Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              else ...[
                // Informations de l'agent
                _buildAgentInfo(isDark),
                SizedBox(height: AppSpacing.lg),

                // Statistiques principales
                _buildStatsSection(isDark),
                SizedBox(height: AppSpacing.lg),

                // Clients inactifs
                if (dashboard.inactiveClients.isNotEmpty)
                  _buildInactiveClientsSection(isDark),
                if (dashboard.inactiveClients.isNotEmpty)
                  SizedBox(height: AppSpacing.lg),

                // Top clients
                if (dashboard.topClients.isNotEmpty)
                  _buildTopClientsSection(isDark),
              ],

              SizedBox(height: AppSpacing.lg),

              // Boutons d'action
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // WIDGETS DE CONSTRUCTION
  // ============================================

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard Agent',
              style: AppTextStyles.h2.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              dashboard.agent.name,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(
            Icons.close,
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildAgentInfo(bool isDark) {
    return GlassContainer(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations Agent',
            style: AppTextStyles.h4.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          _buildInfoRow('Nom', dashboard.agent.name, isDark),
          SizedBox(height: AppSpacing.sm),
          _buildInfoRow('Email', dashboard.agent.email, isDark),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.gray300 : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyBold.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(bool isDark) {
    return GlassContainer(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiques',
            style: AppTextStyles.h4.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            children: [
              _buildStatTile(
                'Clients',
                '${dashboard.stats.totalClients}',
                Icons.people_outline,
                AppColors.primary,
                isDark,
              ),
              _buildStatTile(
                'Commandes',
                '${dashboard.stats.totalOrders}',
                Icons.shopping_cart_outlined,
                AppColors.accent,
                isDark,
              ),
              _buildStatTile(
                'Revenus',
                '${(dashboard.stats.totalRevenue / 1000).toStringAsFixed(0)}k FCFA',
                Icons.trending_up_outlined,
                AppColors.success,
                isDark,
              ),
              _buildStatTile(
                'Moy. Commande',
                '${dashboard.stats.avgOrderValue.toStringAsFixed(0)} FCFA',
                Icons.calculate_outlined,
                AppColors.warning,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.bodyBold.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInactiveClientsSection(bool isDark) {
    return GlassContainer(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Clients Inactifs (>7 jours)',
                style: AppTextStyles.h4.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
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
                  '${dashboard.inactiveClients.length}',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dashboard.inactiveClients.length,
            separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final client = dashboard.inactiveClients[index];
              return _buildClientListItem(client, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopClientsSection(bool isDark) {
    return GlassContainer(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Clients',
                style: AppTextStyles.h4.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
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
                  '${dashboard.topClients.length}',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dashboard.topClients.length,
            separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final client = dashboard.topClients[index];
              return _buildTopClientItem(client, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClientListItem(InactiveClient client, bool isDark) {
    return Container(
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
          Text(
            client.name,
            style: AppTextStyles.bodyBold.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            client.email,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Inactif depuis',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.gray300 : AppColors.textSecondary,
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
                  '${client.daysSinceLastOrder ?? 0} jours',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopClientItem(TopClient client, bool isDark) {
    return Container(
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
          Text(
            client.name,
            style: AppTextStyles.bodyBold.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            client.email,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${client.totalOrders} commandes',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                ),
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
                  '${(client.totalSpent / 1000).toStringAsFixed(0)}k FCFA',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GlassButton(
          label: 'Fermer',
          icon: Icons.close,
          variant: GlassButtonVariant.secondary,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
