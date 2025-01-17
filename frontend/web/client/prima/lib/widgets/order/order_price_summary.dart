import 'package:flutter/material.dart';
import 'package:prima/models/offer.dart';
import 'package:prima/theme/colors.dart';

class OrderPriceSummary extends StatelessWidget {
  final double subtotal;
  final Offer? activeOffer;
  final double? deliveryFee;

  const OrderPriceSummary({
    Key? key,
    required this.subtotal,
    this.activeOffer,
    this.deliveryFee,
  }) : super(key: key);

  double get discount => activeOffer?.calculateDiscount(subtotal) ?? 0;
  double get total => subtotal - discount + (deliveryFee ?? 0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPriceRow('Sous-total', subtotal),
          if (activeOffer != null) ...[
            _buildPriceRow(
              'Réduction (${activeOffer!.name})',
              -discount,
              color: AppColors.success,
            ),
          ],
          if (deliveryFee != null)
            _buildPriceRow('Frais de livraison', deliveryFee!),
          const Divider(height: 16),
          _buildPriceRow('Total', total, isTotal: true),
          if (activeOffer == null)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Sélectionnez une offre pour bénéficier d\'une réduction',
                style: TextStyle(
                  color: AppColors.gray600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
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
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color ?? AppColors.gray800,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)}€',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color ?? AppColors.gray800,
            ),
          ),
        ],
      ),
    );
  }
}
