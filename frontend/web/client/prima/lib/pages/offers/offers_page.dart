import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/home-components/app_bar.dart';
import 'package:prima/providers/offer_provider.dart';
import 'package:provider/provider.dart';
import 'package:prima/widgets/connection_error_widget.dart';

class OffersPage extends StatelessWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      body: SafeArea(
        child: Column(
          children: [
            AppBarComponent(
              title: 'Offres',
              onMenuPressed: () => Scaffold.of(context).openDrawer(),
            ),
            Expanded(
              child: Consumer<OfferProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null) {
                    return ConnectionErrorWidget(
                      onRetry: () => provider.loadOffers(),
                      customMessage: 'Impossible de charger les offres',
                    );
                  }

                  if (provider.offers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_offer_outlined,
                              size: 64, color: AppColors.gray400),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune offre disponible',
                            style: TextStyle(color: AppColors.gray600),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.offers.length,
                    itemBuilder: (context, index) {
                      final offer = provider.offers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.gray200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      offer.discountType == 'PERCENTAGE'
                                          ? '-${offer.discountValue}%'
                                          : '-${offer.discountValue}€',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (offer.minPurchaseAmount != null) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      'Min. ${offer.minPurchaseAmount}€',
                                      style:
                                          TextStyle(color: AppColors.gray600),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                offer.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (offer.description != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  offer.description!,
                                  style: TextStyle(color: AppColors.gray600),
                                ),
                              ],
                              if (offer.endDate != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'Valable jusqu\'au ${_formatDate(offer.endDate!)}',
                                  style: TextStyle(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
