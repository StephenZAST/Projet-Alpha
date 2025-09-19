import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../constants.dart';
import '../../../../models/order.dart';
import '../../../../widgets/shared/glass_container.dart';
import 'flash_order_detail_dialog.dart';

class FlashOrderCard extends StatefulWidget {
  final Order order;
  final VoidCallback onTap;
  
  const FlashOrderCard({
    Key? key,
    required this.order,
    required this.onTap,
  }) : super(key: key);

  @override
  _FlashOrderCardState createState() => _FlashOrderCardState();
}

class _FlashOrderCardState extends State<FlashOrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GlassContainer(
              variant: GlassContainerVariant.neutral,
              padding: EdgeInsets.all(AppSpacing.lg),
              borderRadius: AppRadius.lg,
              onTap: () => _showDetailDialog(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isDark),
                  SizedBox(height: AppSpacing.md),
                  _buildContent(isDark),
                  SizedBox(height: AppSpacing.md),
                  _buildFooter(isDark),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        // ID de la commande avec style moderne
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.2),
                AppColors.primary.withOpacity(0.1),
              ],
            ),
            borderRadius: AppRadius.radiusSM,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
            ),
          ),
          child: Text(
            '#${widget.order.id}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        Spacer(),
        
        // Badge Flash avec animation
        _FlashBadge(),
        
        SizedBox(width: AppSpacing.sm),
        
        // Bouton de conversion rapide
        _QuickConvertButton(
          onPressed: widget.onTap,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nom du client
        if (widget.order.customerName != null) ...[
          Row(
            children: [
              Icon(
                Icons.person,
                size: 16,
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  widget.order.customerName!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
        ],
        
        // Téléphone du client
        if (widget.order.customerPhone != null && widget.order.customerPhone!.isNotEmpty) ...[
          Row(
            children: [
              Icon(
                Icons.phone,
                size: 16,
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                widget.order.customerPhone!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.gray300 : AppColors.gray700,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
        ],
        
        // Adresse de livraison
        if (widget.order.deliveryAddress != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  widget.order.deliveryAddress!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.gray700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
        ],
        
        // Note de la commande
        if (widget.order.note != null && widget.order.note!.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.gray700 : AppColors.gray100).withOpacity(0.5),
              borderRadius: AppRadius.radiusSM,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.note,
                  size: 16,
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                ),
                SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    widget.order.note!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.gray300 : AppColors.gray700,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFooter(bool isDark) {
    return Row(
      children: [
        // Montant total
        if (widget.order.totalAmount != null) ...[
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withOpacity(0.2),
                  AppColors.success.withOpacity(0.1),
                ],
              ),
              borderRadius: AppRadius.radiusSM,
            ),
            child: Text(
              '${widget.order.totalAmount} FCFA',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        
        Spacer(),
        
        // Nombre d'articles
        if (widget.order.items != null && widget.order.items!.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.gray700 : AppColors.gray200).withOpacity(0.5),
              borderRadius: AppRadius.radiusSM,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shopping_bag,
                  size: 14,
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  '${widget.order.items!.length} article${widget.order.items!.length > 1 ? 's' : ''}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => FlashOrderDetailDialog(order: widget.order),
    );
  }
}

// Composants spécialisés pour la FlashOrderCard
class _FlashBadge extends StatefulWidget {
  @override
  _FlashBadgeState createState() => _FlashBadgeState();
}

class _FlashBadgeState extends State<_FlashBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.warning, AppColors.warning.withOpacity(0.8)],
              ),
              borderRadius: AppRadius.radiusSM,
              boxShadow: [
                BoxShadow(
                  color: AppColors.warning.withOpacity(0.4),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.flash_on,
                  color: Colors.white,
                  size: 14,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'FLASH',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickConvertButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isDark;

  const _QuickConvertButton({
    required this.onPressed,
    required this.isDark,
  });

  @override
  _QuickConvertButtonState createState() => _QuickConvertButtonState();
}

class _QuickConvertButtonState extends State<_QuickConvertButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.accent, AppColors.accent.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.4),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(18),
                  child: Center(
                    child: Icon(
                      Icons.transform,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
