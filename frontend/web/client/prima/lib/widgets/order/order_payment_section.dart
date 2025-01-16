import 'package:flutter/material.dart';
import 'package:prima/models/order.dart';
import 'package:prima/theme/colors.dart';
import 'package:spring_button/spring_button.dart';

class OrderPaymentSection extends StatelessWidget {
  final Order order;

  const OrderPaymentSection({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Récapitulatif',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 16),
          _buildPriceDetails(),
          const Divider(height: 32),
          _buildTotalAmount(),
          const SizedBox(height: 24),
          _buildDownloadInvoiceButton(),
        ],
      ),
    );
  }

  Widget _buildPriceDetails() {
    return Column(
      children: [
        _buildPriceRow('Service', order.service?.price ?? 0),
        const SizedBox(height: 8),
        ...(order.items ?? [])
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildPriceRow(
                    '${item.article?.name} (x${item.quantity})',
                    item.unitPrice * item.quantity,
                  ),
                ))
            .toList(),
        if (order.appliedOffers?.isNotEmpty ?? false) ...[
          const SizedBox(height: 8),
          ...(order.appliedOffers ?? [])
              .map((offer) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildPriceRow(
                      'Réduction',
                      -offer.discountAmount,
                      isDiscount: true,
                    ),
                  ))
              .toList(),
        ],
      ],
    );
  }

  Widget _buildPriceRow(String label, double amount,
      {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDiscount ? AppColors.success : AppColors.gray600,
            fontSize: 14,
          ),
        ),
        Text(
          '${isDiscount ? "-" : ""}${amount.toStringAsFixed(2)}€',
          style: TextStyle(
            color: isDiscount ? AppColors.success : AppColors.gray800,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalAmount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
        ),
        Text(
          '${order.totalAmount.toStringAsFixed(2)}€',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadInvoiceButton() {
    final canDownload = order.status == 'DELIVERED' || order.status == 'READY';

    return SpringButton(
      SpringButtonType.OnlyScale,
      Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: canDownload ? AppColors.primary : AppColors.gray200,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_outlined,
              color: canDownload ? Colors.white : AppColors.gray500,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Télécharger la facture',
              style: TextStyle(
                color: canDownload ? Colors.white : AppColors.gray500,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      onTap: canDownload
          ? () {
              // Implémenter le téléchargement de la facture
            }
          : null,
      scaleCoefficient: 0.95,
      useCache: false,
    );
  }
}
