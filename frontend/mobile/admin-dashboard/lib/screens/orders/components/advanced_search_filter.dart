import 'package:admin/widgets/glass_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';

class AdvancedSearchFilter extends StatelessWidget {
  final controller = Get.find<OrdersController>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recherche avancée', style: AppTextStyles.bodyBold),
            SizedBox(height: AppSpacing.md),
            // Ligne 1 : Recherche globale
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher une commande...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: isDark ? Colors.black12 : Colors.white,
                    ),
                    onChanged: (value) => controller.searchQuery.value = value,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            // Ligne 2 : Type de service, Méthode de paiement, Type de commande
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Type de service',
                      border: OutlineInputBorder(),
                    ),
                    value: controller.selectedServiceType.value,
                    items: controller.serviceTypes
                        .map((type) => DropdownMenuItem(
                              value: type.id,
                              child: Text(type.name),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        controller.selectedServiceType.value = value,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Méthode de paiement',
                      border: OutlineInputBorder(),
                    ),
                    value: controller.selectedPaymentMethod.value,
                    items: controller.paymentMethods
                        .map((method) => DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        controller.selectedPaymentMethod.value = value,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Type de commande',
                      border: OutlineInputBorder(),
                    ),
                    value: controller.selectedOrderType.value,
                    items: [
                      DropdownMenuItem(value: 'all', child: Text('Tous')),
                      DropdownMenuItem(value: 'flash', child: Text('Flash')),
                      DropdownMenuItem(
                          value: 'standard', child: Text('Standard')),
                    ],
                    onChanged: (value) =>
                        controller.selectedOrderType.value = value,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            // Ligne 3 : Plage de dates, Montant min/max
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Date de début',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.date_range),
                    ),
                    readOnly: true,
                    controller: controller.startDateController,
                    onTap: () => controller.pickStartDate(context),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Date de fin',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.date_range),
                    ),
                    readOnly: true,
                    controller: controller.endDateController,
                    onTap: () => controller.pickEndDate(context),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Montant min',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => controller.minAmount.value = value,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Montant max',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => controller.maxAmount.value = value,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            // Ligne 4 : Boutons actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GlassButton(
                  label: 'Réinitialiser',
                  onPressed: controller.resetFilters,
                  variant: GlassButtonVariant.secondary,
                  size: GlassButtonSize.medium,
                  isOutlined: true,
                ),
                SizedBox(width: AppSpacing.md),
                GlassButton(
                  label: 'Rechercher',
                  onPressed: controller.applyFilters,
                  icon: Icons.search,
                  variant: GlassButtonVariant.primary,
                  size: GlassButtonSize.medium,
                  isFullWidth: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
