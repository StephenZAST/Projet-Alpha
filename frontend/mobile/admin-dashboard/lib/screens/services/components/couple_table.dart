import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../widgets/shared/glass_container.dart';
import '../service_article_couples_screen.dart';

class CoupleTable extends StatelessWidget {
  final List<ArticleServiceCouple> couples;
  final void Function(ArticleServiceCouple) onEdit;
  final void Function(ArticleServiceCouple) onDelete;
  final void Function(ArticleServiceCouple) onToggleAvailability;

  const CoupleTable({
    Key? key,
    required this.couples,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleAvailability,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // En-tête du tableau
          _buildTableHeader(context, isDark),
          
          // Divider
          Divider(
            height: 1,
            color: isDark
                ? AppColors.gray700.withOpacity(0.3)
                : AppColors.gray200.withOpacity(0.5),
          ),
          
          // Corps du tableau
          Expanded(
            child: ListView.builder(
              itemCount: couples.length,
              itemBuilder: (context, index) {
                final couple = couples[index];
                return _buildTableRow(context, isDark, couple, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.gray900.withOpacity(0.3)
            : AppColors.gray50.withOpacity(0.8),
        borderRadius: BorderRadius.only(
          topLeft: AppRadius.radiusMD.topLeft,
          topRight: AppRadius.radiusMD.topRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Service',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Article',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Tarification',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Statut',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: 120), // Espace pour les actions
        ],
      ),
    );
  }

  Widget _buildTableRow(
      BuildContext context, bool isDark, ArticleServiceCouple couple, int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColors.gray700.withOpacity(0.2)
                : AppColors.gray200.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: InkWell(
        onTap: () => onEdit(couple),
        hoverColor: isDark
            ? AppColors.gray800.withOpacity(0.3)
            : AppColors.gray50.withOpacity(0.5),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Service (type + nom)
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getPricingTypeColor(couple.serviceTypePricingType).withOpacity(0.15),
                        borderRadius: AppRadius.radiusSM,
                      ),
                      child: Icon(
                        _getPricingTypeIcon(couple.serviceTypePricingType),
                        color: _getPricingTypeColor(couple.serviceTypePricingType),
                        size: 20,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            couple.serviceTypeName,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (couple.serviceName.isNotEmpty)
                            Text(
                              couple.serviceName,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textLight
                                    : AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Article
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.15),
                        borderRadius: AppRadius.radiusSM,
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.success,
                        size: 16,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            couple.articleName.isNotEmpty ? couple.articleName : 'Article non défini',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textLight
                                  : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (couple.articleDescription.isNotEmpty)
                            Text(
                              couple.articleDescription,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark ? AppColors.gray300 : AppColors.gray600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tarification
              Expanded(
                flex: 2,
                child: _buildPricingInfo(couple, isDark),
              ),

              // Statut
              Expanded(
                flex: 1,
                child: _buildStatusBadge(couple.isAvailable, isDark),
              ),

              // Actions
              SizedBox(
                width: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        couple.isAvailable ? Icons.toggle_on : Icons.toggle_off,
                        color: couple.isAvailable ? AppColors.success : AppColors.gray400,
                        size: 28,
                      ),
                      onPressed: () => onToggleAvailability(couple),
                      tooltip: couple.isAvailable ? 'Désactiver' : 'Activer',
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit(couple);
                            break;
                          case 'delete':
                            onDelete(couple);
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit_outlined, size: 18),
                            title: Text('Modifier'),
                            dense: true,
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete_outline,
                                size: 18, color: AppColors.error),
                            title: Text('Supprimer',
                                style: TextStyle(color: AppColors.error)),
                            dense: true,
                          ),
                        ),
                      ],
                      icon: Icon(
                        Icons.more_vert,
                        color: isDark ? AppColors.gray300 : AppColors.gray600,
                      ),
                      color: isDark ? AppColors.cardBgDark : AppColors.cardBgLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusMD,
                      ),
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

  Widget _buildPricingInfo(ArticleServiceCouple couple, bool isDark) {
    List<Widget> priceChips = [];

    if (couple.basePrice > 0) {
      priceChips.add(_buildPriceChip(
        'Base: ${couple.basePrice.toStringAsFixed(0)} FCFA',
        AppColors.primary,
        Icons.attach_money,
      ));
    }

    if (couple.premiumPrice > 0) {
      priceChips.add(_buildPriceChip(
        'Premium: ${couple.premiumPrice.toStringAsFixed(0)} FCFA',
        AppColors.warning,
        Icons.star,
      ));
    }

    if (couple.pricePerKg > 0) {
      priceChips.add(_buildPriceChip(
        '${couple.pricePerKg.toStringAsFixed(0)} FCFA/kg',
        AppColors.info,
        Icons.scale,
      ));
    }

    if (priceChips.isEmpty) {
      return Text(
        'Prix non défini',
        style: AppTextStyles.bodySmall.copyWith(
          color: isDark ? AppColors.gray400 : AppColors.gray600,
        ),
      );
    }

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: priceChips.take(2).toList(), // Limite à 2 chips pour éviter le débordement
    );
  }

  Widget _buildPriceChip(String label, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.radiusXS,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          SizedBox(width: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isAvailable, bool isDark) {
    Color color = isAvailable ? AppColors.success : AppColors.error;
    String text = isAvailable ? 'Disponible' : 'Indisponible';
    IconData icon = isAvailable ? Icons.check_circle : Icons.cancel;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPricingTypeColor(String? pricingType) {
    switch (pricingType) {
      case 'FIXED':
        return AppColors.success;
      case 'WEIGHT_BASED':
        return AppColors.warning;
      case 'SUBSCRIPTION':
        return AppColors.info;
      case 'CUSTOM':
        return AppColors.violet;
      default:
        return AppColors.gray500;
    }
  }

  IconData _getPricingTypeIcon(String? pricingType) {
    switch (pricingType) {
      case 'FIXED':
        return Icons.attach_money;
      case 'WEIGHT_BASED':
        return Icons.scale;
      case 'SUBSCRIPTION':
        return Icons.subscriptions;
      case 'CUSTOM':
        return Icons.tune;
      default:
        return Icons.help_outline;
    }
  }
}