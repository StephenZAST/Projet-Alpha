import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin/constants.dart';
import 'package:admin/models/client_manager.dart';
import 'package:admin/models/paginated_response.dart';
import 'package:admin/widgets/shared/glass_container.dart';
import 'package:admin/widgets/shared/glass_button.dart';
import 'package:admin/services/client_manager_service.dart';

/// Dialog affichant les clients d'un agent
class AgentClientsListDialog extends StatefulWidget {
  final AgentStats agent;
  final VoidCallback onRefresh;

  const AgentClientsListDialog({
    Key? key,
    required this.agent,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<AgentClientsListDialog> createState() => _AgentClientsListDialogState();
}

class _AgentClientsListDialogState extends State<AgentClientsListDialog> {
  late Future<PaginatedResponse<ClientInfo>> clientsFuture;
  int currentPage = 1;
  final int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  void _loadClients() {
    setState(() {
      clientsFuture = ClientManagerService.getAgentClients(
        widget.agent.id,
        page: currentPage,
        limit: itemsPerPage,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(AppSpacing.lg),
      child: GlassContainer(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clients de ${widget.agent.name}',
                      style: AppTextStyles.h3.copyWith(
                        color: isDark ? AppColors.textLight : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      '${widget.agent.totalClients} clients assignés',
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
            ),
            SizedBox(height: AppSpacing.lg),

            // Contenu
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              width: MediaQuery.of(context).size.width * 0.8,
              child: FutureBuilder<PaginatedResponse<ClientInfo>>(
                future: clientsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.error,
                          ),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            'Erreur de chargement',
                            style: AppTextStyles.bodyBold.copyWith(
                              color: isDark ? AppColors.textLight : AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            snapshot.error.toString(),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppSpacing.lg),
                          GlassButton(
                            label: 'Réessayer',
                            icon: Icons.refresh_outlined,
                            variant: GlassButtonVariant.primary,
                            onPressed: _loadClients,
                          ),
                        ],
                      ),
                    );
                  }

                  final response = snapshot.data;
                  if (response == null || response.items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 48,
                            color: AppColors.primary.withOpacity(0.5),
                          ),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            'Aucun client assigné',
                            style: AppTextStyles.bodyBold.copyWith(
                              color: isDark ? AppColors.textLight : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Liste des clients
                      Expanded(
                        child: ListView.separated(
                          itemCount: response.items.length,
                          separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final client = response.items[index];
                            return _buildClientTile(client, isDark);
                          },
                        ),
                      ),

                      // Pagination
                      if (response.totalPages > 1) ...[
                        SizedBox(height: AppSpacing.lg),
                        _buildPaginationControls(response, isDark),
                      ],
                    ],
                  );
                },
              ),
            ),

            SizedBox(height: AppSpacing.lg),

            // Bouton fermer
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GlassButton(
                  label: 'Fermer',
                  icon: Icons.close,
                  variant: GlassButtonVariant.secondary,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientTile(ClientInfo client, bool isDark) {
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
          // Nom et badge inactif
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
          ),
          SizedBox(height: AppSpacing.sm),

          // Email et téléphone
          Row(
            children: [
              Icon(Icons.email_outlined, size: 14, color: AppColors.primary),
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
          if (client.phone != null) ...[
            SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 14, color: AppColors.primary),
                SizedBox(width: AppSpacing.xs),
                Text(
                  client.phone!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: AppSpacing.sm),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatBadge(
                '${client.totalOrders}',
                'Commandes',
                Icons.shopping_cart_outlined,
                AppColors.primary,
              ),
              _buildStatBadge(
                '${(client.totalSpent / 1000).toStringAsFixed(0)}k FCFA',
                'Dépensé',
                Icons.trending_up_outlined,
                AppColors.success,
              ),
              if (client.daysSinceLastOrder != null)
                _buildStatBadge(
                  '${client.daysSinceLastOrder} j',
                  'Inactif',
                  Icons.history_outlined,
                  AppColors.warning,
                ),
            ],
          ),

          // Notes
          if (client.notes != null && client.notes!.isNotEmpty) ...[
            SizedBox(height: AppSpacing.sm),
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: AppRadius.radiusSM,
              ),
              child: Text(
                'Note: ${client.notes}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatBadge(
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
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
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

  Widget _buildPaginationControls(
    PaginatedResponse<ClientInfo> response,
    bool isDark,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GlassButton(
          label: '',
          icon: Icons.chevron_left,
          variant: GlassButtonVariant.secondary,
          size: GlassButtonSize.small,
          onPressed: currentPage > 1
              ? () {
                  setState(() => currentPage--);
                  _loadClients();
                }
              : null,
        ),
        SizedBox(width: AppSpacing.sm),
        Text(
          'Page $currentPage/${response.totalPages}',
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        GlassButton(
          label: '',
          icon: Icons.chevron_right,
          variant: GlassButtonVariant.secondary,
          size: GlassButtonSize.small,
          onPressed: currentPage < response.totalPages
              ? () {
                  setState(() => currentPage++);
                  _loadClients();
                }
              : null,
        ),
      ],
    );
  }
}
