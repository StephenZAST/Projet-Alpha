import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/models/offer.dart';
import 'package:provider/provider.dart';
import 'package:prima/providers/offer_provider.dart';

class ReductionInput extends StatelessWidget {
  final Offer? activeOffer;
  final Function(Offer?) onOfferApplied;
  final List<Offer> availableOffers;

  const ReductionInput({
    Key? key,
    this.activeOffer,
    required this.onOfferApplied,
    required this.availableOffers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OfferProvider>(
      builder: (context, provider, _) {
        final recentOffers = provider.getRecentOffers();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section des offres récentes
            if (recentOffers.isNotEmpty) ...[
              const Text(
                'Récemment utilisées',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray800,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: recentOffers
                      .map((offer) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildRecentOfferChip(
                              offer,
                              isSelected:
                                  offer.id == provider.selectedOffer?.id,
                              onTap: () => provider.selectOffer(
                                offer.id == provider.selectedOffer?.id
                                    ? null
                                    : offer,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const Divider(height: 24),
            ],

            // Section des offres disponibles
            const Text(
              'Toutes les offres',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.gray800,
              ),
            ),
            const SizedBox(height: 8),
            ...availableOffers
                .where((offer) => offer.isValid)
                .map((offer) => _buildOfferTile(context, offer)),
          ],
        );
      },
    );
  }

  Widget _buildRecentOfferChip(
    Offer offer, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_offer,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.gray600,
            ),
            const SizedBox(width: 4),
            Text(
              offer.type == 'PERCENTAGE'
                  ? '-${offer.value}%'
                  : '-${offer.value}€',
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.gray800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferTile(BuildContext context, Offer offer) {
    final isSelected = activeOffer?.id == offer.id;

    return ListTile(
      leading: Icon(
        Icons.local_offer,
        color: isSelected ? AppColors.primary : AppColors.gray400,
      ),
      title: Text(offer.name),
      subtitle: Text(
        offer.type == 'PERCENTAGE' ? '-${offer.value}%' : '-${offer.value}€',
      ),
      selected: isSelected,
      onTap: () => onOfferApplied(isSelected ? null : offer),
    );
  }
}
