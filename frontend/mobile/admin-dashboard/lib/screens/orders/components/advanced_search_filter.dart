import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';

class AdvancedSearchFilter extends StatelessWidget {
  final controller = Get.find<OrdersController>();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recherche avancée', style: AppTextStyles.bodyBold),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher une commande...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => controller.searchQuery.value = value,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                ElevatedButton(
                  onPressed: controller.applyFilters,
                  child: Text('Rechercher'),
                ),
                SizedBox(width: AppSpacing.sm),
                TextButton(
                  onPressed: controller.resetFilters,
                  child: Text('Réinitialiser'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
