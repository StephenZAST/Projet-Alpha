import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/affiliate_provider.dart';
import '../widgets/glass_container.dart';

/// 👥 Écran Filleuls - Alpha Affiliate App
///
/// Affichage des filleuls (referrals) avec statistiques

class ReferralsScreen extends StatefulWidget {
  const ReferralsScreen({Key? key}) : super(key: key);

  @override
  State<ReferralsScreen> createState() => _ReferralsScreenState();
}

class _ReferralsScreenState extends State<ReferralsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AffiliateProvider>().loadReferrals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Mes Filleuls',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
      ),
      body: Consumer<AffiliateProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: provider.loadReferrals,
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCard(provider),
                  const SizedBox(height: 24),
                  _buildReferralsList(provider),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _shareAffiliateCode(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.share, color: Colors.white),
        label: Text(
          'Partager Code',
          style: AppTextStyles.labelMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(AffiliateProvider provider) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.people,
                  color: AppColors.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Filleuls',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${provider.totalReferrals}',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                  color: AppColors.info,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Votre Code Affilié',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                      Text(
                        provider.affiliateCode,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
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
      ),
    );
  }

  Widget _buildReferralsList(AffiliateProvider provider) {
    if (provider.isLoadingReferrals) {
      return _buildLoadingList();
    }

    if (provider.referrals.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Liste des Filleuls',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...provider.referrals
            .map((referral) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: GlassContainer(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            referral.user?.initials ?? 'U',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                referral.displayName,
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.textPrimary(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Inscrit le ${_formatDate(referral.createdAt)}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const StatusBadge(
                          text: 'Actif',
                          color: AppColors.success,
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildLoadingList() {
    return Column(
      children: List.generate(
        5,
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
                      const SkeletonLoader(width: 120, height: 16),
                      const SizedBox(height: 8),
                      const SkeletonLoader(width: 100, height: 12),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 48),
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.textTertiary(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun filleul',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Partagez votre code pour commencer\nà parrainer des personnes',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          PremiumButton(
            text: 'Partager mon Code',
            icon: Icons.share,
            onPressed: () => _shareAffiliateCode(context),
          ),
        ],
      ),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'hier';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
