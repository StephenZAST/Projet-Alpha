import 'package:flutter/material.dart';
import 'package:prima/models/order.dart';
import 'package:prima/theme/colors.dart';
import 'package:intl/intl.dart';

class OrderDeliverySection extends StatelessWidget {
  final Order order;

  const OrderDeliverySection({
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
            'Livraison',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 16),
          _buildAddressCard(),
          const SizedBox(height: 16),
          _buildDateInfo(context),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on_outlined, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Adresse de livraison',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            order.address?.name ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.gray800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            order.address?.street ?? '',
            style: const TextStyle(color: AppColors.gray600),
          ),
          Text(
            '${order.address?.city ?? ''}, ${order.address?.postal_code ?? ''}',
            style: const TextStyle(color: AppColors.gray600),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildDateCard(
            context,
            'Collecte',
            order.collectionDate,
            Icons.upload_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDateCard(
            context,
            'Livraison',
            order.deliveryDate,
            Icons.download_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildDateCard(
    BuildContext context,
    String title,
    DateTime? date,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.gray600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            date != null
                ? DateFormat('dd MMM yyyy\nHH:mm', 'fr_FR').format(date)
                : 'Non défini',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.gray800,
            ),
          ),
        ],
      ),
    );
  }
}
