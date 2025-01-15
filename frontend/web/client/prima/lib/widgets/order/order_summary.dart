import 'package:flutter/material.dart';
import 'package:prima/models/service.dart';
import 'package:prima/models/order_item_summary.dart';
import 'package:prima/providers/article_provider.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/widgets/order/recurrence_selection.dart';
import 'package:provider/provider.dart';
import 'package:spring_button/spring_button.dart';
import 'package:intl/intl.dart';
import 'package:prima/providers/address_provider.dart';
import 'package:prima/models/address.dart';
import 'package:prima/utils/bottom_sheet_manager.dart';
import 'package:prima/widgets/address_list_bottom_sheet.dart';

class OrderSummary extends StatelessWidget {
  final Service? selectedService;
  final Map<String, int> selectedArticles;
  final DateTime? collectionDate;
  final DateTime? deliveryDate;
  final TimeOfDay? collectionTime;
  final TimeOfDay? deliveryTime;
  final RecurrenceType selectedRecurrence;
  final VoidCallback onConfirmOrder;
  final bool isLoading;
  final Address? selectedAddress;

  const OrderSummary({
    Key? key,
    this.selectedService,
    required this.selectedArticles,
    this.collectionDate,
    this.deliveryDate,
    this.collectionTime,
    this.deliveryTime,
    required this.selectedRecurrence,
    required this.onConfirmOrder,
    required this.isLoading,
    this.selectedAddress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSummarySection(
            title: 'Service sélectionné',
            child: _buildServiceCard(context),
          ),
          const SizedBox(height: 16),
          _buildSummarySection(
            title: 'Articles sélectionnés',
            child: _buildArticlesList(context),
          ),
          const SizedBox(height: 16),
          _buildSummarySection(
            title: 'Dates et heures',
            child: _buildDateTimeInfo(context),
          ),
          const SizedBox(height: 16),
          _buildSummarySection(
            title: 'Adresse de collecte/livraison',
            child: _buildAddressCard(context),
          ),
          if (selectedRecurrence != RecurrenceType.none) ...[
            const SizedBox(height: 16),
            _buildSummarySection(
              title: 'Récurrence',
              child: _buildRecurrenceInfo(context),
            ),
          ],
          const SizedBox(height: 24),
          if (selectedAddress == null)
            _buildNoAddressWarning()
          else
            _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildSummarySection({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildServiceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.local_laundry_service, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedService?.name ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  selectedService?.description ?? '',
                  style: TextStyle(
                    color: AppColors.gray600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesList(BuildContext context) {
    double totalAmount = 0;
    final itemSummaries = _calculateItemSummaries(context, totalAmount);

    return Column(
      children: [
        ...itemSummaries.map((item) => _buildArticleItem(item)),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.gray200)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${totalAmount.toStringAsFixed(2)}€',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeInfo(BuildContext context) {
    String formatDateTime(DateTime? date, TimeOfDay? time) {
      if (date == null) return 'Non défini';
      final dateStr = DateFormat.yMMMd('fr_FR').format(date);
      final timeStr = time?.format(context) ?? '';
      return '$dateStr ${timeStr.isNotEmpty ? 'à $timeStr' : ''}';
    }

    return Column(
      children: [
        _buildInfoRow(
          icon: Icons.upload,
          title: 'Collecte',
          value: formatDateTime(collectionDate, collectionTime),
        ),
        _buildInfoRow(
          icon: Icons.download,
          title: 'Livraison',
          value: formatDateTime(deliveryDate, deliveryTime),
        ),
      ],
    );
  }

  Widget _buildRecurrenceInfo(BuildContext context) {
    final recurrenceText = {
      RecurrenceType.weekly: 'Hebdomadaire',
      RecurrenceType.biweekly: 'Bi-mensuelle',
      RecurrenceType.monthly: 'Mensuelle',
    }[selectedRecurrence];

    return _buildInfoRow(
      icon: Icons.repeat,
      title: 'Fréquence',
      value: recurrenceText ?? '',
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.gray600,
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<OrderItemSummary> _calculateItemSummaries(
      BuildContext context, double totalAmount) {
    final articleProvider =
        Provider.of<ArticleProvider>(context, listen: false);
    final summaries = <OrderItemSummary>[];

    for (var entry in selectedArticles.entries) {
      final article = articleProvider.articles.firstWhere(
          (a) => a.id == entry.key,
          orElse: () => throw Exception());
      final itemTotal = article.basePrice * entry.value;
      totalAmount += itemTotal;
      summaries.add(OrderItemSummary(
        name: article.name,
        quantity: entry.value,
        unitPrice: article.basePrice,
      ));
    }

    return summaries;
  }

  Widget _buildArticleItem(OrderItemSummary item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${item.quantity}x ${item.unitPrice.toStringAsFixed(2)}€',
                style: TextStyle(
                  color: AppColors.gray600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Text(
            '${item.total.toStringAsFixed(2)}€',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context) {
    if (selectedAddress == null) {
      return SpringButton(
        SpringButtonType.OnlyScale,
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aucune adresse sélectionnée',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _showAddressBottomSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                      ),
                      child: const Text('Ajouter une adresse'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Image.asset(
                  'assets/Building.png',
                  width: 56,
                  height: 51,
                ),
              ),
            ],
          ),
        ),
        onTap: () => _showAddressBottomSheet(context),
        scaleCoefficient: 0.95,
        useCache: false,
      );
    }

    return SpringButton(
      SpringButtonType.OnlyScale,
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (selectedAddress!.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Par défaut',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (selectedAddress!.isDefault) const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedAddress!.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showAddressBottomSheet(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Changer'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (selectedAddress!.street != null)
                    Text(
                      selectedAddress!.street!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  Text(
                    '${selectedAddress!.city}${selectedAddress!.postalCode != null ? ', ${selectedAddress!.postalCode}' : ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Image.asset(
                'assets/Building.png',
                width: 56,
                height: 51,
              ),
            ),
          ],
        ),
      ),
      onTap: () => _showAddressBottomSheet(context),
      scaleCoefficient: 0.95,
      useCache: false,
    );
  }

  void _showAddressBottomSheet(BuildContext context) {
    BottomSheetManager().showCustomBottomSheet(
      context: context,
      builder: (context) => AddressListBottomSheet(
        selectedAddress: selectedAddress,
        onSelected: (address) {
          Provider.of<AddressProvider>(context, listen: false)
              .setSelectedAddress(address);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildNoAddressWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Veuillez sélectionner une adresse pour continuer',
        style: TextStyle(
          color: AppColors.error,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SpringButton(
      SpringButtonType.OnlyScale,
      Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30),
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
    );
  }
}
