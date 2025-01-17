import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/providers/loyalty_provider.dart';
import 'package:provider/provider.dart';

class LoyaltyOverviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LoyaltyProvider>(
      builder: (context, provider, _) {
        final points = provider.points;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.stars, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Text(
                      'Points de Fidélité',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${points?.pointsBalance ?? 0} points',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Total gagné : ${points?.totalEarned ?? 0} points',
                  style: TextStyle(color: AppColors.gray600),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: ((points?.pointsBalance ?? 0) % 100) / 100,
                  backgroundColor: AppColors.gray200,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
