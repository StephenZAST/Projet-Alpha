import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../constants.dart';
import '../../../../../controllers/orders_controller.dart';
import 'package:admin/models/enums.dart';
import '../order_item_recap_card.dart';

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
          _buildExtraFieldsSummary(),
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

  Widget _buildExtraFieldsSummary() {
    return Obx(() {
      final draft = controller.orderDraft.value;
      String? statusLabel;
      Color? statusColor;
      IconData? statusIcon;
      if (draft.status != null) {
        final statusEnum =
            OrderStatus.values.firstWhereOrNull((s) => s.name == draft.status);
        statusLabel = statusEnum?.label;
        statusColor = statusEnum?.color;
        statusIcon = statusEnum?.icon;
      }
      String? paymentLabel;
      if (draft.paymentMethod != null) {
        final paymentEnum = PaymentMethod.values
            .firstWhereOrNull((p) => p.name == draft.paymentMethod);
        paymentLabel = paymentEnum?.label;
      }
      String? recurrenceLabel;
      if (draft.recurrenceType != null) {
        switch (draft.recurrenceType) {
          case 'WEEKLY':
            recurrenceLabel = 'Hebdomadaire';
            break;
          case 'BIWEEKLY':
            recurrenceLabel = 'Toutes les 2 semaines';
            break;
          case 'MONTHLY':
            recurrenceLabel = 'Mensuelle';
            break;
          default:
            recurrenceLabel = 'Aucune';
        }
      }
      return _buildSection(
        title: 'Informations complémentaires',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
                'Date de collecte',
                draft.collectionDate != null
                    ? draft.collectionDate!.toLocal().toString().split(' ')[0]
                    : ''),
            _buildInfoRow(
                'Date de livraison',
                draft.deliveryDate != null
                    ? draft.deliveryDate!.toLocal().toString().split(' ')[0]
                    : ''),
            if (statusLabel != null)
              Row(
                children: [
                  if (statusIcon != null)
                    Icon(statusIcon, color: statusColor, size: 18),
                  SizedBox(width: 6),
                  _buildInfoRow('Statut', statusLabel),
                ],
              ),
            if (paymentLabel != null)
              _buildInfoRow('Méthode de paiement', paymentLabel),
            if (draft.affiliateCode != null && draft.affiliateCode!.isNotEmpty)
              _buildInfoRow('Code affilié', draft.affiliateCode!),
            if (recurrenceLabel != null && recurrenceLabel != 'Aucune')
              _buildInfoRow('Type de récurrence', recurrenceLabel),
            if (draft.nextRecurrenceDate != null &&
                draft.recurrenceType != null &&
                draft.recurrenceType != 'NONE')
              _buildInfoRow('Prochaine récurrence',
                  draft.nextRecurrenceDate!.toLocal().toString().split(' ')[0]),
          ],
        ),
      );
    });
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
      content: Obx(() {
        final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
        final items = controller.selectedArticleDetails;
        if (items.isEmpty) {
          return Text('Aucun article/service sélectionné',
              style: TextStyle(color: isDark ? Colors.white : Colors.black87));
        }
        return Column(
          children: items.map((item) {
            // Calcul du prix unitaire et du total de ligne selon premium ou non
            final bool isPremium = item['isPremium'] ?? false;
            final double unitPrice = isPremium
                ? (item['premiumPrice'] ?? item['basePrice'] ?? 0.0)
                : (item['basePrice'] ?? 0.0);
            final int quantity = item['quantity'] ?? 1;
            final double lineTotal = unitPrice * quantity;
            return OrderItemRecapCard(
              item: {
                ...item,
                'unitPrice': unitPrice,
                'lineTotal': lineTotal,
              },
              darkMode: isDark,
            );
          }).toList(),
        );
      }),
    );
  }

  Widget _buildTotalSection() {
    return Obx(() {
      final items = controller.getRecapOrderItems();
      final total = items.fold<double>(0, (sum, item) {
        // Utilise lineTotal si dispo, sinon fallback sur unitPrice * quantity
        final lineTotal = (item['lineTotal'] as num?)?.toDouble();
        if (lineTotal != null) return sum + lineTotal;
        final unitPrice = (item['unitPrice'] as num?)?.toDouble() ?? 0.0;
        final quantity = item['quantity'] is int
            ? item['quantity'] as int
            : (item['quantity'] as num?)?.toInt() ?? 1;
        return sum + (unitPrice * quantity);
      });
      return Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: AppRadius.radiusMD,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total estimé', style: AppTextStyles.h3),
            Text(
              '$total FCFA',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.orange,
              ),
            ),
          ],
        ),
      );
    });
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
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? Colors.white.withOpacity(0.7)
                  : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? Colors.white : null,
            ),
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
