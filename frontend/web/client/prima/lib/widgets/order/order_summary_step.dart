import 'package:flutter/material.dart';
import 'package:prima/models/article.dart';
import 'package:prima/models/service.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/providers/article_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class OrderSummaryStep extends StatelessWidget {
  final Service? service;
  final Map<String, int> articles;
  final DateTime? collectionDate;
  final DateTime? deliveryDate;
  final Function(double) onConfirm;
  final bool isLoading;

  const OrderSummaryStep({
    Key? key,
    required this.service,
    required this.articles,
    required this.collectionDate,
    required this.deliveryDate,
    required this.onConfirm,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalAmount = 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildServiceCard(context),
          const SizedBox(height: 16),
          _buildArticlesCard(context, totalAmount),
          const SizedBox(height: 16),
          _buildDatesCard(context),
          const SizedBox(height: 24),
          _buildConfirmButton(context, totalAmount),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context) {
    return _buildSummaryCard(
      title: 'Service sélectionné',
      child: ListTile(
        leading: Icon(Icons.local_laundry_service, color: AppColors.primary),
        title: Text(service?.name ?? 'Aucun service sélectionné'),
        subtitle: Text(service?.description ?? ''),
      ),
    );
  }

  Widget _buildArticlesCard(BuildContext context, double totalAmount) {
    final articleProvider = context.read<ArticleProvider>();

    return _buildSummaryCard(
      title: 'Articles sélectionnés',
      child: Column(
        children: [
          ...articles.entries.map((entry) {
            final article = articleProvider.articles.firstWhere(
                (a) => a.id == entry.key,
                orElse: () => throw Exception('Article non trouvé'));
            final itemTotal = article.basePrice * entry.value;
            totalAmount += itemTotal;

            return ListTile(
              title: Text(article.name),
              subtitle: Text('${article.basePrice}€ × ${entry.value}'),
              trailing: Text(
                '${itemTotal.toStringAsFixed(2)}€',
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
    );
  }

  Widget _buildDatesCard(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return _buildSummaryCard(
      title: 'Dates',
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.calendar_today, color: AppColors.primary),
            title: const Text('Collecte'),
            trailing: Text(
              collectionDate != null
                  ? dateFormat.format(collectionDate!)
                  : 'Non définie',
              style: TextStyle(
                color: collectionDate != null
                    ? AppColors.gray800
                    : AppColors.error,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.event, color: AppColors.primary),
            title: const Text('Livraison'),
            trailing: Text(
              deliveryDate != null
                  ? dateFormat.format(deliveryDate!)
                  : 'Non définie',
              style: TextStyle(
                color:
                    deliveryDate != null ? AppColors.gray800 : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, double totalAmount) {
    final bool isValid = service != null &&
        articles.isNotEmpty &&
        collectionDate != null &&
        deliveryDate != null;

    return ElevatedButton(
      onPressed: isValid && !isLoading ? () => onConfirm(totalAmount) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            )
          : const Text(
              'Confirmer la commande',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
}
