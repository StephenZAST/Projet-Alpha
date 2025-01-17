import 'package:flutter/material.dart';
import 'package:prima/models/offer.dart';
import 'package:prima/theme/colors.dart';

class PriceSummary extends StatelessWidget {
  final double subtotal;
  final Offer? appliedOffer;

  const PriceSummary({
    Key? key,
    required this.subtotal,
    this.appliedOffer,
  }) : super(key: key);

  double get discountAmount {
    if (appliedOffer == null) return 0;
    if (appliedOffer!.discountType == 'PERCENTAGE') {
      return subtotal * (appliedOffer!.discountValue / 100);
    }
    return appliedOffer!.discountValue;
  }

  double get total => subtotal - discountAmount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPriceRow('Sous-total', subtotal),
        if (appliedOffer != null)
          _buildPriceRow('Réduction', -discountAmount, isDiscount: true),
        const Divider(),
        _buildPriceRow('Total', total, isTotal: true),
      ],
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? AppColors.success : AppColors.gray800,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)}€',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? AppColors.success : AppColors.gray800,
            ),
          ),
        ],
      ),
    );
  }
}
