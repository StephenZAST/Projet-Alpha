import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import '../../../widgets/shared/app_button.dart';
import '../../../routes/admin_routes.dart';

class OrdersHeader extends StatelessWidget {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final OrdersController controller = Get.find<OrdersController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: defaultPadding),
      child: Column(
        children: [
          // En-tête principal avec titre et boutons d'action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Gestion des commandes",
                style: AppTextStyles.h2.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Row(
                children: [
                  AppButton(
                    label: "Commande Flash",
                    icon: Icons.flash_on,
                    variant: AppButtonVariant
                        .secondary, // Style différent pour distinguer
                    onPressed: () => AdminRoutes.goToFlashOrders(),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  AppButton(
                    label: "Nouvelle commande",
                    icon: Icons.add,
                    onPressed: () => Get.toNamed('/orders/create'),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: defaultPadding),

          // Barre de recherche et filtres
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Rechercher des commandes...",
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark
                          ? AppColors.textLight
                          : AppColors.textSecondary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.radiusMD,
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.radiusMD,
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                  ),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                  onChanged: controller.searchOrders,
                ),
              ),
              SizedBox(width: defaultPadding),
              // Ici vous pouvez ajouter d'autres filtres si nécessaire
            ],
          ),
        ],
      ),
    );
  }
}
