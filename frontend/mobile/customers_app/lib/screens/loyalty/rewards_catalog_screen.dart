import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../providers/loyalty_provider.dart';
import '../../components/glass_components.dart';
import '../../core/models/loyalty.dart';

/// 🎁 Écran Catalogue Récompenses - Alpha Client App
///
/// Catalogue complet des récompenses avec filtres par catégorie et réclamation

class RewardsCatalogScreen extends StatefulWidget {
  const RewardsCatalogScreen({Key? key}) : super(key: key);

  @override
  State<RewardsCatalogScreen> createState() => _RewardsCatalogScreenState();
}

class _RewardsCatalogScreenState extends State<RewardsCatalogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  RewardType? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoyaltyProvider>().loadRewards();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          'Récompenses',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary(context),
          indicatorColor: AppColors.primary,
          isScrollable: true,
          onTap: (index) => _onTabChanged(index),
          tabs: const [
            Tab(text: 'Toutes'),
            Tab(text: 'Réductions'),
            Tab(text: 'Services'),
            Tab(text: 'Cadeaux'),
            Tab(text: 'Bons'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildPointsHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRewardsList(null),
                _buildRewardsList(RewardType.discount),
                _buildRewardsList(RewardType.freeService),
                _buildRewardsList(RewardType.gift),
                _buildRewardsList(RewardType.voucher),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 💰 En-tête avec points disponibles
  Widget _buildPointsHeader() {
    return Consumer<LoyaltyProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: AppSpacing.pagePadding,
          child: GlassContainer(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.stars,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mes Points Disponibles',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${provider.currentPoints}',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '≈ ${provider.calculateDiscountForPoints(provider.currentPoints).toInt()} FCFA',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 🎁 Liste des récompenses
  Widget _buildRewardsList(RewardType? categoryFilter) {
    return Consumer<LoyaltyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingRewards) {
          return _buildLoadingList();
        }

        if (provider.rewardsError != null) {
          return _buildErrorState(provider.rewardsError!);
        }

        List<Reward> rewards;
        if (categoryFilter == null) {
          rewards = provider.rewards;
        } else {
          rewards = provider.rewards
              .where((reward) => reward.type == categoryFilter)
              .toList();
        }

        if (rewards.isEmpty) {
          return _buildEmptyState(categoryFilter);
        }

        return RefreshIndicator(
          onRefresh: provider.loadRewards,
          child: ListView.builder(
            padding: AppSpacing.pagePadding,
            itemCount: rewards.length,
            itemBuilder: (context, index) {
              final reward = rewards[index];
              return _buildRewardCard(reward, provider);
            },
          ),
        );
      },
    );
  }

  /// 🎁 Carte de récompense
  Widget _buildRewardCard(Reward reward, LoyaltyProvider provider) {
    final canClaim = provider.currentPoints >= reward.pointsRequired;
    final isExpired = reward.isExpired;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        onTap: () => _showRewardDetails(reward, provider),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec icône et type
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getRewardTypeColor(reward.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getRewardTypeIcon(reward.type),
                    color: _getRewardTypeColor(reward.type),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reward.name,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _getRewardTypeColor(reward.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          reward.typeText,
                          style: AppTextStyles.overline.copyWith(
                            color: _getRewardTypeColor(reward.type),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: canClaim
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: canClaim
                              ? AppColors.success.withOpacity(0.3)
                              : AppColors.warning.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '${reward.pointsRequired} pts',
                        style: AppTextStyles.labelSmall.copyWith(
                          color:
                              canClaim ? AppColors.success : AppColors.warning,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              reward.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 16),

            // Pied avec statut et action
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (reward.validUntil != null) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: isExpired
                                  ? AppColors.error
                                  : AppColors.textTertiary(context),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isExpired
                                  ? 'Expiré'
                                  : 'Expire le ${_formatDate(reward.validUntil!)}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isExpired
                                    ? AppColors.error
                                    : AppColors.textTertiary(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],

                      // Indicateur de disponibilité
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: canClaim && !isExpired
                                  ? AppColors.success
                                  : AppColors.warning,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            canClaim && !isExpired
                                ? 'Disponible'
                                : canClaim && isExpired
                                    ? 'Expiré'
                                    : 'Points insuffisants',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: canClaim && !isExpired
                                  ? AppColors.success
                                  : AppColors.warning,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (canClaim && !isExpired) ...[
                  PremiumButton(
                    text: 'Réclamer',
                    isLoading: provider.isUsingPoints,
                    onPressed: () => _claimReward(reward, provider),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isExpired ? 'Expiré' : 'Indisponible',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textTertiary(context),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 💀 Liste de chargement skeleton
  Widget _buildLoadingList() {
    return ListView.builder(
      padding: AppSpacing.pagePadding,
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: GlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SkeletonLoader(width: 56, height: 56),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SkeletonLoader(width: 120, height: 16),
                          const SizedBox(height: 8),
                          const SkeletonLoader(width: 80, height: 12),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SkeletonLoader(width: 60, height: 24),
                        const SizedBox(height: 4),
                        const SkeletonLoader(width: 40, height: 12),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const SkeletonLoader(width: double.infinity, height: 16),
                const SizedBox(height: 4),
                const SkeletonLoader(width: 200, height: 16),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SkeletonLoader(width: 100, height: 12),
                          const SizedBox(height: 4),
                          const SkeletonLoader(width: 80, height: 12),
                        ],
                      ),
                    ),
                    const SkeletonLoader(width: 80, height: 32),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ❌ État d'erreur
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PremiumButton(
              text: 'Réessayer',
              onPressed: () => context.read<LoyaltyProvider>().loadRewards(),
            ),
          ],
        ),
      ),
    );
  }

  /// 📭 État vide
  Widget _buildEmptyState(RewardType? categoryFilter) {
    String title;
    String subtitle;
    IconData icon;

    if (categoryFilter == null) {
      title = 'Aucune récompense';
      subtitle = 'Les récompenses apparaîtront ici';
      icon = Icons.card_giftcard_outlined;
    } else {
      title = 'Aucune récompense dans cette catégorie';
      subtitle = 'Essayez une autre catégorie';
      icon = _getRewardTypeIcon(categoryFilter);
    }

    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textTertiary(context),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Actions
  void _onTabChanged(int index) {
    switch (index) {
      case 0:
        _selectedCategory = null;
        break;
      case 1:
        _selectedCategory = RewardType.discount;
        break;
      case 2:
        _selectedCategory = RewardType.freeService;
        break;
      case 3:
        _selectedCategory = RewardType.gift;
        break;
      case 4:
        _selectedCategory = RewardType.voucher;
        break;
    }
  }

  void _showRewardDetails(Reward reward, LoyaltyProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RewardDetailsSheet(
        reward: reward,
        provider: provider,
      ),
    );
  }

  void _claimReward(Reward reward, LoyaltyProvider provider) async {
    final success = await provider.claimReward(reward.id);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Récompense "${reward.name}" réclamée avec succès !'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(provider.usePointsError ?? 'Erreur lors de la réclamation'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Utilitaires
  IconData _getRewardTypeIcon(RewardType type) {
    switch (type) {
      case RewardType.discount:
        return Icons.percent;
      case RewardType.freeService:
        return Icons.cleaning_services;
      case RewardType.gift:
        return Icons.card_giftcard;
      case RewardType.voucher:
        return Icons.local_offer;
    }
  }

  Color _getRewardTypeColor(RewardType type) {
    switch (type) {
      case RewardType.discount:
        return AppColors.success;
      case RewardType.freeService:
        return AppColors.primary;
      case RewardType.gift:
        return AppColors.primary;
      case RewardType.voucher:
        return AppColors.accent;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// 📄 Sheet des détails de récompense
class _RewardDetailsSheet extends StatelessWidget {
  final Reward reward;
  final LoyaltyProvider provider;

  const _RewardDetailsSheet({
    Key? key,
    required this.reward,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canClaim =
        provider.currentPoints >= reward.pointsRequired && !reward.isExpired;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.textTertiary(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color:
                            _getRewardTypeColor(reward.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _getRewardTypeIcon(reward.type),
                        color: _getRewardTypeColor(reward.type),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reward.name,
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: AppColors.textPrimary(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getRewardTypeColor(reward.type)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              reward.typeText,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: _getRewardTypeColor(reward.type),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Description
                Text(
                  'Description',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  reward.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),

                const SizedBox(height: 24),

                // Détails
                _buildDetailRow(
                    context, 'Points requis', '${reward.pointsRequired}'),
                _buildDetailRow(context, 'Valeur', reward.valueText),
                if (reward.validUntil != null)
                  _buildDetailRow(
                    context,
                    'Valide jusqu\'au',
                    _formatDate(reward.validUntil!),
                  ),

                const SizedBox(height: 24),

                // Statut
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: canClaim
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: canClaim
                          ? AppColors.success.withOpacity(0.3)
                          : AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        canClaim ? Icons.check_circle : Icons.warning,
                        color: canClaim ? AppColors.success : AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          canClaim
                              ? 'Vous pouvez réclamer cette récompense'
                              : reward.isExpired
                                  ? 'Cette récompense a expiré'
                                  : 'Points insuffisants (${reward.pointsRequired - provider.currentPoints} manquants)',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: canClaim
                                ? AppColors.success
                                : AppColors.warning,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: PremiumButton(
                        text: 'Fermer',
                        isOutlined: true,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PremiumButton(
                        text: 'Réclamer',
                        isLoading: provider.isUsingPoints,
                        onPressed:
                            canClaim ? () => _claimReward(context) : null,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _claimReward(BuildContext context) async {
    Navigator.pop(context); // Fermer le sheet

    final success = await provider.claimReward(reward.id);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Récompense "${reward.name}" réclamée avec succès !'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(provider.usePointsError ?? 'Erreur lors de la réclamation'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  IconData _getRewardTypeIcon(RewardType type) {
    switch (type) {
      case RewardType.discount:
        return Icons.percent;
      case RewardType.freeService:
        return Icons.cleaning_services;
      case RewardType.gift:
        return Icons.card_giftcard;
      case RewardType.voucher:
        return Icons.local_offer;
    }
  }

  Color _getRewardTypeColor(RewardType type) {
    switch (type) {
      case RewardType.discount:
        return AppColors.success;
      case RewardType.freeService:
        return AppColors.primary;
      case RewardType.gift:
        return AppColors.primary;
      case RewardType.voucher:
        return AppColors.accent;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
