import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/affiliate_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/glass_container.dart';
import 'commissions_screen.dart';
import 'withdrawal_screen.dart';
import 'referrals_screen.dart';
import 'profile_screen.dart';

/// 🏠 Écran Dashboard - Alpha Affiliate App
///
/// Dashboard principal avec statistiques, actions rapides et navigation

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AffiliateProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () => context.read<AffiliateProvider>().refreshAll(),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverPadding(
              padding: AppSpacing.pagePadding,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildWelcomeSection(context),
                  const SizedBox(height: 24),
                  _buildStatsGrid(context),
                  const SizedBox(height: 24),
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  _buildRecentTransactions(context),
                  const SizedBox(height: 24),
                  _buildLevelProgress(context),
                  const SizedBox(height: 100), // Bottom padding
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  /// 📱 AppBar Glass Premium - Modern Design
  Widget _buildAppBar(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SliverAppBar(
          expandedHeight: 140,
          floating: true,
          pinned: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    // Effet glass moderne avec couleur Alpha
                    color: AppColors.primary.withOpacity(0.85),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              // Logo Alpha Laundry avec effet glass
                              Container(
                                width: 48,
                                height: 48,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Image.asset(
                                          'assets/Alpha_logo.png',
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.local_laundry_service,
                                              color: Colors.white,
                                              size: 24,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Alpha Laundry',
                                      style: AppTextStyles.headlineSmall.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 24,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.2),
                                            offset: const Offset(0, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Programme Affilié',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Avatar utilisateur avec effet glass
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ProfileScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.3),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            authProvider.initials,
                                            style: AppTextStyles.labelLarge.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black.withOpacity(0.3),
                                                  offset: const Offset(0, 1),
                                                  blurRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          title: Container(), // Titre vide car contenu dans flexibleSpace
        );
      },
    );
  }

  /// 👋 Section de bienvenue
  Widget _buildWelcomeSection(BuildContext context) {
    return Consumer2<AuthProvider, AffiliateProvider>(
      builder: (context, authProvider, affiliateProvider, child) {
        if (affiliateProvider.isLoadingProfile) {
          return _buildWelcomeSkeleton();
        }

        return GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour ${authProvider.firstName ?? 'Affilié'} 👋',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.textPrimary(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Voici votre tableau de bord affilié',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (affiliateProvider.profile != null)
                    StatusBadge(
                      text: affiliateProvider.profile!.statusText,
                      color: _getStatusColor(affiliateProvider.profile!.status),
                      icon: Icons.verified,
                    ),
                ],
              ),
              if (affiliateProvider.profile != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: AppRadius.borderRadiusSM,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.link,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Code: ${affiliateProvider.affiliateCode}',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _shareAffiliateCode(context),
                        child: Icon(
                          Icons.share,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// 📊 Grille de statistiques
  Widget _buildStatsGrid(BuildContext context) {
    return Consumer<AffiliateProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingProfile) {
          return _buildStatsGridSkeleton();
        }

        final stats = provider.dashboardStats;

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1, // Légèrement plus de hauteur pour éviter l'overflow
          children: [
            StatCard(
              title: 'Solde Disponible',
              value: '${formatNumber(stats['availableBalance'])} FCFA',
              subtitle: provider.canWithdraw ? 'Retrait possible' : 'Minimum ${formatNumber(AffiliateConfig.minWithdrawalAmount)} FCFA',
              icon: Icons.account_balance_wallet,
              color: AppColors.success,
              onTap: () => _navigateToWithdrawal(context),
            ),
            StatCard(
              title: 'Gains Totaux',
              value: '${formatNumber(stats['totalEarnings'])} FCFA',
              subtitle: 'Depuis le début',
              icon: Icons.trending_up,
              color: AppColors.primary,
              onTap: () => _navigateToCommissions(context),
            ),
            StatCard(
              title: 'Ce Mois',
              value: '${formatNumber(stats['monthlyEarnings'])} FCFA',
              subtitle: 'Gains mensuels',
              icon: Icons.calendar_month,
              color: AppColors.accent,
            ),
            StatCard(
              title: 'Filleuls',
              value: '${stats['totalReferrals']}',
              subtitle: 'Personnes parrainées',
              icon: Icons.people,
              color: AppColors.info,
              onTap: () => _navigateToReferrals(context),
            ),
          ],
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
              child: PremiumButton(
                text: 'Demander Retrait',
                icon: Icons.request_quote,
                onPressed: () => _navigateToWithdrawal(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PremiumButton(
                text: 'Partager Code',
                icon: Icons.share,
                isOutlined: true,
                onPressed: () => _shareAffiliateCode(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 📋 Transactions récentes
  Widget _buildRecentTransactions(BuildContext context) {
    return Consumer<AffiliateProvider>(
      builder: (context, provider, child) {
        final recentTransactions = provider.dashboardStats['recentTransactions'] as List;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Transactions Récentes',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _navigateToCommissions(context),
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
            if (provider.isLoadingCommissions)
              _buildTransactionsSkeleton()
            else if (recentTransactions.isEmpty)
              _buildEmptyTransactions()
            else
              ...recentTransactions.map((transaction) => TransactionCard(
                transaction: transaction,
                onTap: () => _showTransactionDetails(context, transaction),
              )).toList(),
          ],
        );
      },
    );
  }

  /// 🎯 Progression de niveau
  Widget _buildLevelProgress(BuildContext context) {
    return Consumer<AffiliateProvider>(
      builder: (context, provider, child) {
        final progress = provider.nextLevelProgress;
        
        if (progress == null) {
          return const SizedBox.shrink();
        }

        return GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: AppColors.accent,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Progression vers ${progress['nextLevel'].name}',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress['progress'],
                backgroundColor: AppColors.gray200,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${formatNumber(progress['currentEarnings'])} FCFA',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Objectif: ${formatNumber(progress['requiredEarnings'])} FCFA',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🎈 Bouton flottant Premium
  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.floatingShadow,
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _generateNewCode(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.refresh,
            color: Colors.white,
            size: 16,
          ),
        ),
        label: Text(
          'Nouveau Code',
          style: AppTextStyles.labelMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Skeletons
  Widget _buildWelcomeSkeleton() {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(width: 200, height: 24),
          const SizedBox(height: 8),
          const SkeletonLoader(width: 150, height: 16),
          const SizedBox(height: 16),
          const SkeletonLoader(width: double.infinity, height: 40),
        ],
      ),
    );
  }

  Widget _buildStatsGridSkeleton() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: List.generate(4, (index) => 
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SkeletonLoader(width: 40, height: 40),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 16),
              const SkeletonLoader(width: 80, height: 12),
              const SizedBox(height: 8),
              const SkeletonLoader(width: 120, height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsSkeleton() {
    return Column(
      children: List.generate(3, (index) => 
        Container(
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
        ),
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return GlassContainer(
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: AppColors.textTertiary(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune transaction',
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

  // Actions
  void _navigateToCommissions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CommissionsScreen()),
    );
  }

  void _navigateToWithdrawal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WithdrawalScreen()),
    );
  }

  void _navigateToReferrals(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReferralsScreen()),
    );
  }

  void _shareAffiliateCode(BuildContext context) {
    final provider = context.read<AffiliateProvider>();
    final code = provider.affiliateCode;
    
    if (code.isNotEmpty) {
      // TODO: Implémenter le partage système
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Code copié: $code'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _generateNewCode(BuildContext context) async {
    final provider = context.read<AffiliateProvider>();
    final success = await provider.generateNewCode();
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nouveau code généré avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.codeError ?? 'Erreur lors de la génération'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showTransactionDetails(BuildContext context, transaction) {
    // TODO: Implémenter les détails de transaction
  }

  Color _getStatusColor(AffiliateStatus status) {
    switch (status) {
      case AffiliateStatus.active:
        return AppColors.success;
      case AffiliateStatus.pending:
        return AppColors.warning;
      case AffiliateStatus.suspended:
        return AppColors.error;
    }
  }
}