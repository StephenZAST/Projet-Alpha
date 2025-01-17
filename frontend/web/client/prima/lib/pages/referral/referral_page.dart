import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/home-components/app_bar.dart';
import 'package:prima/providers/referral_provider.dart';
import 'package:prima/providers/loyalty_provider.dart';
import 'package:provider/provider.dart';
import 'package:prima/widgets/connection_error_widget.dart';

class ReferralPage extends StatefulWidget {
  const ReferralPage({super.key});

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ReferralProvider>().loadReferralCode());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBarComponent(
              title: 'Parrainage',
              onMenuPressed: () => Scaffold.of(context).openDrawer(),
            ),
            Expanded(
              child: Consumer2<ReferralProvider, LoyaltyProvider>(
                builder: (context, referralProvider, loyaltyProvider, _) {
                  if (referralProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (referralProvider.error != null) {
                    return ConnectionErrorWidget(
                      onRetry: () => referralProvider.loadReferralCode(),
                      customMessage: 'Impossible de charger votre code',
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildReferralCard(referralProvider),
                        const SizedBox(height: 24),
                        _buildRewardsInfo(),
                        if (loyaltyProvider.points != null) ...[
                          const SizedBox(height: 24),
                          _buildPointsCard(loyaltyProvider),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralCard(ReferralProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.primaryShadow],
      ),
      child: Column(
        children: [
          const Text(
            'Votre code de parrainage',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  provider.referralCode ?? 'Chargement...',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.share, color: AppColors.primary),
                  onPressed: provider.shareReferralCode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comment ça marche ?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.gray800,
              ),
            ),
            const SizedBox(height: 16),
            _buildRewardStep(
              icon: Icons.people,
              title: 'Partagez votre code',
              description: 'Invitez vos amis à utiliser votre code',
            ),
            const SizedBox(height: 16),
            _buildRewardStep(
              icon: Icons.redeem,
              title: 'Gagnez des points',
              description: '1000 points par parrainage réussi',
            ),
            const SizedBox(height: 16),
            _buildRewardStep(
              icon: Icons.card_giftcard,
              title: 'Échangez vos points',
              description: 'Contre des réductions sur vos commandes',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardStep({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray800,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: AppColors.gray600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPointsCard(LoyaltyProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.stars, color: AppColors.warning, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vos points de fidélité',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray800,
                    ),
                  ),
                  Text(
                    '${provider.points?.pointsBalance ?? 0} points',
                    style: TextStyle(
                      color: AppColors.gray600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
