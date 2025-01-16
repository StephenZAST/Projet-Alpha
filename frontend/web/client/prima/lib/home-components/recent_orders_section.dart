import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/providers/order_provider.dart';
import 'package:prima/widgets/order/recent_order_card.dart';
import 'package:provider/provider.dart';

class RecentOrdersSectionComponent extends StatelessWidget {
  const RecentOrdersSectionComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Commandes Récentes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray800,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/orders'),
                child: Row(
                  children: [
                    Text(
                      'Voir plus',
                      style: TextStyle(color: AppColors.primary),
                    ),
                    Icon(Icons.arrow_forward, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Consumer<OrderProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (provider.recentOrders.isEmpty) {
                return Center(
                  child: Text(
                    'Aucune commande récente',
                    style: TextStyle(color: AppColors.gray600),
                  ),
                );
              }

              return Column(
                children: provider.recentOrders
                    .map((order) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: RecentOrderCard(order: order),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
