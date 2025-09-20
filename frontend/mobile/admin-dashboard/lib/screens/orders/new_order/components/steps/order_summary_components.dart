import 'package:flutter/material.dart';
import 'package:admin/constants.dart';
import 'package:admin/widgets/shared/glass_container.dart';

// Composants modernes pour OrderSummaryStep

class SummarySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  final bool isDark;

  const SummarySection({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class SummaryInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isDark;
  final bool isMultiline;

  const SummaryInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    required this.isDark,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment:
            isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? AppColors.gray400 : AppColors.gray600,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.gray700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: valueColor ??
                    (isDark ? AppColors.textLight : AppColors.textPrimary),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
              maxLines: isMultiline ? null : 1,
              overflow: isMultiline ? null : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class ModernArticleCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool isDark;

  const ModernArticleCard({
    required this.item,
    required this.isDark,
  });

  @override
  ModernArticleCardState createState() => ModernArticleCardState();
}

class ModernArticleCardState extends State<ModernArticleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final articleName = widget.item['articleName'] ?? 'Article inconnu';
    final categoryName = widget.item['categoryName'] ?? '';
    final quantity = widget.item['quantity'] ?? 1;
    final unitPrice = widget.item['unitPrice'] ?? 0.0;
    final lineTotal = widget.item['lineTotal'] ?? 0.0;
    final isPremium = widget.item['isPremium'] ?? false;

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
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: (widget.isDark ? AppColors.gray700 : AppColors.gray100)
                    .withOpacity(0.5),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: (widget.isDark ? AppColors.gray600 : AppColors.gray300)
                      .withOpacity(0.5),
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Icône article
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isPremium
                            ? [
                                AppColors.warning,
                                AppColors.warning.withOpacity(0.8)
                              ]
                            : [
                                AppColors.accent,
                                AppColors.accent.withOpacity(0.8)
                              ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (isPremium ? AppColors.warning : AppColors.accent)
                                  .withOpacity(0.3),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        isPremium ? Icons.star : Icons.inventory_2,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),

                  // Informations article
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                articleName,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: widget.isDark
                                      ? AppColors.textLight
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isPremium)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.warning,
                                      AppColors.warning.withOpacity(0.8)
                                    ],
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Text(
                                  'PREMIUM',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (categoryName.isNotEmpty) ...[
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            categoryName,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: widget.isDark
                                  ? AppColors.gray400
                                  : AppColors.gray600,
                            ),
                          ),
                        ],
                        SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            // Quantité
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.info.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                                border: Border.all(
                                  color: AppColors.info.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.numbers,
                                    size: 12,
                                    color: AppColors.info,
                                  ),
                                  SizedBox(width: AppSpacing.xs),
                                  Text(
                                    'x$quantity',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.info,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: AppSpacing.sm),

                            // Prix unitaire
                            Text(
                              '${unitPrice.toStringAsFixed(0)} FCFA',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: widget.isDark
                                    ? AppColors.gray400
                                    : AppColors.gray600,
                              ),
                            ),

                            Spacer(),

                            // Total ligne
                            Text(
                              '${lineTotal.toStringAsFixed(0)} FCFA',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

class TotalCard extends StatefulWidget {
  final double total;
  final int itemCount;
  final bool isDark;

  const TotalCard({
    required this.total,
    required this.itemCount,
    required this.isDark,
  });

  @override
  TotalCardState createState() => TotalCardState();
}

class TotalCardState extends State<TotalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
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
          child: GlassContainer(
            variant: GlassContainerVariant.success,
            padding: EdgeInsets.all(AppSpacing.lg),
            borderRadius: AppRadius.lg,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.receipt_long,
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
                            'Total de la Commande',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${widget.itemCount} article${widget.itemCount > 1 ? 's' : ''}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${widget.total.toStringAsFixed(0)}',
                          style: AppTextStyles.h1.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                        Text(
                          'FCFA',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.white.withOpacity(0.8),
                        size: 18,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Ce montant est estimatif et peut varier selon les options choisies',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
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

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool isDark;

  const EmptyState({
    required this.icon,
    required this.message,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: isDark ? AppColors.gray400 : AppColors.gray500,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
