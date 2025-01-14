import 'package:flutter/material.dart';
import 'package:prima/models/article.dart';
import 'package:prima/models/service.dart';
import 'package:prima/providers/article_provider.dart';
import 'package:prima/theme/colors.dart';
import 'package:provider/provider.dart';

class OrderSummary extends StatelessWidget {
  final Service? selectedService;
  final Map<String, int> selectedArticles;
  final DateTime? collectionDate;
  final DateTime? deliveryDate;
  final VoidCallback onConfirmOrder;
  final bool isLoading;

  const OrderSummary({
    Key? key,
    this.selectedService,
    required this.selectedArticles,
    this.collectionDate,
    this.deliveryDate,
    required this.onConfirmOrder,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalAmount = 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSummaryCard(
            title: 'Service sélectionné',
            child: ListTile(
              leading:
                  Icon(Icons.local_laundry_service, color: AppColors.primary),
              title: Text(selectedService?.name ?? ''),
              subtitle: Text(selectedService?.description ?? ''),
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            title: 'Articles sélectionnés',
            child: Column(
              children: [
                ...selectedArticles.entries.map((entry) {
                  final article = _findArticle(context, entry.key);
                  if (article == null) return const SizedBox();
                  final itemTotal = article.basePrice * entry.value;
                  totalAmount += itemTotal;

                  return ListTile(
                    title: Text(article.name),
                    trailing: Text(
                      '${entry.value}x - ${itemTotal.toStringAsFixed(2)}€',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
                const Divider(),
                ListTile(
                  title: const Text('Total'),
                  trailing: Text(
                    '${totalAmount.toStringAsFixed(2)}€',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            title: 'Dates',
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.upload, color: AppColors.primary),
                  title: const Text('Collecte'),
                  subtitle: Text(collectionDate?.toString().split(' ')[0] ??
                      'Non sélectionnée'),
                ),
                ListTile(
                  leading: Icon(Icons.download, color: AppColors.primary),
                  title: const Text('Livraison'),
                  subtitle: Text(deliveryDate?.toString().split(' ')[0] ??
                      'Non sélectionnée'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildConfirmOrderButton(context, totalAmount),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required Widget child}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.gray700,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildConfirmOrderButton(BuildContext context, double totalAmount) {
    return ElevatedButton(
      onPressed: isLoading ? null : onConfirmOrder,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              'Confirmer la commande',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Article? _findArticle(BuildContext context, String articleId) {
    final articleProvider =
        Provider.of<ArticleProvider>(context, listen: false);
    return articleProvider.articles.firstWhere(
      (article) => article.id == articleId,
      orElse: () => throw Exception('Article non trouvé'),
    );
  }
}
