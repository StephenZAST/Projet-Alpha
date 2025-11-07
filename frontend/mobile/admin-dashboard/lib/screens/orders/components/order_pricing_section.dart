import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin/controllers/orders_controller.dart';
import '../../../constants.dart';
import '../../../widgets/shared/glass_container.dart';
import 'order_pricing_components.dart';
import 'order_pricing_dialogs.dart';

/// Section complète de gestion du pricing et du paiement
/// 
/// Affiche :
/// - Prix original, manuel (si applicable), remise, prix final
/// - Badge de statut de paiement (Payée/Non payée)
/// - Date de paiement (si payée)
/// - Boutons d'action : Modifier prix, Réinitialiser, Marquer payée/non payée
/// 
/// Utilise Obx pour la réactivité et gère les états de chargement.
Widget buildPricingSection(
  BuildContext context,
  dynamic order,
  OrdersController controller,
  bool isDark,
) {
  return Obx(() {
    final pricing = controller.orderPricing;
    final isLoading = controller.pricingLoading.value;

    // Valeurs par défaut si pricing vide
    final originalPrice =
        pricing['originalPrice'] as double? ?? order.totalAmount ?? 0.0;
    final manualPrice = pricing['manualPrice'] as double?;
    final displayPrice =
        pricing['displayPrice'] as double? ?? originalPrice;
    final discount = pricing['discount'] as double?;
    final discountPercentage = pricing['discountPercentage'] as double?;
    final isPaid = pricing['isPaid'] as bool? ?? false;
    final paidAt = pricing['paidAt'] as String?;

    return GlassContainer(
      variant: GlassContainerVariant.primary,
      padding: EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === HEADER ===
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withOpacity(0.8),
                      AppColors.accent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.payments,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paiement & Prix',
                      style: AppTextStyles.h3.copyWith(
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'Gestion du prix et du statut de paiement',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.gray400
                            : AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge paiement
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isPaid
                      ? AppColors.success.withOpacity(0.15)
                      : AppColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isPaid
                        ? AppColors.success.withOpacity(0.5)
                        : AppColors.warning.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPaid ? Icons.check_circle : Icons.pending,
                      color: isPaid ? AppColors.success : AppColors.warning,
                      size: 18,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      isPaid ? 'Payée' : 'Non payée',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isPaid
                            ? AppColors.success
                            : AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),

          // === AFFICHAGE DES PRIX ===
          if (isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Column(
              children: [
                // Prix original
                PricingRow(
                  label: 'Prix original',
                  value: '${originalPrice.toStringAsFixed(2)} FCFA',
                  isDark: isDark,
                ),
                SizedBox(height: AppSpacing.md),

                // Prix manuel (si applicable)
                if (manualPrice != null) ...[
                  PricingRow(
                    label: 'Prix manuel',
                    value: '${manualPrice.toStringAsFixed(2)} FCFA',
                    isDark: isDark,
                    highlight: true,
                  ),
                  SizedBox(height: AppSpacing.md),

                  // ✅ AFFICHAGE DE LA COMPARAISON PRIX ORIGINAL vs PRIX MANUEL
                  Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: discount != null && discount > 0
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: discount != null && discount > 0
                            ? AppColors.success.withOpacity(0.3)
                            : AppColors.warning.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              discount != null && discount > 0
                                  ? Icons.trending_down
                                  : Icons.trending_up,
                              color: discount != null && discount > 0
                                  ? AppColors.success
                                  : AppColors.warning,
                              size: 20,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                discount != null && discount > 0
                                    ? 'Réduction appliquée'
                                    : 'Augmentation appliquée',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: discount != null && discount > 0
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Montant:',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.gray300
                                    : AppColors.gray700,
                              ),
                            ),
                            Text(
                              '${discount != null && discount > 0 ? '-' : '+'}${discount?.abs().toStringAsFixed(2) ?? '0.00'} FCFA',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: discount != null && discount > 0
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                        if (discountPercentage != null) ...[
                          SizedBox(height: AppSpacing.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pourcentage:',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isDark
                                      ? AppColors.gray300
                                      : AppColors.gray700,
                                ),
                              ),
                              Text(
                                '${discount != null && discount > 0 ? '-' : '+'}${discountPercentage!.abs().toStringAsFixed(1)}%',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: discount != null && discount > 0
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                ],

                // Prix final
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Prix final',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textLight
                              : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${displayPrice.toStringAsFixed(2)} FCFA',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Date de paiement (si payée)
                if (isPaid && paidAt != null) ...[
                  SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: isDark
                            ? AppColors.gray400
                            : AppColors.gray600,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'Payée le: $paidAt',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.gray400
                              : AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

          SizedBox(height: AppSpacing.lg),

          // === BOUTONS D'ACTION ===
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              // Modifier prix
              PricingActionButton(
                icon: Icons.edit,
                label: 'Modifier prix',
                isLoading: isLoading,
                onPressed: () => showManualPriceDialog(
                  context,
                  order.id,
                  controller,
                ),
              ),

              // Reset prix
              if (manualPrice != null)
                PricingActionButton(
                  icon: Icons.refresh,
                  label: 'Réinitialiser',
                  isLoading: isLoading,
                  variant: PricingButtonVariant.secondary,
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Réinitialiser le prix ?'),
                        content: Text(
                          'Cela supprimera le prix manuel et reviendra au prix original.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(ctx).pop(false),
                            child: Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.of(ctx).pop(true),
                            child: Text('Réinitialiser'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await controller
                          .resetManualPriceForOrder(order.id);
                    }
                  },
                ),

              // Marquer payée/non payée
              PricingActionButton(
                icon: isPaid ? Icons.cancel : Icons.check_circle,
                label: isPaid ? 'Marquer non payée' : 'Marquer payée',
                isLoading: isLoading,
                variant: isPaid
                    ? PricingButtonVariant.error
                    : PricingButtonVariant.success,
                onPressed: () => showPaymentReasonDialog(
                  context,
                  order.id,
                  controller,
                  !isPaid,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  });
}
