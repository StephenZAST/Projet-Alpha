import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../shared/providers/flash_order_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../core/models/flash_order.dart';

/// 📊 Résumé de Commande Flash - Alpha Client App
///
/// Widget pour afficher le résumé détaillé de la commande flash
/// avec calculs de prix et informations de livraison.
class FlashOrderSummary extends StatelessWidget {
  const FlashOrderSummary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<FlashOrderProvider, AuthProvider>(
      builder: (context, flashProvider, authProvider, child) {
        final flashOrder = flashProvider.currentFlashOrder;
        if (flashOrder == null || flashOrder.items.isEmpty) {
          return const SizedBox.shrink();
        }

        return GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Résumé de la commande',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Détails des articles
              _buildItemsBreakdown(context, flashOrder),

              const SizedBox(height: 16),
              Divider(color: AppColors.border(context)),
              const SizedBox(height: 16),

              // Calculs de prix
              _buildPriceBreakdown(context, flashOrder),

              const SizedBox(height: 16),
              Divider(color: AppColors.border(context)),
              const SizedBox(height: 16),

              // Informations de livraison
              _buildDeliveryInfo(context, authProvider),

              const SizedBox(height: 16),

              // Note importante
              _buildImportantNote(context),
            ],
          ),
        );
      },
    );
  }

  /// 📋 Détail des articles
  Widget _buildItemsBreakdown(BuildContext context, FlashOrder flashOrder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Articles (${flashOrder.totalItems})',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...flashOrder.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.quantity}× ${item.articleName}${item.isPremium ? ' (Premium)' : ''}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                  Text(
                    '€${item.totalPrice.toStringAsFixed(2)}',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  /// 💰 Détail des prix
  Widget _buildPriceBreakdown(BuildContext context, FlashOrder flashOrder) {
    final subtotal = flashOrder.totalEstimatedPrice;
    final premiumItems =
        flashOrder.items.where((item) => item.isPremium).toList();
    final premiumSurcharge = premiumItems.fold(
        0.0, (sum, item) => sum + (item.estimatedPrice * 0.5 * item.quantity));

    return Column(
      children: [
        // Sous-total
        _buildPriceRow(
          context,
          'Sous-total',
          '€${subtotal.toStringAsFixed(2)}',
          isSubtotal: true,
        ),

        // Supplément premium si applicable
        if (premiumSurcharge > 0) ...[
          const SizedBox(height: 8),
          _buildPriceRow(
            context,
            'Supplément Premium',
            '€${premiumSurcharge.toStringAsFixed(2)}',
            color: AppColors.warning,
          ),
        ],

        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _buildPriceRow(
            context,
            'Total estimé',
            '€${subtotal.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ),
      ],
    );
  }

  /// 💳 Ligne de prix
  Widget _buildPriceRow(
    BuildContext context,
    String label,
    String amount, {
    bool isSubtotal = false,
    bool isTotal = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color ??
                (isTotal
                    ? AppColors.textPrimary(context)
                    : AppColors.textSecondary(context)),
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          amount,
          style: AppTextStyles.labelLarge.copyWith(
            color: color ??
                (isTotal ? AppColors.primary : AppColors.textPrimary(context)),
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 🚚 Informations de livraison
  Widget _buildDeliveryInfo(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUser;
    final defaultAddress = user?.defaultAddress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Livraison',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        if (defaultAddress != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.success.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Adresse par défaut',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        defaultAddress.formattedAddress,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.warning.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_outlined,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Aucune adresse par défaut configurée',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 12),

        // Estimation de délai
        Row(
          children: [
            Icon(
              Icons.schedule,
              color: AppColors.info,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              'Délai estimé: 24-48h après validation',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// ⚠️ Note importante
  Widget _buildImportantNote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.info.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.info,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'À propos des commandes flash',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Votre commande sera créée en brouillon et notre équipe la validera avec les prix finaux dans les plus brefs délais.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
