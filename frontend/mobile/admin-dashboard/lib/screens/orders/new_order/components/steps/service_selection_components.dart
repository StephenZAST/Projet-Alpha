import 'package:flutter/material.dart';
import 'package:admin/constants.dart';
import 'package:admin/widgets/shared/glass_container.dart';
import '../../../../../models/service.dart';
import '../../../../../models/service_type.dart';

// Composants modernes pour ServiceSelectionStep

class ModernServiceTypeDropdown extends StatefulWidget {
  final ServiceType? value;
  final List<ServiceType> items;
  final ValueChanged<ServiceType?> onChanged;
  final bool isDark;

  const ModernServiceTypeDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.isDark,
  });

  @override
  ModernServiceTypeDropdownState createState() =>
      ModernServiceTypeDropdownState();
}

class ModernServiceTypeDropdownState extends State<ModernServiceTypeDropdown> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type de Service',
          style: AppTextStyles.bodyMedium.copyWith(
            color: widget.isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: (widget.isDark ? AppColors.gray700 : AppColors.gray100)
                .withOpacity(0.5),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: _isFocused
                  ? AppColors.primary.withOpacity(0.5)
                  : (widget.isDark ? AppColors.gray600 : AppColors.gray300)
                      .withOpacity(0.5),
            ),
          ),
          child: DropdownButtonFormField<ServiceType>(
            value: widget.value,
            style: AppTextStyles.bodyMedium.copyWith(
              color:
                  widget.isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Sélectionner le type de service',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: widget.isDark ? AppColors.gray400 : AppColors.gray600,
              ),
              prefixIcon: Icon(
                Icons.category,
                color: _isFocused
                    ? AppColors.primary
                    : (widget.isDark ? AppColors.gray400 : AppColors.gray600),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(AppSpacing.md),
            ),
            items: widget.items.map((type) {
              return DropdownMenuItem<ServiceType>(
                value: type,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        _getServiceTypeIcon(type.pricingType),
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type.name,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _getServiceTypeDescription(type.pricingType),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: widget.isDark
                                  ? AppColors.gray400
                                  : AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: widget.onChanged,
            onTap: () => setState(() => _isFocused = true),
            dropdownColor: widget.isDark ? AppColors.gray800 : Colors.white,
          ),
        ),
      ],
    );
  }

  IconData _getServiceTypeIcon(String? pricingType) {
    switch (pricingType) {
      case 'FIXED':
        return Icons.inventory;
      case 'WEIGHT_BASED':
        return Icons.scale;
      case 'SUBSCRIPTION':
        return Icons.subscriptions;
      case 'CUSTOM':
        return Icons.tune;
      default:
        return Icons.room_service;
    }
  }

  String _getServiceTypeDescription(String? pricingType) {
    switch (pricingType) {
      case 'FIXED':
        return 'Prix fixe par article';
      case 'WEIGHT_BASED':
        return 'Tarification au poids';
      case 'SUBSCRIPTION':
        return 'Service d\'abonnement';
      case 'CUSTOM':
        return 'Tarif personnalisé';
      default:
        return 'Service standard';
    }
  }
}

class ModernServiceDropdown extends StatefulWidget {
  final Service? value;
  final List<Service> items;
  final ValueChanged<Service?> onChanged;
  final bool isDark;
  final bool enabled;

  const ModernServiceDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.isDark,
    this.enabled = true,
  });

  @override
  ModernServiceDropdownState createState() => ModernServiceDropdownState();
}

class ModernServiceDropdownState extends State<ModernServiceDropdown> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Spécifique',
          style: AppTextStyles.bodyMedium.copyWith(
            color: widget.isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: (widget.isDark ? AppColors.gray700 : AppColors.gray100)
                .withOpacity(
              widget.enabled ? 0.5 : 0.3,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: _isFocused && widget.enabled
                  ? AppColors.primary.withOpacity(0.5)
                  : (widget.isDark ? AppColors.gray600 : AppColors.gray300)
                      .withOpacity(0.5),
            ),
          ),
          child: DropdownButtonFormField<Service>(
            value: widget.value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: widget.enabled
                  ? (widget.isDark
                      ? AppColors.textLight
                      : AppColors.textPrimary)
                  : (widget.isDark ? AppColors.gray500 : AppColors.gray400),
            ),
            decoration: InputDecoration(
              hintText: widget.enabled
                  ? 'Sélectionner le service'
                  : 'Sélectionnez d\'abord un type de service',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: widget.isDark ? AppColors.gray400 : AppColors.gray600,
              ),
              prefixIcon: Icon(
                Icons.room_service,
                color: _isFocused && widget.enabled
                    ? AppColors.primary
                    : (widget.isDark ? AppColors.gray400 : AppColors.gray600),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(AppSpacing.md),
            ),
            items: widget.enabled
                ? widget.items.map((service) {
                    return DropdownMenuItem<Service>(
                      value: service,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.accent,
                                  AppColors.accent.withOpacity(0.8)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.room_service,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.name,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (service.description != null) ...[
                                  Text(
                                    service.description!,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: widget.isDark
                                          ? AppColors.gray400
                                          : AppColors.gray600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList()
                : [],
            onChanged: widget.enabled ? widget.onChanged : null,
            onTap:
                widget.enabled ? () => setState(() => _isFocused = true) : null,
            dropdownColor: widget.isDark ? AppColors.gray800 : Colors.white,
          ),
        ),
      ],
    );
  }
}

