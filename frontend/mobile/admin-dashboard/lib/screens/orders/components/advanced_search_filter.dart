import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import '../../../models/enums.dart';
import 'dart:ui';

class AdvancedSearchFilter extends StatelessWidget {
  final controller = Get.find<OrdersController>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recherche avancée', style: AppTextStyles.h3),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: controller.resetAdvancedSearch,
                  tooltip: 'Réinitialiser les filtres',
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                // ID et informations client
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'ID Commande',
                          prefixIcon: Icon(Icons.tag),
                        ),
                        onChanged: controller.setOrderId,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Nom/Prénom client',
                          prefixIcon: Icon(Icons.person),
                        ),
                        onChanged: controller.setCustomerName,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Email/Téléphone',
                          prefixIcon: Icon(Icons.contact_mail),
                        ),
                        onChanged: controller.setCustomerContact,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.lg),
                // Dates et montants
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Montant min',
                                prefixIcon: Icon(Icons.monetization_on),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) => controller
                                  .setMinAmount(double.tryParse(value) ?? 0),
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Montant max',
                                prefixIcon: Icon(Icons.monetization_on),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) => controller
                                  .setMaxAmount(double.tryParse(value) ?? 0),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() => DropdownButtonFormField<bool>(
                                  value: controller.paymentStatus.value,
                                  decoration: InputDecoration(
                                    labelText: 'Statut paiement',
                                    prefixIcon: Icon(Icons.payment),
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: null,
                                      child: Text('Tous'),
                                    ),
                                    DropdownMenuItem(
                                      value: true,
                                      child: Text('Payé'),
                                    ),
                                    DropdownMenuItem(
                                      value: false,
                                      child: Text('Non payé'),
                                    ),
                                  ],
                                  onChanged: controller.setPaymentStatus,
                                )),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Adresse',
                                prefixIcon: Icon(Icons.location_on),
                              ),
                              onChanged: controller.setAddress,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                AppColors.primary.withOpacity(0.2),
                                AppColors.primary.withOpacity(0.3),
                              ]
                            : [
                                AppColors.primary.withOpacity(0.1),
                                AppColors.primary.withOpacity(0.2),
                              ],
                      ),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.5),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => controller.applyAdvancedSearch(),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.search_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Rechercher',
                                    style: AppTextStyles.buttonMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.1),
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.refresh_rounded),
                      onPressed: controller.resetAdvancedSearch,
                      tooltip: 'Réinitialiser',
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
