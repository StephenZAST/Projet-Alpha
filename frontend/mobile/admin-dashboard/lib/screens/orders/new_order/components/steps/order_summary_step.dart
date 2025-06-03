import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../constants.dart';
import '../../../../../controllers/orders_controller.dart';

class OrderSummaryStep extends StatelessWidget {
  final controller = Get.find<OrdersController>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Récapitulatif de la commande', style: AppTextStyles.h3),
          SizedBox(height: AppSpacing.xl),
          _buildClientSummary(),
          _buildDivider(),
          _buildServiceSummary(),
          _buildDivider(),
          _buildArticlesSummary(),
          _buildDivider(),
          _buildTotalSection(),
        ],
      ),
    );
  }

  Widget _buildClientSummary() {
    return Obx(() {
      final client = controller.clients
          .firstWhereOrNull((c) => c.id == controller.selectedClientId.value);
      final address = controller.clientAddresses
          .firstWhereOrNull((a) => a.id == controller.selectedAddressId.value);

      return _buildSection(
        title: 'Informations client',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Nom', '${client?.firstName} ${client?.lastName}'),
            _buildInfoRow('Email', client?.email ?? ''),
            _buildInfoRow('Téléphone', client?.phone ?? ''),
            _buildInfoRow('Adresse', address?.fullAddress ?? ''),
          ],
        ),
      );
    });
  }

  Widget _buildServiceSummary() {
    return Obx(() {
      final service = controller.services
          .firstWhereOrNull((s) => s.id == controller.selectedServiceId.value);

      return _buildSection(
        title: 'Service',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Type de service', service?.name ?? ''),
            if (service?.description != null)
              _buildInfoRow('Description', service!.description!),
          ],
        ),
      );
    });
  }

  Widget _buildArticlesSummary() {
    return _buildSection(
      title: 'Articles',
      content: Obx(() => Column(
            children: controller.selectedItems.map((item) {
              final article = controller.articles
                  .firstWhere((a) => a.id == item['articleId']);

              return _buildInfoRow(
                article.name,
                '${item['quantity']} × ${item['price']} = ${item['quantity'] * item['price']} FCFA',
              );
            }).toList(),
          )),
    );
  }

  Widget _buildTotalSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: AppRadius.radiusMD,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total', style: AppTextStyles.h3),
          Obx(() => Text(
                '${controller.orderTotal.value} FCFA',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.primary,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.bodyBold),
        SizedBox(height: AppSpacing.sm),
        content,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Divider(height: 1),
    );
  }
}
