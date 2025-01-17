import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prima/models/offer.dart';
import 'package:prima/providers/loyalty_provider.dart';
import 'package:prima/theme/colors.dart';

class PointExchangeOfferCard extends StatelessWidget {
  final Offer offer;
  final VoidCallback? onSelect;
  final bool isSelected;

  const PointExchangeOfferCard({
    super.key,
    required this.offer,
    this.onSelect,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LoyaltyProvider>(
      builder: (context, loyaltyProvider, _) {
        final hasEnoughPoints = loyaltyProvider.points?.pointsBalance ??
            0 >= (offer.pointsRequired ?? 0);

        return Card(
          elevation: isSelected ? 4 : 1,
          child: InkWell(
            onTap: hasEnoughPoints ? onSelect : null,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: isSelected
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${offer.discountValue}€ de réduction',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${offer.pointsRequired} points',
                        style: TextStyle(
                          color: hasEnoughPoints
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (!hasEnoughPoints) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Points insuffisants',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
