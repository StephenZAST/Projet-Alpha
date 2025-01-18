import 'package:flutter/material.dart';
import 'package:prima/models/offer.dart';
import 'package:prima/providers/offer_provider.dart';
import 'package:prima/theme/colors.dart';
import 'package:provider/provider.dart';

class OfferSelector extends StatelessWidget {
  const OfferSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OfferProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.offers.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Réductions disponibles',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.offers.length,
              itemBuilder: (context, index) {
                final offer = provider.offers[index];
                final isSelected = provider.selectedOffer?.id == offer.id;

                return ListTile(
                  leading: Icon(
                    Icons.local_offer,
                    color: isSelected ? AppColors.primary : AppColors.gray400,
                  ),
                  title: Text(offer.name),
                  subtitle: Text(offer.description ?? ''),
                  trailing: Text(
                    '${offer.discountValue}${offer.discountType == 'PERCENTAGE' ? '%' : '€'}',
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.gray600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  selected: isSelected,
                  onTap: () => provider.selectOffer(isSelected ? null : offer),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
