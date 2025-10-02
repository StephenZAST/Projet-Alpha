import 'package:affiliate_app/models/affiliate_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/affiliate_provider.dart';
import '../widgets/glass_container.dart';

/// 💰 Écran Commissions - Alpha Affiliate App
///
/// Affichage de l'historique des commissions avec filtres et pagination

class CommissionsScreen extends StatefulWidget {
  const CommissionsScreen({Key? key}) : super(key: key);

  @override
  State<CommissionsScreen> createState() => _CommissionsScreenState();
}

class _CommissionsScreenState extends State<CommissionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AffiliateProvider>().loadCommissions(refresh: true);
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
      context.read<AffiliateProvider>().loadMoreCommissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Mes Commissions',
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
            Tab(text: 'Commissions'),
            Tab(text: 'Retraits'),
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
                _buildTransactionsList(showAll: true),
                _buildTransactionsList(commissionsOnly: true),
                _buildTransactionsList(withdrawalsOnly: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📊 En-tête avec statistiques
  Widget _buildStatsHeader() {
    return Consumer<AffiliateProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: AppSpacing.pagePadding,
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Gains Totaux',
                  '${provider.totalEarnings.toFormattedString()} FCFA',
                  Icons.trending_up,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Solde Disponible',
                  '${provider.availableBalance.toFormattedString()} FCFA',
                  Icons.account_balance_wallet,
                  AppColors.success,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// 📋 Liste des transactions
  Widget _buildTransactionsList({
    bool showAll = false,
    bool commissionsOnly = false,
    bool withdrawalsOnly = false,
  }) {
    return Consumer<AffiliateProvider>(
      builder: (context, provider, child) {
        List<CommissionTransaction> transactions;

        if (commissionsOnly) {
          transactions = provider.getCommissionsByType(withdrawalsOnly: false);
        } else if (withdrawalsOnly) {
          transactions = provider.getCommissionsByType(withdrawalsOnly: true);
        } else {
          transactions = provider.commissions;
        }

        if (provider.isLoadingCommissions && transactions.isEmpty) {
          return _buildLoadingList();
        }

        if (transactions.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadCommissions(refresh: true),
          child: ListView.builder(
            controller: _scrollController,
            padding: AppSpacing.pagePadding,
            itemCount:
                transactions.length + (provider.hasMoreCommissions ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= transactions.length) {
                return _buildLoadingIndicator();
              }

              final transaction = transactions[index];
              return TransactionCard(
                transaction: transaction,
                onTap: () => _showTransactionDetails(context, transaction),
              );
            },
          ),
        );
      },
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
                      Row(
                        children: [
                          const SkeletonLoader(width: 80, height: 16),
                          const Spacer(),
                          const SkeletonLoader(width: 100, height: 16),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const SkeletonLoader(width: 60, height: 12),
                          const Spacer(),
                          const SkeletonLoader(width: 80, height: 12),
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
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.textTertiary(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune transaction',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vos commissions et retraits apparaîtront ici',
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

  /// 📄 Détails de transaction
  void _showTransactionDetails(
      BuildContext context, CommissionTransaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TransactionDetailsSheet(transaction: transaction),
    );
  }
}

/// 📄 Sheet des détails de transaction
class _TransactionDetailsSheet extends StatelessWidget {
  final CommissionTransaction transaction;

  const _TransactionDetailsSheet({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWithdrawal = transaction.isWithdrawal;
    final color = isWithdrawal ? AppColors.error : AppColors.success;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
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
              color: AppColors.gray300,
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
                        isWithdrawal
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
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
                          StatusBadge(
                            text: transaction.statusText,
                            color: _getStatusColor(transaction.status),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Montant
                _buildDetailRow(
                  context,
                  'Montant',
                  '${isWithdrawal ? '-' : '+'}${transaction.amount.toFormattedString()} FCFA',
                  valueColor: color,
                  isAmount: true,
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

                if (transaction.orderId != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    'Commande liée',
                    transaction.orderId!.substring(0, 8).toUpperCase(),
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

  Color _getStatusColor(WithdrawalStatus status) {
    switch (status) {
      case WithdrawalStatus.pending:
        return AppColors.warning;
      case WithdrawalStatus.approved:
        return AppColors.success;
      case WithdrawalStatus.rejected:
        return AppColors.error;
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
