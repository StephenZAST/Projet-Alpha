import 'package:flutter/material.dart';
import 'package:prima/models/offer.dart';
import 'package:prima/theme/colors.dart';

class AvailableOffers extends StatelessWidget {
  final List<Offer> offers;
  final Offer? selectedOffer;
  final double orderTotal;
  final Function(Offer?) onOfferSelected;

  const AvailableOffers({
    Key? key,
    required this.offers,
    required this.selectedOffer,
    required this.orderTotal,
    required this.onOfferSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Réductions disponibles',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.gray800,
          ),
        ),
        const SizedBox(height: 8),
        ...offers.map((offer) {
          final isValid = _isOfferValid(offer);
          final isSelected = selectedOffer?.id == offer.id;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.gray300,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_offer,
                  color: isValid ? AppColors.primary : AppColors.gray400,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              isValid ? AppColors.gray800 : AppColors.gray400,
                        ),
                      ),
                      if (offer.description != null)
                        Text(
                          offer.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isValid ? AppColors.gray600 : AppColors.gray400,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  _formatDiscount(offer),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isValid ? AppColors.primary : AppColors.gray400,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _formatDiscount(Offer offer) {
    return offer.discountType == 'PERCENTAGE'
        ? '-${offer.discountValue}%'
        : '-${offer.discountValue}€';
  }

  bool _isOfferValid(Offer offer) {
    if (!offer.isActive) return false;
    if (offer.minPurchaseAmount != null &&
        orderTotal < offer.minPurchaseAmount!) {
      return false;
    }
    final now = DateTime.now();
    if (offer.startDate != null && now.isBefore(offer.startDate!)) return false;
    if (offer.endDate != null && now.isAfter(offer.endDate!)) return false;
    return true;
  }
}
