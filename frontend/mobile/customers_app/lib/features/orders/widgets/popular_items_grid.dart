import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../shared/providers/flash_order_provider.dart';
import '../../../core/models/flash_order.dart';

/// 🎯 Grille d'Articles Populaires - Alpha Client App
///
/// Widget pour afficher et sélectionner les articles populaires
/// pour les commandes flash avec animations et feedback visuel.
class PopularItemsGrid extends StatelessWidget {
  const PopularItemsGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FlashOrderProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingPopularItems) {
          return _buildLoadingGrid(context);
        }

        if (provider.popularItems.isEmpty) {
          return _buildEmptyState(context);
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: provider.popularItems.length,
          itemBuilder: (context, index) {
            final item = provider.popularItems[index];
            return PopularItemCard(
              item: item,
              onTap: () => _showItemOptionsBottomSheet(context, item),
            );
          },
        );
      },
    );
  }

  /// 💀 Grille de chargement
  Widget _buildLoadingGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return GlassContainer(
          padding: const EdgeInsets.all(16),
          child: const Column(
            children: [
              SkeletonLoader(width: 60, height: 60),
              SizedBox(height: 12),
              SkeletonLoader(width: double.infinity, height: 16),
              SizedBox(height: 8),
              SkeletonLoader(width: 80, height: 14),
              Spacer(),
              SkeletonLoader(width: double.infinity, height: 36),
            ],
          ),
        );
      },
    );
  }

  /// 📭 État vide
  Widget _buildEmptyState(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.textTertiary(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun article disponible',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Veuillez réessayer plus tard',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary(context),
            ),
          ),
        ],
      ),
    );
  }

  /// 📋 Bottom sheet pour les options d'article
  void _showItemOptionsBottomSheet(
      BuildContext context, PopularFlashItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ItemOptionsBottomSheet(item: item),
    );
  }
}

/// 🎯 Carte d'Article Populaire
class PopularItemCard extends StatelessWidget {
  final PopularFlashItem item;
  final VoidCallback onTap;

  const PopularItemCard({
    Key? key,
    required this.item,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FlashOrderProvider>(
      builder: (context, provider, child) {
        final isInCart =
            provider.hasItem(item.articleId, item.serviceId, false);
        final quantity =
            provider.getItemQuantity(item.articleId, item.serviceId, false);

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: AnimatedContainer(
            duration: AppAnimations.fast,
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isInCart
                    ? AppColors.primary
                    : AppColors.surfaceVariant(context),
                width: isInCart ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isInCart
                      ? AppColors.primary.withOpacity(0.2)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: isInCart ? 12 : 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec icône et badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getIconData(item.iconName),
                          color: item.color,
                          size: 28,
                        ),
                      ),
                      if (item.isPopular)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'TOP',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.warning,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Nom de l'article
                  Text(
                    item.articleName,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Service
                  Text(
                    item.serviceName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Prix
                  Text(
                    'À partir de €${item.basePrice.toStringAsFixed(2)}',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Spacer(),

                  // Bouton d'action
                  SizedBox(
                    width: double.infinity,
                    child: isInCart
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Ajouté ($quantity)',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Ajouter',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 🎨 Obtenir l'icône depuis le nom
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'checkroom':
        return Icons.checkroom;
      case 'checkroom_outlined':
        return Icons.checkroom_outlined;
      case 'work_outline':
        return Icons.work_outline;
      case 'woman':
        return Icons.woman;
      case 'dry_cleaning':
        return Icons.dry_cleaning;
      default:
        return Icons.checkroom;
    }
  }
}

/// 📋 Bottom Sheet pour Options d'Article
class ItemOptionsBottomSheet extends StatefulWidget {
  final PopularFlashItem item;

  const ItemOptionsBottomSheet({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<ItemOptionsBottomSheet> createState() => _ItemOptionsBottomSheetState();
}

class _ItemOptionsBottomSheetState extends State<ItemOptionsBottomSheet> {
  int _quantity = 1;
  bool _isPremium = false;

  @override
  Widget build(BuildContext context) {
    final totalPrice =
        (_isPremium ? widget.item.basePrice * 1.5 : widget.item.basePrice) *
            _quantity;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // En-tête article
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: widget.item.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getIconData(widget.item.iconName),
                      color: widget.item.color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.articleName,
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.textPrimary(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          widget.item.serviceName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Sélecteur de quantité
              Text(
                'Quantité',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildQuantityButton(
                    context,
                    icon: Icons.remove,
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 60,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '$_quantity',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildQuantityButton(
                    context,
                    icon: Icons.add,
                    onPressed: _quantity < 10
                        ? () => setState(() => _quantity++)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Option Premium
              GestureDetector(
                onTap: () => setState(() => _isPremium = !_isPremium),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isPremium
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.surfaceVariant(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          _isPremium ? AppColors.primary : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isPremium
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: _isPremium
                            ? AppColors.primary
                            : AppColors.textSecondary(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Service Premium',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.textPrimary(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Traitement prioritaire (+50%)',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '+€${(widget.item.basePrice * 0.5 * _quantity).toStringAsFixed(2)}',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Résumé et bouton
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                        Text(
                          '€${totalPrice.toStringAsFixed(2)}',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    PremiumButton(
                      text: 'Ajouter au panier',
                      onPressed: _handleAddToCart,
                      icon: Icons.add_shopping_cart,
                      width: 180,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: onPressed != null
            ? AppColors.primary
            : AppColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: onPressed != null
              ? Colors.white
              : AppColors.textTertiary(context),
        ),
        onPressed: onPressed,
      ),
    );
  }

  void _handleAddToCart() {
    HapticFeedback.lightImpact();

    final provider = Provider.of<FlashOrderProvider>(context, listen: false);
    provider.addItem(
      widget.item,
      quantity: _quantity,
      isPremium: _isPremium,
    );

    Navigator.pop(context);

    // Feedback visuel
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.item.articleName} ajouté à votre commande'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'checkroom':
        return Icons.checkroom;
      case 'checkroom_outlined':
        return Icons.checkroom_outlined;
      case 'work_outline':
        return Icons.work_outline;
      case 'woman':
        return Icons.woman;
      case 'dry_cleaning':
        return Icons.dry_cleaning;
      default:
        return Icons.checkroom;
    }
  }
}
