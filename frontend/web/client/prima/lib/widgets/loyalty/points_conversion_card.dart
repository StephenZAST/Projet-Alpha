import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prima/providers/loyalty_provider.dart';
import 'package:prima/theme/colors.dart';

class PointsConversionCard extends StatelessWidget {
  const PointsConversionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<LoyaltyProvider>(
          builder: (context, provider, _) {
            final points = provider.points?.pointsBalance ?? 0;
            final possibleDiscount = provider.calculatePossibleDiscount(points);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Convertir vos points',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Vous pouvez obtenir jusqu\'à ${possibleDiscount.toStringAsFixed(2)}€ de réduction',
                  style: TextStyle(color: AppColors.gray600),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: points >= 100
                      ? () => provider.convertPointsToDiscount(points)
                      : null,
                  child: const Text('Convertir mes points'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
