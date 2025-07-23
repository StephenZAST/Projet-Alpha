import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import '../../../routes/admin_routes.dart';
import 'dart:ui';

class OrdersHeader extends StatelessWidget {
  final searchController = TextEditingController();

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool isSecondary = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: isSecondary
              ? [
                  AppColors.warning.withOpacity(0.2),
                  AppColors.warning.withOpacity(0.3),
                ]
              : [
                  AppColors.primary.withOpacity(0.2),
                  AppColors.primary.withOpacity(0.3),
                ],
        ),
        border: Border.all(
          color: isSecondary
              ? AppColors.warning.withOpacity(0.5)
              : AppColors.primary.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSecondary
                ? AppColors.warning.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.1),
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
              onTap: onPressed,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color:
                          isSecondary ? AppColors.warning : AppColors.primary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      label,
                      style: AppTextStyles.buttonMedium.copyWith(
                        color:
                            isSecondary ? AppColors.warning : AppColors.primary,
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
    );
  }

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
                  _buildActionButton(
                    label: "Commande Flash",
                    icon: Icons.flash_on,
                    onPressed: () => AdminRoutes.goToFlashOrders(),
                    isSecondary: true,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  _buildActionButton(
                    label: "Nouvelle commande",
                    icon: Icons.add,
                    onPressed: () => Get.toNamed('/orders/create'),
                    isSecondary: false,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: defaultPadding),

          // Barre de recherche supprimée, la recherche avancée la remplace
        ],
      ),
    );
  }
}