class CategoryHeader extends StatelessWidget {
  final String name;
  final bool isDark;

  const CategoryHeader({
    required this.name,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withOpacity(0.2),
            AppColors.accent.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.category,
            color: AppColors.accent,
            size: 18,
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            name,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ArticleCard extends StatefulWidget {
  final Map<String, dynamic> couple;
  final int quantity;
  final bool isPremium;
  final Function(String, int) onQuantityChanged;
  final bool isDark;

  const ArticleCard({
    required this.couple,
    required this.quantity,
    required this.isPremium,
    required this.onQuantityChanged,
    required this.isDark,
  });

  @override
  ArticleCardState createState() => ArticleCardState();
}

class ArticleCardState extends State<ArticleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final articleId = widget.couple['article_id'];
    final articleName = widget.couple['article_name'] ?? '';
    final articleDescription = widget.couple['article_description'] ?? '';
    final basePrice =
        double.tryParse(widget.couple['base_price'].toString()) ?? 0.0;
    final premiumPrice =
        double.tryParse(widget.couple['premium_price'].toString()) ?? 0.0;
    final displayPrice = widget.isPremium ? premiumPrice : basePrice;
    final totalPrice = displayPrice * widget.quantity;

    return MouseRegion(
      onEnter: (_) {
        _controller.forward();
      },
      onExit: (_) {
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GlassContainer(
              variant: widget.quantity > 0
                  ? GlassContainerVariant.success
                  : GlassContainerVariant.neutral,
              padding: EdgeInsets.all(AppSpacing.md),
              borderRadius: AppRadius.md,
              child: Row(
                children: [
                  // Icône article
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.quantity > 0
                            ? [
                                AppColors.success,
                                AppColors.success.withOpacity(0.8)
                              ]
                            : [AppColors.gray500, AppColors.gray400],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.checkroom,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),

                  // Informations article
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          articleName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: widget.quantity > 0
                                ? Colors.white
                                : (widget.isDark
                                    ? AppColors.textLight
                                    : AppColors.textPrimary),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (articleDescription.isNotEmpty) ...[
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            articleDescription,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: widget.quantity > 0
                                  ? Colors.white.withOpacity(0.8)
                                  : (widget.isDark
                                      ? AppColors.gray400
                                      : AppColors.gray600),
                            ),
                          ),
                        ],
                        SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: widget.isPremium
                                    ? AppColors.warning.withOpacity(0.2)
                                    : AppColors.info.withOpacity(0.2),
                                borderRadius: AppRadius.radiusXS,
                              ),
                              child: Text(
                                widget.isPremium ? 'PREMIUM' : 'STANDARD',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: widget.isPremium
                                      ? AppColors.warning
                                      : AppColors.info,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text(
                              '${displayPrice.toStringAsFixed(0)} FCFA',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: widget.quantity > 0
                                    ? Colors.white
                                    : AppColors.info,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (widget.quantity > 0) ...[
                              SizedBox(width: AppSpacing.md),
                              Text(
                                'Total: ${totalPrice.toStringAsFixed(0)} FCFA',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Contrôles quantité
                  QuantityControls(
                    quantity: widget.quantity,
                    onChanged: (newQuantity) {
                      widget.onQuantityChanged(articleId, newQuantity);
                    },
                    isSelected: widget.quantity > 0,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class QuantityControls extends StatefulWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final bool isSelected;

  const QuantityControls({
    required this.quantity,
    required this.onChanged,
    this.isSelected = false,
  });

  @override
  QuantityControlsState createState() => QuantityControlsState();
}

class QuantityControlsState extends State<QuantityControls>
    with TickerProviderStateMixin {
  late AnimationController _minusController;
  late AnimationController _plusController;
  late Animation<double> _minusScale;
  late Animation<double> _plusScale;

  @override
  void initState() {
    super.initState();
    _minusController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _plusController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );

    _minusScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _minusController, curve: Curves.easeOutCubic),
    );
    _plusScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _plusController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _minusController.dispose();
    _plusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bouton moins
        GestureDetector(
          onTapDown: (_) => _minusController.forward(),
          onTapUp: (_) {
            _minusController.reverse();
            if (widget.quantity > 0) {
              widget.onChanged(widget.quantity - 1);
            }
          },
          onTapCancel: () => _minusController.reverse(),
          child: AnimatedBuilder(
            animation: _minusScale,
            builder: (context, child) {
              return Transform.scale(
                scale: _minusScale.value,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.isSelected
                          ? [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.2)
                            ]
                          : [AppColors.error, AppColors.error.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.remove,
                    color: widget.isSelected ? Colors.white : Colors.white,
                    size: 18,
                  ),
                ),
              );
            },
          ),
        ),

        // Affichage quantité
        Container(
          width: 50,
          child: Center(
            child: Text(
              '${widget.quantity}',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: widget.isSelected
                    ? Colors.white
                    : (widget.quantity > 0
                        ? AppColors.success
                        : AppColors.gray600),
              ),
            ),
          ),
        ),

        // Bouton plus
        GestureDetector(
          onTapDown: (_) => _plusController.forward(),
          onTapUp: (_) {
            _plusController.reverse();
            widget.onChanged(widget.quantity + 1);
          },
          onTapCancel: () => _plusController.reverse(),
          child: AnimatedBuilder(
            animation: _plusScale,
            builder: (context, child) {
              return Transform.scale(
                scale: _plusScale.value,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.isSelected
                          ? [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.2)
                            ]
                          : [
                              AppColors.success,
                              AppColors.success.withOpacity(0.8)
                            ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ModernWeightField extends StatefulWidget {
  final double? value;
  final ValueChanged<double?> onChanged;
  final bool isDark;

  const ModernWeightField({
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  ModernWeightFieldState createState() => ModernWeightFieldState();
}

class ModernWeightFieldState extends State<ModernWeightField> {
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(ModernWeightField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: _isFocused
              ? Colors.white.withOpacity(0.5)
              : Colors.white.withOpacity(0.2),
        ),
      ),
      child: TextFormField(
        controller: _controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        style: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white,
        ),
        onChanged: (value) {
          widget.onChanged(double.tryParse(value));
        },
        onTap: () => setState(() => _isFocused = true),
        onEditingComplete: () => setState(() => _isFocused = false),
        decoration: InputDecoration(
          hintText: 'Ex: 2.5',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white.withOpacity(0.6),
          ),
          prefixIcon: Icon(
            Icons.scale,
            color: _isFocused ? Colors.white : Colors.white.withOpacity(0.7),
            size: 20,
          ),
          suffixText: 'kg',
          suffixStyle: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppSpacing.md),
        ),
      ),
    );
  }
}

class ModernPremiumSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  const ModernPremiumSwitch({
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  ModernPremiumSwitchState createState() => ModernPremiumSwitchState();
}

class ModernPremiumSwitchState extends State<ModernPremiumSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: widget.value
                    ? LinearGradient(
                        colors: [
                          AppColors.warning.withOpacity(0.3),
                          AppColors.warning.withOpacity(0.2),
                        ],
                      )
                    : null,
                color: !widget.value
                    ? (widget.isDark ? AppColors.gray700 : AppColors.gray100)
                        .withOpacity(0.5)
                    : null,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: widget.value
                      ? AppColors.warning.withOpacity(0.5)
                      : (widget.isDark ? AppColors.gray600 : AppColors.gray300)
                          .withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: widget.value
                          ? LinearGradient(
                              colors: [
                                AppColors.warning,
                                AppColors.warning.withOpacity(0.8)
                              ],
                            )
                          : null,
                      color: !widget.value
                          ? (widget.isDark
                              ? AppColors.gray600
                              : AppColors.gray400)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service Premium',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: widget.isDark
                                ? AppColors.textLight
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          'Qualité supérieure et traitement prioritaire',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: widget.isDark
                                ? AppColors.gray400
                                : AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: widget.value,
                    onChanged: widget.onChanged,
                    activeColor: Colors.white,
                    activeTrackColor: AppColors.warning.withOpacity(0.8),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.white.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
