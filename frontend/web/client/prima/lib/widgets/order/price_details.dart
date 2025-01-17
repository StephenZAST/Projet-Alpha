import 'package:flutter/material.dart';
import 'package:prima/models/offer.dart';
import 'package:prima/theme/colors.dart';

class PriceDetails extends StatelessWidget {
  final double subtotal;
  final Offer? activeOffer;

  const PriceDetails({
    Key? key,
    required this.subtotal,
    this.activeOffer,
  }) : super(key: key);

  double get discount => activeOffer?.calculateDiscount(subtotal) ?? 0;
  double get total => subtotal - discount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPriceRow('Sous-total', subtotal),
        if (activeOffer != null) ...[
          _buildPriceRow(
            'Réduction (${activeOffer!.name})',
            -discount,
            color: AppColors.success,
          ),
        ],
        const Divider(height: 24),
        _buildPriceRow('Total', total, isTotal: true),
      ],
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    Color? color,
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
              color: color ?? AppColors.gray800,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)}€',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color ?? AppColors.gray800,
            ),
          ),
        ],
      ),
    );
  }
}
