import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/providers/loyalty_provider.dart';
import 'package:provider/provider.dart';
import 'package:prima/widgets/loyalty/points_rules_card.dart';
import 'package:prima/widgets/loyalty/points_history_list.dart';
import 'package:prima/widgets/loyalty/points_summary_card.dart';
import 'package:prima/widgets/loyalty/points_stats_card.dart';

class LoyaltyPointsPage extends StatefulWidget {
  const LoyaltyPointsPage({super.key});

  @override
  State<LoyaltyPointsPage> createState() => _LoyaltyPointsPageState();
}

class _LoyaltyPointsPageState extends State<LoyaltyPointsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<LoyaltyProvider>().loadTransactions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        title: const Text('Points de fidélité'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<LoyaltyProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.points == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.refreshPoints(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PointsSummaryCard(points: provider.points),
                const SizedBox(height: 24),
                PointsStatsCard(
                  pointsThisMonth: provider.pointsThisMonth,
                  totalOrders: provider.totalOrders,
                  referrals: provider.totalReferrals,
                ),
                const SizedBox(height: 24),
                const PointsRulesCard(),
                const SizedBox(height: 24),
                const Text(
                  'Historique des transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray800,
                  ),
                ),
                const SizedBox(height: 16),
                PointsHistoryList(transactions: provider.transactions),
              ],
            ),
          );
        },
      ),
    );
  }
}
