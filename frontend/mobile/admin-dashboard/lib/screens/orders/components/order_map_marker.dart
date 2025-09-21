import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../models/order_map.dart';

class OrderMapMarker extends StatefulWidget {
  final OrderMapData order;
  final VoidCallback onTap;
  final bool isSelected;

  const OrderMapMarker({
    Key? key,
    required this.order,
    required this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  _OrderMapMarkerState createState() => _OrderMapMarkerState();
}

class _OrderMapMarkerState extends State<OrderMapMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isSelected) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(OrderMapMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        if (!widget.isSelected) {
          _animationController.forward();
        }
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        if (!widget.isSelected) {
          _animationController.reverse();
        }
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final scale = widget.isSelected 
                ? _pulseAnimation.value 
                : (_isHovered ? _scaleAnimation.value : 1.0);

            return Transform.scale(
              scale: scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ombre/halo pour les marqueurs sélectionnés
                  if (widget.isSelected || _isHovered)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor.withOpacity(0.3),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),

                  // Marqueur principal
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor,
                      border: Border.all(
                        color: isDark ? AppColors.white : AppColors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _buildMarkerIcon(),
                    ),
                  ),

                  // Badge pour les commandes flash
                  if (widget.order.isFlashOrder)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent,
                          border: Border.all(
                            color: isDark ? AppColors.darkBg : AppColors.white,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.flash_on,
                          size: 8,
                          color: AppColors.white,
                        ),
                      ),
                    ),

                  // Tooltip avec informations de base
                  if (_isHovered || widget.isSelected)
                    Positioned(
                      bottom: 30,
                      child: _buildTooltip(isDark),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMarkerIcon() {
    IconData icon;
    Color iconColor = AppColors.white;

    switch (widget.order.status.toUpperCase()) {
      case 'PENDING':
        icon = Icons.schedule;
        break;
      case 'COLLECTING':
        icon = Icons.local_shipping;
        break;
      case 'COLLECTED':
        icon = Icons.inventory;
        break;
      case 'PROCESSING':
        icon = Icons.settings;
        break;
      case 'READY':
        icon = Icons.check_circle;
        break;
      case 'DELIVERING':
        icon = Icons.delivery_dining;
        break;
      case 'DELIVERED':
        icon = Icons.done_all;
        break;
      case 'CANCELLED':
        icon = Icons.cancel;
        break;
      default:
        icon = Icons.help;
    }

    return Icon(
      icon,
      size: 12,
      color: iconColor,
    );
  }

  Widget _buildTooltip(bool isDark) {
    return Container(
      constraints: BoxConstraints(maxWidth: 200),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.gray900.withOpacity(0.95)
            : AppColors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: isDark 
              ? AppColors.gray700.withOpacity(0.3)
              : AppColors.gray300.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ID de la commande
          Row(
            children: [
              Icon(
                Icons.receipt,
                size: 14,
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  '#${widget.order.id.substring(0, 8)}...',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),

          // Client
          Row(
            children: [
              Icon(
                Icons.person,
                size: 14,
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  widget.order.client.fullName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.gray700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),

          // Statut
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getStatusColor(),
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  _getStatusLabel(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.gray700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),

          // Montant
          if (widget.order.totalAmount != null)
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  size: 14,
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  '${widget.order.totalAmount!.toStringAsFixed(0)} FCFA',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

          // Adresse
          SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on,
                size: 14,
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  '${widget.order.address.street}, ${widget.order.address.city}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.gray700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (widget.order.status.toUpperCase()) {
      case 'PENDING':
        return AppColors.warning;
      case 'COLLECTING':
        return AppColors.info;
      case 'COLLECTED':
        return AppColors.success.withOpacity(0.8);
      case 'PROCESSING':
        return AppColors.primary;
      case 'READY':
        return AppColors.accent;
      case 'DELIVERING':
        return Color(0xFFFF7043); // Orange foncé
      case 'DELIVERED':
        return AppColors.success;
      case 'CANCELLED':
        return AppColors.error;
      default:
        return AppColors.gray500;
    }
  }

  String _getStatusLabel() {
    switch (widget.order.status.toUpperCase()) {
      case 'PENDING':
        return 'En attente';
      case 'COLLECTING':
        return 'Collecte';
      case 'COLLECTED':
        return 'Collecté';
      case 'PROCESSING':
        return 'En traitement';
      case 'READY':
        return 'Prêt';
      case 'DELIVERING':
        return 'En livraison';
      case 'DELIVERED':
        return 'Livré';
      case 'CANCELLED':
        return 'Annulé';
      default:
        return widget.order.status;
    }
  }
}