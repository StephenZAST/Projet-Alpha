import 'package:flutter/material.dart';
import 'package:prima/models/article.dart';
import 'package:prima/models/service.dart';
import 'package:prima/models/order_item_summary.dart';
import 'package:prima/providers/article_provider.dart';
import 'package:prima/services/order_service.dart';
import 'package:prima/theme/colors.dart';
import 'package:provider/provider.dart';
import 'package:spring_button/spring_button.dart';

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
    List<OrderItemSummary> itemSummaries = [];
    double totalAmount = 0;

    // Calculer les totaux
    for (var entry in selectedArticles.entries) {
      final article = _findArticle(context, entry.key);
      if (article != null) {
        final itemTotal = article.basePrice * entry.value;
        totalAmount += itemTotal;
        itemSummaries.add(OrderItemSummary(
          name: article.name,
          quantity: entry.value,
          unitPrice: article.basePrice,
        ));
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildServiceSection(),
          const SizedBox(height: 16),
          _buildArticlesSection(itemSummaries, totalAmount),
          const SizedBox(height: 16),
          _buildDatesSection(),
          const SizedBox(height: 24),
          if (_canConfirmOrder())
            SpringButton(
              SpringButtonType.OnlyScale,
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [AppColors.primaryShadow],
                ),
                child: Center(
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Confirmer la commande',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              onTap: isLoading ? null : onConfirmOrder,
              scaleCoefficient: 0.95,
              useCache: false,
            ),
        ],
      ),
    );
  }

  Widget _buildServiceSection() {
    return _buildSummaryCard(
      title: 'Service sélectionné',
      child: ListTile(
        leading: Icon(Icons.local_laundry_service, color: AppColors.primary),
        title: Text(
          selectedService?.name ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(selectedService?.description ?? ''),
      ),
    );
  }

  Widget _buildArticlesSection(
      List<OrderItemSummary> itemSummaries, double totalAmount) {
    return _buildSummaryCard(
      title: 'Articles sélectionnés',
      child: Column(
        children: [
          ...itemSummaries.map((item) => ListTile(
                title: Text(item.name),
                trailing: Text(
                  '${item.quantity}x - ${item.total.toStringAsFixed(2)}€',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              )),
          const Divider(height: 1),
          ListTile(
            title: const Text(
              'Total',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              '${totalAmount.toStringAsFixed(2)}€',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatesSection() {
    return _buildSummaryCard(
      title: 'Dates',
      child: Column(
        children: [
          _buildDateTile(
            icon: Icons.upload,
            title: 'Collecte',
            date: collectionDate,
          ),
          _buildDateTile(
            icon: Icons.download,
            title: 'Livraison',
            date: deliveryDate,
          ),
        ],
      ),
    );
  }

  Widget _buildDateTile({
    required IconData icon,
    required String title,
    required DateTime? date,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(
        date?.toString().split(' ')[0] ?? 'Non sélectionnée',
        style: TextStyle(
          color: date != null ? AppColors.gray800 : AppColors.gray400,
        ),
      ),
    );
  }

  bool _canConfirmOrder() {
    return selectedService != null &&
        selectedArticles.isNotEmpty &&
        collectionDate != null &&
        deliveryDate != null;
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

  Article? _findArticle(BuildContext context, String articleId) {
    final articleProvider =
        Provider.of<ArticleProvider>(context, listen: false);
    return articleProvider.articles.firstWhere(
      (article) => article.id == articleId,
      orElse: () => throw Exception('Article non trouvé'),
    );
  }
}
