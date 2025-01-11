import 'package:flutter/material.dart';
import 'package:prima/models/order_item_summary.dart';
import 'package:prima/theme/colors.dart';

class OrderSummary extends StatelessWidget {
  final String serviceName;
  final List<OrderItemSummary> items;
  final DateTime? collectionDate;
  final DateTime? deliveryDate;
  final double totalAmount;

  const OrderSummary({
    Key? key,
    required this.serviceName,
    required this.items,
    this.collectionDate,
    this.deliveryDate,
    required this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Résumé de la commande',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildServiceSection(),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildItemsSection(),
        ],
        const SizedBox(height: 16),
        _buildDatesSection(),
        const SizedBox(height: 16),
        _buildTotalSection(),
      ],
    );
  }

  Widget _buildServiceSection() {
    return Card(
      child: ListTile(
        leading:
            const Icon(Icons.local_laundry_service, color: AppColors.primary),
        title: const Text('Service'),
        subtitle: Text(serviceName),
      ),
    );
  }

  Widget _buildItemsSection() {
    return Card(
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.inventory_2, color: AppColors.primary),
            title: Text('Articles'),
          ),
          ...items.map((item) => ListTile(
                title: Text(item.name),
                trailing: Text('${item.quantity}x'),
                subtitle: Text('\$${item.unitPrice}'),
              )),
        ],
      ),
    );
  }

  Widget _buildDatesSection() {
    return Card(
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.calendar_today, color: AppColors.primary),
            title: Text('Dates'),
          ),
          if (collectionDate != null)
            ListTile(
              title: const Text('Collecte'),
              subtitle: Text(
                '${collectionDate?.day}/${collectionDate?.month}/${collectionDate?.year}',
              ),
            ),
          if (deliveryDate != null)
            ListTile(
              title: const Text('Livraison'),
              subtitle: Text(
                '${deliveryDate?.day}/${deliveryDate?.month}/${deliveryDate?.year}',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    return Card(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '\$${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
