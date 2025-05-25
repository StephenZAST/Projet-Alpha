import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import '../../../models/order.dart';
import '../../../models/enums.dart';
import '../../../theme/glass_style.dart'; // Ajout de l'import

class OrderDetails extends StatelessWidget {
  final isEditing = false.obs;
  final _editControllers = <String, TextEditingController>{}.obs;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final order = controller.selectedOrder.value;
      if (order == null) return Center(child: CircularProgressIndicator());

      // Initialiser les contrôleurs d'édition
      if (_editControllers.isEmpty) {
        _editControllers.addAll({
          'notes': TextEditingController(text: order.notes),
          'address': TextEditingController(text: order.deliveryAddress),
          'collectionDate': TextEditingController(
              text: order.collectionDate?.toString() ?? ''),
          'deliveryDate':
              TextEditingController(text: order.deliveryDate?.toString() ?? ''),
          'recurrenceType':
              TextEditingController(text: order.recurrenceType ?? 'NONE'),
        });
      }

      return Container(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            _buildHeader(context, order),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCustomerSection(context, order),
                    Divider(height: AppSpacing.xl),
                    _buildStatusSection(context, order),
                    Divider(height: AppSpacing.xl),
                    _buildAddressSection(context, order),
                    if (order.items?.isNotEmpty ?? false) ...[
                      Divider(height: AppSpacing.xl),
                      _buildItemsSection(context, order),
                    ],
                    Divider(height: AppSpacing.xl),
                    _buildNotesSection(context, order),
                  ],
                ),
              ),
            ),
            _buildActionButtons(context, order),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(BuildContext context, Order order) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Détails de la commande #${order.id}', style: AppTextStyles.h3),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Get.back(),
            tooltip: 'Fermer',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Order order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isEditing.value) ...[
            Container(
              decoration: GlassStyle.buttonDecoration(
                context: context,
                color: AppColors.error,
              ),
              child: TextButton.icon(
                icon: Icon(Icons.close, color: AppColors.error),
                label: Text(
                  'Annuler',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
                onPressed: () => isEditing.value = false,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Container(
              decoration: GlassStyle.buttonDecoration(
                context: context,
                color: AppColors.success,
                isSelected: true,
              ),
              child: TextButton.icon(
                icon: Icon(Icons.save, color: AppColors.success),
                label: Text(
                  'Enregistrer',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: AppColors.success,
                  ),
                ),
                onPressed: () => _saveChanges(order),
              ),
            ),
          ] else
            Container(
              decoration: GlassStyle.buttonDecoration(
                context: context,
                color: AppColors.primary,
                isSelected: false,
              ),
              child: TextButton.icon(
                icon: Icon(Icons.edit, color: AppColors.primary),
                label: Text(
                  'Modifier',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                onPressed: () => isEditing.value = true,
              ),
            ),
        ],
      ),
    );
  }

  void _saveChanges(Order order) async {
    try {
      final updatedData = {
        'notes': _editControllers['notes']?.text,
        'deliveryAddress': _editControllers['address']?.text,
        'collectionDate': _editControllers['collectionDate']?.text,
        'deliveryDate': _editControllers['deliveryDate']?.text,
        'recurrenceType': _editControllers['recurrenceType']?.text,
      };

      await Get.find<OrdersController>().updateOrder(order.id, updatedData);
      isEditing.value = false;
      Get.snackbar(
        'Succès',
        'Commande mise à jour avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour la commande',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    }
  }

  Widget _buildStatusSection(BuildContext context, Order order) {
    final status = order.status.toOrderStatus();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statut',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: status.color.withOpacity(0.1),
                borderRadius: AppRadius.radiusSM,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(status.icon, size: 16, color: status.color),
                  SizedBox(width: 4),
                  Text(
                    status.label,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: status.color,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerSection(BuildContext context, Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Client',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.customerName ?? 'N/A',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (order.customerEmail != null) ...[
                  SizedBox(height: 4),
                  Text(
                    order.customerEmail!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (order.customerPhone != null) ...[
                  SizedBox(height: 4),
                  Text(
                    order.customerPhone!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection(BuildContext context, Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adresse de livraison',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Obx(() {
          if (isEditing.value) {
            return TextField(
              controller: _editControllers['address'],
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Modifier l\'adresse',
              ),
            );
          } else {
            return Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text(
                  order.deliveryAddress ?? 'N/A',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            );
          }
        }),
      ],
    );
  }

  Widget _buildItemsSection(BuildContext context, Order order) {
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'fcfa',
      decimalDigits: 0,
    );

    if (order.items == null || order.items!.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Articles',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Card(
          margin: EdgeInsets.zero,
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: order.items!.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final item = order.items![index];
              return ListTile(
                title: Text(
                  item.name,
                  style: AppTextStyles.bodyMedium,
                ),
                subtitle: Text(
                  'Quantité: ${item.quantity}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: Text(
                  currencyFormat.format(item.total),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context, Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Obx(() {
          if (isEditing.value) {
            return TextField(
              controller: _editControllers['notes'],
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Modifier les notes',
              ),
              maxLines: 3,
            );
          } else {
            return Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text(
                  order.notes ?? 'Aucune note',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            );
          }
        }),
      ],
    );
  }
}
