import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/loyalty_controller.dart';
import '../../models/loyalty.dart';
import '../../widgets/shared/glass_button.dart';
import '../../widgets/shared/glass_container.dart';
import '../../utils/date_utils.dart';
import 'components/loyalty_stats_grid.dart';
import 'components/loyalty_points_table.dart';
import 'components/loyalty_filters.dart';
import 'components/pending_claims_card.dart';
import 'components/rewards_management_dialog.dart';
import 'components/point_transaction_dialog.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({Key? key}) : super(key: key);

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen>
    with SingleTickerProviderStateMixin {
  late LoyaltyController controller;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    print('[LoyaltyScreen] initState: Initialisation');

    // Initialiser le TabController
    _tabController = TabController(length: 4, vsync: this);

    // S'assurer que le contrôleur existe et est unique
    if (Get.isRegistered<LoyaltyController>()) {
      controller = Get.find<LoyaltyController>();
    } else {
      controller = Get.put(LoyaltyController(), permanent: true);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.gray50,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDark),
              SizedBox(height: AppSpacing.lg),

              // Statistiques
              LoyaltyStatsGrid(),
              SizedBox(height: AppSpacing.lg),

              // Demandes de récompenses en attente (si il y en a)
              Obx(() {
                if (controller.pendingRewardClaims.isNotEmpty) {
                  return Column(
                    children: [
                      PendingClaimsCard(),
                      SizedBox(height: AppSpacing.lg),
                    ],
                  );
                }
                return SizedBox.shrink();
              }),

              // Onglets
              _buildTabBar(context, isDark),
              SizedBox(height: AppSpacing.md),

              // Contenu des onglets
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLoyaltyPointsTab(context, isDark),
                    _buildTransactionsTab(context, isDark),
                    _buildRewardsTab(context, isDark),
                    _buildClaimsTab(context, isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Système de Fidélité',
              style: AppTextStyles.h1.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Obx(() => Text(
                  controller.isLoading.value
                      ? 'Chargement...'
                      : '${controller.totalLoyaltyPoints.value} utilisateur${controller.totalLoyaltyPoints.value > 1 ? 's' : ''} avec des points',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                )),
          ],
        ),
        Row(
          children: [
            GlassButton(
              label: 'Ajouter Points',
              icon: Icons.add_circle_outline,
              variant: GlassButtonVariant.success,
              onPressed: () => _showAddPointsDialog(context),
            ),
            SizedBox(width: AppSpacing.sm),
            GlassButton(
              label: 'Récompenses',
              icon: Icons.card_giftcard_outlined,
              variant: GlassButtonVariant.info,
              onPressed: () => _showRewardsManagement(context),
            ),
            SizedBox(width: AppSpacing.sm),
            GlassButton(
              label: 'Actualiser',
              icon: Icons.refresh_outlined,
              variant: GlassButtonVariant.primary,
              size: GlassButtonSize.small,
              onPressed: () {
                print('[LoyaltyScreen] Bouton Actualiser cliqué');
                controller.refreshAll();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context, bool isDark) {
    return _glassCard(
      context,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary.withOpacity(0.12),
          borderRadius: AppRadius.radiusMD,
        ),
        labelColor: AppColors.primary,
        unselectedLabelColor:
            isDark ? AppColors.gray300 : AppColors.textSecondary,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.bodyMedium,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stars_outlined, size: 18),
                SizedBox(width: AppSpacing.xs),
                Text('Points'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.swap_horiz_outlined, size: 18),
                SizedBox(width: AppSpacing.xs),
                Text('Transactions'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.card_giftcard_outlined, size: 18),
                SizedBox(width: AppSpacing.xs),
                Text('Récompenses'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.redeem_outlined, size: 18),
                SizedBox(width: AppSpacing.xs),
                Text('Demandes'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyPointsTab(BuildContext context, bool isDark) {
    return Column(
      children: [
        // Filtres et recherche
        LoyaltyFilters(),
        SizedBox(height: AppSpacing.md),

        // Table des points de fidélité
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Chargement des points de fidélité...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (controller.filteredLoyaltyPoints.isEmpty) {
              return _buildEmptyState(
                context,
                isDark,
                'Aucun point de fidélité trouvé',
                'Aucun utilisateur n\'a encore de points de fidélité',
                Icons.stars_outlined,
              );
            }

            return LoyaltyPointsTable();
          }),
        ),

        // Pagination
        SizedBox(height: AppSpacing.md),
        _buildPagination(context, isDark),
      ],
    );
  }

  Widget _buildTransactionsTab(BuildContext context, bool isDark) {
    return Column(
      children: [
        // Filtres pour les transactions
        _buildTransactionFilters(context, isDark),
        SizedBox(height: AppSpacing.md),

        // Liste des transactions
        Expanded(
          child: Obx(() {
            if (controller.isLoadingTransactions.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Chargement des transactions...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (controller.filteredPointTransactions.isEmpty) {
              return _buildEmptyState(
                context,
                isDark,
                'Aucune transaction trouvée',
                'Aucune transaction de points n\'a été effectuée',
                Icons.swap_horiz_outlined,
              );
            }

            return _buildTransactionsList(context, isDark);
          }),
        ),
      ],
    );
  }

  Widget _buildRewardsTab(BuildContext context, bool isDark) {
    return Column(
      children: [
        // Filtres pour les récompenses
        _buildRewardFilters(context, isDark),
        SizedBox(height: AppSpacing.md),

        // Liste des récompenses
        Expanded(
          child: Obx(() {
            if (controller.isLoadingRewards.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Chargement des récompenses...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (controller.filteredRewards.isEmpty) {
              return _buildEmptyState(
                context,
                isDark,
                'Aucune récompense trouvée',
                'Aucune récompense n\'est disponible',
                Icons.card_giftcard_outlined,
              );
            }

            return _buildRewardsList(context, isDark);
          }),
        ),
      ],
    );
  }

  Widget _buildClaimsTab(BuildContext context, bool isDark) {
    return Column(
      children: [
        // Filtres pour les demandes
        _buildClaimFilters(context, isDark),
        SizedBox(height: AppSpacing.md),

        // Liste des demandes
        Expanded(
          child: Obx(() {
            if (controller.isLoadingClaims.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Chargement des demandes...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (controller.filteredRewardClaims.isEmpty) {
              return _buildEmptyState(
                context,
                isDark,
                'Aucune demande trouvée',
                'Aucune demande de récompense n\'a été effectuée',
                Icons.redeem_outlined,
              );
            }

            return _buildClaimsList(context, isDark);
          }),
        ),
      ],
    );
  }

  Widget _buildTransactionFilters(BuildContext context, bool isDark) {
    return _glassCard(
      context,
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => DropdownButtonFormField<PointTransactionType>(
                  value: controller.selectedTransactionType.value,
                  decoration: InputDecoration(
                    labelText: 'Type de transaction',
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.radiusSM,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text('Tous les types'),
                    ),
                    ...PointTransactionType.values
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Row(
                                children: [
                                  Icon(type.icon, size: 16, color: type.color),
                                  SizedBox(width: AppSpacing.xs),
                                  Text(type == PointTransactionType.EARNED
                                      ? 'Gagné'
                                      : 'Dépensé'),
                                ],
                              ),
                            )),
                  ],
                  onChanged: controller.filterTransactionsByType,
                )),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Obx(() => DropdownButtonFormField<PointSource>(
                  value: controller.selectedTransactionSource.value,
                  decoration: InputDecoration(
                    labelText: 'Source',
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.radiusSM,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text('Toutes les sources'),
                    ),
                    ...PointSource.values.map((source) => DropdownMenuItem(
                          value: source,
                          child: Row(
                            children: [
                              Icon(source.icon, size: 16, color: source.color),
                              SizedBox(width: AppSpacing.xs),
                              Text(source.name == 'ORDER'
                                  ? 'Commande'
                                  : source.name == 'REFERRAL'
                                      ? 'Parrainage'
                                      : 'Récompense'),
                            ],
                          ),
                        )),
                  ],
                  onChanged: controller.filterTransactionsBySource,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardFilters(BuildContext context, bool isDark) {
    return _glassCard(
      context,
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => DropdownButtonFormField<RewardType>(
                  value: controller.selectedRewardType.value,
                  decoration: InputDecoration(
                    labelText: 'Type de récompense',
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.radiusSM,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text('Tous les types'),
                    ),
                    ...RewardType.values.map((type) => DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Icon(type.icon, size: 16, color: type.color),
                              SizedBox(width: AppSpacing.xs),
                              Text(type.name == 'DISCOUNT'
                                  ? 'Remise'
                                  : type.name == 'FREE_DELIVERY'
                                      ? 'Livraison gratuite'
                                      : type.name == 'CASHBACK'
                                          ? 'Cashback'
                                          : 'Cadeau'),
                            ],
                          ),
                        )),
                  ],
                  onChanged: controller.filterRewardsByType,
                )),
          ),
          SizedBox(width: AppSpacing.md),
          Obx(() => GlassButton(
                label: controller.showActiveRewardsOnly.value
                    ? 'Actives seulement'
                    : 'Toutes',
                icon: controller.showActiveRewardsOnly.value
                    ? Icons.visibility
                    : Icons.visibility_off,
                variant: controller.showActiveRewardsOnly.value
                    ? GlassButtonVariant.success
                    : GlassButtonVariant.secondary,
                size: GlassButtonSize.small,
                onPressed: controller.toggleActiveRewardsOnly,
              )),
        ],
      ),
    );
  }

  Widget _buildClaimFilters(BuildContext context, bool isDark) {
    return _glassCard(
      context,
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => DropdownButtonFormField<RewardClaimStatus>(
                  value: controller.selectedClaimStatus.value,
                  decoration: InputDecoration(
                    labelText: 'Statut de la demande',
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.radiusSM,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text('Tous les statuts'),
                    ),
                    ...RewardClaimStatus.values
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Row(
                                children: [
                                  Icon(status.icon,
                                      size: 16, color: status.color),
                                  SizedBox(width: AppSpacing.xs),
                                  Text(status.name == 'PENDING'
                                      ? 'En attente'
                                      : status.name == 'APPROVED'
                                          ? 'Approuvée'
                                          : status.name == 'REJECTED'
                                              ? 'Rejetée'
                                              : 'Utilisée'),
                                ],
                              ),
                            )),
                  ],
                  onChanged: controller.filterClaimsByStatus,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context, bool isDark) {
    return _glassCard(
      context,
      padding: EdgeInsets.zero,
      child: Obx(() => ListView.builder(
            itemCount: controller.filteredPointTransactions.length,
            itemBuilder: (context, index) {
              final transaction = controller.filteredPointTransactions[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: transaction.type.color.withOpacity(0.1),
                    borderRadius: AppRadius.radiusSM,
                  ),
                  child: Icon(
                    transaction.type.icon,
                    color: transaction.type.color,
                    size: 20,
                  ),
                ),
                title: Text(
                  transaction.formattedPoints,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: transaction.type.color,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.user?.email ?? 'Utilisateur inconnu',
                      style: AppTextStyles.bodySmall,
                    ),
                    Text(
                      '${transaction.sourceLabel} • ${AppDateUtils.formatDateTime(transaction.createdAt)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                    ),
                  ],
                ),
                trailing: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: transaction.source.color.withOpacity(0.1),
                    borderRadius: AppRadius.radiusSM,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        transaction.source.icon,
                        size: 14,
                        color: transaction.source.color,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        transaction.sourceLabel,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: transaction.source.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )),
    );
  }

  Widget _buildRewardsList(BuildContext context, bool isDark) {
    return _glassCard(
      context,
      padding: EdgeInsets.zero,
      child: Obx(() => ListView.builder(
            itemCount: controller.filteredRewards.length,
            itemBuilder: (context, index) {
              final reward = controller.filteredRewards[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: reward.type.color.withOpacity(0.1),
                    borderRadius: AppRadius.radiusSM,
                  ),
                  child: Icon(
                    reward.type.icon,
                    color: reward.type.color,
                    size: 20,
                  ),
                ),
                title: Text(
                  reward.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.description,
                      style: AppTextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Text(
                          reward.formattedPointsCost,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (reward.formattedDiscountValue.isNotEmpty) ...[
                          Text(' • ', style: AppTextStyles.bodySmall),
                          Text(
                            reward.formattedDiscountValue,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: reward.isActive
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.error.withOpacity(0.1),
                        borderRadius: AppRadius.radiusSM,
                      ),
                      child: Text(
                        reward.isActive ? 'Active' : 'Inactive',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: reward.isActive
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      reward.availabilityText,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                    ),
                  ],
                ),
                onTap: () => controller.selectReward(reward),
              );
            },
          )),
    );
  }

  Widget _buildClaimsList(BuildContext context, bool isDark) {
    return _glassCard(
      context,
      padding: EdgeInsets.zero,
      child: Obx(() => ListView.builder(
            itemCount: controller.filteredRewardClaims.length,
            itemBuilder: (context, index) {
              final claim = controller.filteredRewardClaims[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: claim.status.color.withOpacity(0.1),
                    borderRadius: AppRadius.radiusSM,
                  ),
                  child: Icon(
                    claim.status.icon,
                    color: claim.status.color,
                    size: 20,
                  ),
                ),
                title: Text(
                  claim.reward?.name ?? 'Récompense inconnue',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      claim.user?.email ?? 'Utilisateur inconnu',
                      style: AppTextStyles.bodySmall,
                    ),
                    Text(
                      '${claim.formattedPointsUsed} • ${AppDateUtils.formatDateTime(claim.createdAt)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: claim.status.color.withOpacity(0.1),
                        borderRadius: AppRadius.radiusSM,
                      ),
                      child: Text(
                        claim.statusLabel,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: claim.status.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (claim.isPending) ...[
                      SizedBox(width: AppSpacing.sm),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert),
                        onSelected: (value) {
                          switch (value) {
                            case 'approve':
                              controller.approveRewardClaim(claim.id);
                              break;
                            case 'reject':
                              _showRejectClaimDialog(claim.id);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'approve',
                            child: Row(
                              children: [
                                Icon(Icons.check, color: AppColors.success),
                                SizedBox(width: AppSpacing.sm),
                                Text('Approuver'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'reject',
                            child: Row(
                              children: [
                                Icon(Icons.close, color: AppColors.error),
                                SizedBox(width: AppSpacing.sm),
                                Text('Rejeter'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          )),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isDark,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppRadius.radiusXL,
            ),
            child: Icon(
              icon,
              size: 60,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: AppTextStyles.h3.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(BuildContext context, bool isDark) {
    return Obx(() {
      if (controller.totalPages.value <= 1) return SizedBox.shrink();

      return _glassCard(
        context,
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Page ${controller.currentPage.value} sur ${controller.totalPages.value}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                GlassButton(
                  label: '',
                  icon: Icons.chevron_left,
                  variant: GlassButtonVariant.secondary,
                  size: GlassButtonSize.small,
                  onPressed: controller.currentPage.value > 1
                      ? controller.previousPage
                      : null,
                ),
                SizedBox(width: AppSpacing.sm),
                GlassButton(
                  label: '',
                  icon: Icons.chevron_right,
                  variant: GlassButtonVariant.secondary,
                  size: GlassButtonSize.small,
                  onPressed:
                      controller.currentPage.value < controller.totalPages.value
                          ? controller.nextPage
                          : null,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // Generic glass card wrapper to unify glassmorphism styles across the screen
  Widget _glassCard(BuildContext context,
      {required Widget child, EdgeInsets? padding}) {
    // Delegate to the centralized GlassContainer so all cards share the same
    // tokens (background, border, blur, shadows, etc.). This removes subtle
    // visual drift between screens.
    return GlassContainer(
      padding: padding,
      child: child,
    );
  }

  void _showAddPointsDialog(BuildContext context) {
    Get.dialog(
      PointTransactionDialog(
        onAddPoints: (userId, points, source, referenceId) {
          controller.addPointsToUser(userId, points, source, referenceId);
        },
        onDeductPoints: (userId, points, source, referenceId) {
          controller.deductPointsFromUser(userId, points, source, referenceId);
        },
      ),
    );
  }

  void _showRewardsManagement(BuildContext context) {
    Get.dialog(
      RewardsManagementDialog(
        rewards: controller.rewards,
        onCreateReward: (name, description, pointsCost, type, discountValue,
            discountType, maxRedemptions) {
          controller.createReward(
            name: name,
            description: description,
            pointsCost: pointsCost,
            type: type,
            discountValue: discountValue,
            discountType: discountType,
            maxRedemptions: maxRedemptions,
          );
        },
        onUpdateReward: (rewardId, name, description, pointsCost, type,
            discountValue, discountType, isActive, maxRedemptions) {
          controller.updateReward(
            rewardId,
            name: name,
            description: description,
            pointsCost: pointsCost,
            type: type,
            discountValue: discountValue,
            discountType: discountType,
            isActive: isActive,
            maxRedemptions: maxRedemptions,
          );
        },
        onDeleteReward: controller.deleteReward,
      ),
    );
  }

  void _showRejectClaimDialog(String claimId) {
    final reasonController = TextEditingController();

    Get.dialog(
      Dialog(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Rejeter la demande',
                style: AppTextStyles.h4,
              ),
              SizedBox(height: AppSpacing.lg),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: 'Raison du rejet',
                  hintText: 'Expliquez pourquoi cette demande est rejetée...',
                ),
                maxLines: 3,
              ),
              SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'Annuler',
                      variant: GlassButtonVariant.secondary,
                      onPressed: () => Get.back(),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GlassButton(
                      label: 'Rejeter',
                      variant: GlassButtonVariant.error,
                      onPressed: () {
                        if (reasonController.text.isNotEmpty) {
                          controller.rejectRewardClaim(
                              claimId, reasonController.text);
                          Get.back();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
