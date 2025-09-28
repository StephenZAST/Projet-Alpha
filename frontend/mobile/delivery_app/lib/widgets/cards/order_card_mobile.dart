import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../models/delivery_order.dart';
import '../shared/glass_container.dart';

/// 📱 Card Commande Mobile - Alpha Delivery App
///
/// Widget optimisé tactile pour afficher les commandes.
/// Fonctionnalités : swipe actions, indicateurs visuels, navigation.
class OrderCardMobile extends StatefulWidget {
  final DeliveryOrder order;
  final VoidCallback? onTap;
  final Function(OrderStatus)? onStatusUpdate;
  final bool showActions;
  final EdgeInsetsGeometry? margin;

  const OrderCardMobile({
    Key? key,
    required this.order,
    this.onTap,
    this.onStatusUpdate,
    this.showActions = true,
    this.margin,
  }) : super(key: key);

  @override
  State<OrderCardMobile> createState() => _OrderCardMobileState();
}

class _OrderCardMobileState extends State<OrderCardMobile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.cardHover,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin:
                widget.margin ?? const EdgeInsets.only(bottom: AppSpacing.sm),
            child: GestureDetector(
              onTapDown: (_) => _onTapDown(),
              onTapUp: (_) => _onTapUp(),
              onTapCancel: () => _onTapCancel(),
              onTap: widget.onTap,
              child: GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    // =======================================================
                    // 📋 HEADER AVEC STATUT
                    // =======================================================
                    _buildHeader(isDark),

                    // =======================================================
                    // 📍 INFORMATIONS PRINCIPALES
                    // =======================================================
                    _buildMainInfo(isDark),

                    // =======================================================
                    // 🎯 ACTIONS RAPIDES
                    // =======================================================
                    if (widget.showActions) _buildActions(isDark),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 📋 Header avec ID et statut
  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: widget.order.status.color.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(MobileDimensions.radiusLG),
          topRight: Radius.circular(MobileDimensions.radiusLG),
        ),
      ),
      child: Row(
        children: [
          // ID de la commande
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Commande #${widget.order.shortId}',
                  style: AppTextStyles.h4.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${widget.order.customer.firstName} ${widget.order.customer.lastName}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Badge de statut
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: widget.order.status.color,
              borderRadius: AppRadius.radiusSM,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.order.status.icon,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  widget.order.status.displayName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Indicateur urgent
          if (widget.order.isUrgent) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.priority_high,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 📍 Informations principales
  Widget _buildMainInfo(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Adresse
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.order.address.fullAddress,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Informations temporelles et prix
          Row(
            children: [
              // Date/heure
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: 18,
                      color: isDark ? AppColors.gray400 : AppColors.gray500,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _getTimeInfo(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.gray300
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Prix total
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: AppRadius.radiusSM,
                ),
                child: Text(
                  '${widget.order.totalAmount?.toStringAsFixed(0) ?? '0'} FCFA',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Articles (aperçu)
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 18,
                color: isDark ? AppColors.gray400 : AppColors.gray500,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  '${widget.order.items.length} article(s) • ${_getItemsPreview()}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🎯 Actions rapides selon le statut
  Widget _buildActions(bool isDark) {
    final actions = _getAvailableActions();
    if (actions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        children: actions.map((action) {
          final isLast = action == actions.last;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: isLast ? 0 : AppSpacing.sm,
              ),
              child: _buildActionButton(action, isDark),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 🔘 Bouton d'action
  Widget _buildActionButton(_OrderAction action, bool isDark) {
    return GestureDetector(
      onTap: () => _handleAction(action),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: action.color.withOpacity(0.1),
          borderRadius: AppRadius.radiusSM,
          border: Border.all(
            color: action.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              action.icon,
              size: 18,
              color: action.color,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              action.label,
              style: AppTextStyles.bodySmall.copyWith(
                color: action.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎬 Animations tactiles
  void _onTapDown() {
    _animationController.forward();
  }

  void _onTapUp() {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  /// ⏰ Informations temporelles
  String _getTimeInfo() {
    final now = DateTime.now();

    if (widget.order.collectionDate != null) {
      final collection = widget.order.collectionDate!;
      final diff = collection.difference(now);

      if (diff.inDays > 0) {
        return 'Collecte dans ${diff.inDays}j';
      } else if (diff.inHours > 0) {
        return 'Collecte dans ${diff.inHours}h';
      } else if (diff.inMinutes > 0) {
        return 'Collecte dans ${diff.inMinutes}min';
      } else {
        return 'Collecte maintenant';
      }
    }

    if (widget.order.deliveryDate != null) {
      final delivery = widget.order.deliveryDate!;
      final diff = delivery.difference(now);

      if (diff.inDays > 0) {
        return 'Livraison dans ${diff.inDays}j';
      } else if (diff.inHours > 0) {
        return 'Livraison dans ${diff.inHours}h';
      } else if (diff.inMinutes > 0) {
        return 'Livraison dans ${diff.inMinutes}min';
      } else {
        return 'Livraison maintenant';
      }
    }

    return 'Pas de date définie';
  }

  /// 📦 Aperçu des articles
  String _getItemsPreview() {
    if (widget.order.items.isEmpty) return 'Aucun article';

    final firstItem = widget.order.items.first;
    if (widget.order.items.length == 1) {
      return firstItem.articleName;
    } else {
      return '${firstItem.articleName} +${widget.order.items.length - 1}';
    }
  }

  /// 🎯 Actions disponibles selon le statut
  List<_OrderAction> _getAvailableActions() {
    switch (widget.order.status) {
      case OrderStatus.PENDING:
        return [
          _OrderAction(
            label: 'Collecter',
            icon: Icons.local_shipping_outlined,
            color: AppColors.primary,
            status: OrderStatus.COLLECTING,
          ),
        ];

      case OrderStatus.COLLECTING:
        return [
          _OrderAction(
            label: 'Collectée',
            icon: Icons.check_circle_outline,
            color: AppColors.success,
            status: OrderStatus.COLLECTED,
          ),
        ];

      case OrderStatus.READY:
        return [
          _OrderAction(
            label: 'Livrer',
            icon: Icons.delivery_dining_outlined,
            color: AppColors.primary,
            status: OrderStatus.DELIVERING,
          ),
        ];

      case OrderStatus.DELIVERING:
        return [
          _OrderAction(
            label: 'Livrée',
            icon: Icons.done_all_outlined,
            color: AppColors.success,
            status: OrderStatus.DELIVERED,
          ),
        ];

      default:
        return [];
    }
  }

  /// 🎬 Gestion des actions
  void _handleAction(_OrderAction action) {
    if (widget.onStatusUpdate != null) {
      widget.onStatusUpdate!(action.status);
    }
  }
}

/// 🎯 Modèle d'action pour les commandes
class _OrderAction {
  final String label;
  final IconData icon;
  final Color color;
  final OrderStatus status;

  const _OrderAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.status,
  });
}
