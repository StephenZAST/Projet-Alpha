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
            // Ligne 2 : Type de service, Méthode de paiement, Type de commande, Code affilié, Type de récurrence
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Type de service',
                      border: OutlineInputBorder(),
                    ),
                    value: controller.selectedServiceType.value,
                    items: [
                      DropdownMenuItem(value: null, child: Text('Tous')),
                      ...controller.serviceTypes
                          .map((type) => DropdownMenuItem(
                                value: type.id,
                                child: Text(type.name),
                              ))
                          .toList(),
                    ],
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
                // Switch 'Commande flash' retiré, car les commandes flash ont leur propre page
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Code affilié',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.code),
                    ),
                    onChanged: (value) =>
                        controller.affiliateCode.value = value,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Type de récurrence',
                      border: OutlineInputBorder(),
                    ),
                    value: controller.selectedRecurrenceType.value,
                    items: controller.recurrenceTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        controller.selectedRecurrenceType.value = value,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            // Ligne 3 : Plages de dates, Montant min/max, Ville, Code postal, Récurrence
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Date de création début',
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
                      labelText: 'Date de création fin',
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
                      labelText: 'Date collecte début',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.event_available),
                    ),
                    readOnly: true,
                    controller: controller.collectionDateStartController,
                    onTap: () => controller.pickCollectionDateStart(context),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Date collecte fin',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.event_available),
                    ),
                    readOnly: true,
                    controller: controller.collectionDateEndController,
                    onTap: () => controller.pickCollectionDateEnd(context),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Date livraison début',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_shipping),
                    ),
                    readOnly: true,
                    controller: controller.deliveryDateStartController,
                    onTap: () => controller.pickDeliveryDateStart(context),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Date livraison fin',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_shipping),
                    ),
                    readOnly: true,
                    controller: controller.deliveryDateEndController,
                    onTap: () => controller.pickDeliveryDateEnd(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
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
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Ville',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    onChanged: (value) => controller.city.value = value,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Code postal',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.markunread_mailbox),
                    ),
                    onChanged: (value) => controller.postalCode.value = value,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: SwitchListTile(
                    title: Text('Récurrente'),
                    value: controller.isRecurring.value,
                    onChanged: (value) => controller.isRecurring.value = value,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            // Ligne 4 : Boutons actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: GlassButton(
                    label: 'Réinitialiser',
                    onPressed: controller.resetFilters,
                    variant: GlassButtonVariant.secondary,
                    size: GlassButtonSize.medium,
                    isOutlined: true,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: GlassButton(
                    label: 'Rechercher',
                    onPressed: controller.applyFilters,
                    icon: Icons.search,
                    variant: GlassButtonVariant.primary,
                    size: GlassButtonSize.medium,
                    isFullWidth: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
