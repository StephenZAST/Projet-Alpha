import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../providers/loyalty_provider.dart';
import '../../components/glass_components.dart';
import '../../core/models/loyalty.dart';
import 'loyalty_history_screen.dart';
import 'rewards_catalog_screen.dart';

/// 🎁 Écran Dashboard Fidélité - Alpha Client App
///
/// Dashboard principal du programme de fidélité avec points, récompenses et historique

class LoyaltyDashboardScreen extends StatefulWidget {
  const LoyaltyDashboardScreen({Key? key}) : super(key: key);

  @override
  State<LoyaltyDashboardScreen> createState() => _LoyaltyDashboardScreenState();
}

class _LoyaltyDashboardScreenState extends State<LoyaltyDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoyaltyProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: RefreshIndicator(
        onRefresh: () => context.read<LoyaltyProvider>().refreshAll(),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverPadding(
              padding: AppSpacing.pagePadding,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildPointsCard(context),
                  const SizedBox(height: 24),
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  _buildRecentTransactions(context),
                  const SizedBox(height: 24),
                  _buildAvailableRewards(context),
                  const SizedBox(height: 100), // Bottom padding
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📱 AppBar avec gradient
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      title: Text(
        'Programme Fidélit��',
        style: AppTextStyles.headlineSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showLoyaltyInfo(context),
          icon: const Icon(
            Icons.info_outline,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  /// 💰 Carte des points
  Widget _buildPointsCard(BuildContext context) {
    return Consumer<LoyaltyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingPoints) {
          return _buildPointsCardSkeleton();
        }

        final points = provider.loyaltyPoints;
        if (points == null) {
          return _buildPointsCardError(provider.pointsError);
        }

        return GlassContainer(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.stars,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mes Points',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${points.pointsBalance}',
                          style: AppTextStyles.display.copyWith(
                            color: AppColors.textPrimary(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: AppRadius.radiusMD,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Gagné',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            '${points.totalEarned} points',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '≈ ${provider.calculateDiscountForPoints(points.pointsBalance).toInt()} FCFA',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ⚡ Actions rapides
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions Rapides',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Récompenses',
                'Découvrir',
                Icons.card_giftcard,
                AppColors.accent,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RewardsCatalogScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Historique',
                'Consulter',
                Icons.history,
                AppColors.accent,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoyaltyHistoryScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GlassContainer(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  /// 📋 Transactions récentes
  Widget _buildRecentTransactions(BuildContext context) {
    return Consumer<LoyaltyProvider>(
      builder: (context, provider, child) {
        final recentTransactions = provider.transactions.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Activité Récente',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoyaltyHistoryScreen(),
                    ),
                  ),
                  child: Text(
                    'Voir tout',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (provider.isLoadingTransactions)
              _buildTransactionsSkeleton()
            else if (recentTransactions.isEmpty)
              _buildEmptyTransactions()
            else
              ...recentTransactions
                  .map((transaction) => _buildTransactionCard(transaction))
                  .toList(),
          ],
        );
      },
    );
  }

  Widget _buildTransactionCard(PointTransaction transaction) {
    final isEarned = transaction.isEarned;
    final color = isEarned ? AppColors.success : AppColors.warning;
    final icon = isEarned ? Icons.add_circle : Icons.remove_circle;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassContainer(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.sourceText,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  transaction.displayPoints,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(transaction.createdAt),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🎁 Récompenses disponibles
  Widget _buildAvailableRewards(BuildContext context) {
    return Consumer<LoyaltyProvider>(
      builder: (context, provider, child) {
        final availableRewards = provider.availableRewards.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Récompenses Disponibles',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RewardsCatalogScreen(),
                    ),
                  ),
                  child: Text(
                    'Voir tout',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (provider.isLoadingRewards)
              _buildRewardsSkeleton()
            else if (availableRewards.isEmpty)
              _buildEmptyRewards()
            else
              ...availableRewards
                  .map((reward) => _buildRewardCard(reward, provider))
                  .toList(),
          ],
        );
      },
    );
  }

  Widget _buildRewardCard(Reward reward, LoyaltyProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassContainer(
        onTap: () => _showRewardDetails(context, reward, provider),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getRewardIcon(reward.type),
                color: AppColors.accent,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.name,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reward.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${reward.pointsRequired} pts',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reward.valueText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Skeletons et états vides
  Widget _buildPointsCardSkeleton() {
    return GlassContainer(
      child: Column(
        children: [
          Row(
            children: [
              const SkeletonLoader(width: 60, height: 60),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonLoader(width: 80, height: 16),
                    const SizedBox(height: 8),
                    const SkeletonLoader(width: 120, height: 32),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const SkeletonLoader(width: double.infinity, height: 60),
        ],
      ),
    );
  }

  Widget _buildPointsCardError(String? error) {
    return GlassContainer(
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionsSkeleton() {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: GlassContainer(
            child: Row(
              children: [
                const SkeletonLoader(width: 40, height: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonLoader(width: 120, height: 16),
                      const SizedBox(height: 4),
                      const SkeletonLoader(width: 80, height: 12),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SkeletonLoader(width: 60, height: 16),
                    const SizedBox(height: 4),
                    const SkeletonLoader(width: 40, height: 12),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardsSkeleton() {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: GlassContainer(
            child: Row(
              children: [
                const SkeletonLoader(width: 48, height: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonLoader(width: 100, height: 16),
                      const SizedBox(height: 4),
                      const SkeletonLoader(width: 150, height: 12),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SkeletonLoader(width: 60, height: 20),
                    const SizedBox(height: 4),
                    const SkeletonLoader(width: 40, height: 12),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return GlassContainer(
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: AppColors.textTertiary(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune activité',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          Text(
            'Vos transactions apparaîtront ici',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRewards() {
    return GlassContainer(
      child: Column(
        children: [
          Icon(
            Icons.card_giftcard_outlined,
            size: 48,
            color: AppColors.textTertiary(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune récompense disponible',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          Text(
            'Gagnez plus de points pour débloquer des récompenses',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Utilitaires
  IconData _getRewardIcon(RewardType type) {
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  void _showLoyaltyInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusLG,
        ),
        title: Text(
          'Programme Fidélité',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comment ça marche ?',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoItem('🛍️', 'Gagnez 1 point par FCFA dépensé'),
            _buildInfoItem('🎁', 'Échangez vos points contre des récompenses'),
            _buildInfoItem('💰', '1 point = 0.1 FCFA de réduction'),
            _buildInfoItem('⭐', 'Plus vous commandez, plus vous gagnez'),
          ],
        ),
        actions: [
          PremiumButton(
            text: 'Compris',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRewardDetails(
      BuildContext context, Reward reward, LoyaltyProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusLG,
        ),
        title: Text(
          reward.name,
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reward.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Points requis: ',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                Text(
                  '${reward.pointsRequired}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Valeur: ',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                Text(
                  reward.valueText,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fermer',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          PremiumButton(
            text: 'Réclamer',
            isLoading: provider.isUsingPoints,
            onPressed: provider.currentPoints >= reward.pointsRequired
                ? () => _claimReward(context, reward, provider)
                : null,
          ),
        ],
      ),
    );
  }

  void _claimReward(
      BuildContext context, Reward reward, LoyaltyProvider provider) async {
    Navigator.pop(context); // Fermer le dialog

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
}
