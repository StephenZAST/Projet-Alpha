import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../providers/loyalty_provider.dart';
import '../../components/glass_components.dart';
import '../../core/models/loyalty.dart';

/// 📋 Écran Historique Fidélité - Alpha Client App
///
/// Historique complet des transactions de points avec filtres et détails

class LoyaltyHistoryScreen extends StatefulWidget {
  const LoyaltyHistoryScreen({Key? key}) : super(key: key);

  @override
  State<LoyaltyHistoryScreen> createState() => _LoyaltyHistoryScreenState();
}

class _LoyaltyHistoryScreenState extends State<LoyaltyHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoyaltyProvider>().loadTransactions(refresh: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<LoyaltyProvider>().loadTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          'Historique Points',
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
          tabs: const [
            Tab(text: 'Toutes'),
            Tab(text: 'Gagnés'),
            Tab(text: 'Utilisés'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildStatsHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionsList(null),
                _buildTransactionsList(PointTransactionType.earned),
                _buildTransactionsList(PointTransactionType.spent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📊 En-tête avec statistiques
  Widget _buildStatsHeader() {
    return Consumer<LoyaltyProvider>(
      builder: (context, provider, child) {
        final stats = provider.loyaltyStats;

        return Container(
          padding: AppSpacing.pagePadding,
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Points Actuels',
                  '${stats['currentPoints']}',
                  Icons.stars,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total Gagné',
                  '${stats['totalEarned']}',
                  Icons.trending_up,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Valeur',
                  '${provider.calculateDiscountForPoints(stats['currentPoints']).toInt()} FCFA',
                  Icons.account_balance_wallet,
                  AppColors.accent,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return GlassContainer(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 📋 Liste des transactions
  Widget _buildTransactionsList(PointTransactionType? typeFilter) {
    return Consumer<LoyaltyProvider>(
      builder: (context, provider, child) {
        List<PointTransaction> transactions;

        if (typeFilter == null) {
          transactions = provider.transactions;
        } else {
          transactions = provider.getTransactionsByType(typeFilter);
        }

        if (provider.isLoadingTransactions && transactions.isEmpty) {
          return _buildLoadingList();
        }

        if (transactions.isEmpty) {
          return _buildEmptyState(typeFilter);
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadTransactions(refresh: true),
          child: ListView.builder(
            controller: _scrollController,
            padding: AppSpacing.pagePadding,
            itemCount:
                transactions.length + (provider.hasMoreTransactions ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= transactions.length) {
                return _buildLoadingIndicator();
              }

              final transaction = transactions[index];
              return _buildTransactionCard(transaction);
            },
          ),
        );
      },
    );
  }

  /// 💰 Carte de transaction
  Widget _buildTransactionCard(PointTransaction transaction) {
    final isEarned = transaction.isEarned;
    final color = isEarned ? AppColors.success : AppColors.warning;
    final icon = isEarned ? Icons.add_circle : Icons.remove_circle;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        onTap: () => _showTransactionDetails(transaction),
        child: Row(
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          transaction.description,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textPrimary(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        transaction.displayPoints,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getSourceColor(transaction.source)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          transaction.sourceText,
                          style: AppTextStyles.overline.copyWith(
                            color: _getSourceColor(transaction.source),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
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
          ],
        ),
      ),
    );
  }

  /// 🔄 Indicateur de chargement
  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  /// 💀 Liste de chargement skeleton
  Widget _buildLoadingList() {
    return ListView.builder(
      padding: AppSpacing.pagePadding,
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
            child: Row(
              children: [
                const SkeletonLoader(width: 48, height: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: SkeletonLoader(width: 120, height: 16),
                          ),
                          const SkeletonLoader(width: 60, height: 16),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const SkeletonLoader(width: 80, height: 12),
                          const Spacer(),
                          const SkeletonLoader(width: 60, height: 12),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 📭 État vide
  Widget _buildEmptyState(PointTransactionType? typeFilter) {
    String title;
    String subtitle;
    IconData icon;

    if (typeFilter == null) {
      title = 'Aucune transaction';
      subtitle = 'Vos transactions de points apparaîtront ici';
      icon = Icons.history;
    } else if (typeFilter == PointTransactionType.earned) {
      title = 'Aucun point gagné';
      subtitle = 'Passez des commandes pour gagner des points';
      icon = Icons.add_circle_outline;
    } else {
      title = 'Aucun point utilisé';
      subtitle = 'Utilisez vos points pour des récompenses';
      icon = Icons.remove_circle_outline;
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
            if (typeFilter == PointTransactionType.earned) ...[
              const SizedBox(height: 24),
              PremiumButton(
                text: 'Passer une commande',
                icon: Icons.add_shopping_cart,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 📄 Détails de transaction
  void _showTransactionDetails(PointTransaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TransactionDetailsSheet(transaction: transaction),
    );
  }

  // Utilitaires
  Color _getSourceColor(PointSource source) {
    switch (source) {
      case PointSource.order:
        return AppColors.primary;
      case PointSource.referral:
        return AppColors.accent;
      case PointSource.bonus:
        return AppColors.accent;
      case PointSource.reward:
        return AppColors.warning;
      case PointSource.admin:
        return AppColors.info;
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
      return '${difference.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// 📄 Sheet des détails de transaction
class _TransactionDetailsSheet extends StatelessWidget {
  final PointTransaction transaction;

  const _TransactionDetailsSheet({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isEarned = transaction.isEarned;
    final color = isEarned ? AppColors.success : AppColors.warning;

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
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isEarned ? Icons.add_circle : Icons.remove_circle,
                        color: color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.typeText,
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
                              color: _getSourceColor(transaction.source)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              transaction.sourceText,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: _getSourceColor(transaction.source),
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

                // Points
                _buildDetailRow(
                  context,
                  'Points',
                  transaction.displayPoints,
                  valueColor: color,
                  isAmount: true,
                ),

                const SizedBox(height: 16),

                // Description
                _buildDetailRow(
                  context,
                  'Description',
                  transaction.description,
                ),

                const SizedBox(height: 16),

                // Date
                _buildDetailRow(
                  context,
                  'Date',
                  _formatFullDate(transaction.createdAt),
                ),

                const SizedBox(height: 16),

                // ID Transaction
                _buildDetailRow(
                  context,
                  'ID Transaction',
                  transaction.id.substring(0, 8).toUpperCase(),
                ),

                if (transaction.referenceId != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    'Référence',
                    transaction.referenceId!.substring(0, 8).toUpperCase(),
                  ),
                ],

                const SizedBox(height: 32),

                // Bouton fermer
                SizedBox(
                  width: double.infinity,
                  child: PremiumButton(
                    text: 'Fermer',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
    bool isAmount = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            style:
                (isAmount ? AppTextStyles.labelLarge : AppTextStyles.bodyMedium)
                    .copyWith(
              color: valueColor ?? AppColors.textPrimary(context),
              fontWeight: isAmount ? FontWeight.w700 : FontWeight.w500,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Color _getSourceColor(PointSource source) {
    switch (source) {
      case PointSource.order:
        return AppColors.primary;
      case PointSource.referral:
        return AppColors.accent;
      case PointSource.bonus:
        return AppColors.accent;
      case PointSource.reward:
        return AppColors.warning;
      case PointSource.admin:
        return AppColors.info;
    }
  }

  String _formatFullDate(DateTime date) {
    const months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Jun',
      'Jul',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
