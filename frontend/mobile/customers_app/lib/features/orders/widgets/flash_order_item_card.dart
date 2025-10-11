import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../shared/providers/flash_order_provider.dart';
import '../../../core/models/flash_order.dart';

/// 🛍️ Carte d'Article de Commande Flash - Alpha Client App
///
/// Widget pour afficher un article dans la commande flash actuelle
/// avec contrôles de quantité et options de modification.
class FlashOrderItemCard extends StatelessWidget {
  final FlashOrderItem item;

  const FlashOrderItemCard({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // En-tête avec informations article
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône article
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getArticleIcon(item.articleName),
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),

              // Informations article
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.articleName,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.textPrimary(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (item.isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'PREMIUM',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.warning,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.serviceName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '€${item.estimatedPrice.toStringAsFixed(2)} × ${item.quantity}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Prix total
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '€${item.totalPrice.toStringAsFixed(2)}',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  // Bouton supprimer
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    onPressed: () => _handleRemoveItem(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Contrôles de quantité
          Row(
            children: [
              Text(
                'Quantité:',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
              const Spacer(),
              _buildQuantityControls(context),
            ],
          ),

          // Notes si présentes
          if (item.notes != null && item.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes:',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.notes!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 🔢 Contrôles de quantité
  Widget _buildQuantityControls(BuildContext context) {
    return Consumer<FlashOrderProvider>(
      builder: (context, provider, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bouton diminuer
            _buildQuantityButton(
              context: context,
              icon: Icons.remove,
              onPressed: item.quantity > 1
                  ? () => _handleQuantityChange(context, item.quantity - 1)
                  : null,
            ),

            const SizedBox(width: 12),

            // Affichage quantité
            Container(
              width: 40,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${item.quantity}',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Bouton augmenter
            _buildQuantityButton(
              context: context,
              icon: Icons.add,
              onPressed: item.quantity < 10
                  ? () => _handleQuantityChange(context, item.quantity + 1)
                  : null,
            ),
          ],
        );
      },
    );
  }

  /// 🔘 Bouton de quantité
  Widget _buildQuantityButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: onPressed != null
            ? AppColors.primary
            : AppColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: onPressed != null
              ? Colors.white
              : AppColors.textTertiary(context),
          size: 18,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  /// 🎯 Gestionnaire de changement de quantité
  void _handleQuantityChange(BuildContext context, int newQuantity) {
    HapticFeedback.lightImpact();

    final provider = Provider.of<FlashOrderProvider>(context, listen: false);
    provider.updateItemQuantity(
      item.articleId,
      item.serviceId,
      item.isPremium,
      newQuantity,
    );
  }

  /// 🗑️ Gestionnaire de suppression d'article
  void _handleRemoveItem(BuildContext context) {
    HapticFeedback.lightImpact();

    // Confirmation avant suppression
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Supprimer l\'article ?',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
          ),
        ),
        content: Text(
          'Voulez-vous retirer "${item.articleName}" de votre commande ?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          PremiumButton(
            text: 'Supprimer',
            onPressed: () {
              final provider =
                  Provider.of<FlashOrderProvider>(context, listen: false);
              provider.removeItem(
                item.articleId,
                item.serviceId,
                item.isPremium,
              );
              Navigator.pop(context);

              // Feedback
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.articleName} supprimé'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            backgroundColor: AppColors.error,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
        ],
      ),
    );
  }

  /// 🎨 Obtenir l'icône selon le type d'article
  IconData _getArticleIcon(String articleName) {
    final name = articleName.toLowerCase();

    if (name.contains('chemise') || name.contains('shirt')) {
      return Icons.checkroom;
    } else if (name.contains('pantalon') || name.contains('pants')) {
      return Icons.checkroom_outlined;
    } else if (name.contains('costume') || name.contains('suit')) {
      return Icons.work_outline;
    } else if (name.contains('robe') || name.contains('dress')) {
      return Icons.woman;
    } else if (name.contains('veste') || name.contains('jacket')) {
      return Icons.checkroom;
    } else if (name.contains('manteau') || name.contains('coat')) {
      return Icons.checkroom;
    } else {
      return Icons.checkroom;
    }
  }
}
