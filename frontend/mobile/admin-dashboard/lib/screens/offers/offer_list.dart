import 'package:flutter/material.dart';
import 'dart:ui';
import '../../constants.dart';
import '../../widgets/shared/glass_container.dart';
import '../../widgets/shared/glass_button.dart';

class OfferList extends StatelessWidget {
  final List<Map<String, dynamic>> offers;
  final void Function(Map<String, dynamic>) onEdit;
  final void Function(Map<String, dynamic>) onDelete;
  final void Function(Map<String, dynamic>) onToggleStatus;

  const OfferList({
    Key? key,
    required this.offers,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (offers.isEmpty) {
      return Center(
        child: GlassContainer(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: AppRadius.radiusXL,
                ),
                child: Icon(
                  Icons.local_offer_outlined,
                  size: 40,
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                "Aucune offre disponible",
                style: AppTextStyles.h4.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                "Créez votre première offre pour commencer",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return GlassContainer(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        itemCount: offers.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: isDark
              ? AppColors.gray700.withOpacity(0.2)
              : AppColors.gray200.withOpacity(0.3),
        ),
        itemBuilder: (context, index) {
          final offer = offers[index];
          return _buildOfferItem(context, offer, isDark);
        },
      ),
    );
  }

  Widget _buildOfferItem(
      BuildContext context, Map<String, dynamic> offer, bool isDark) {
    final bool isActive = offer['isActive'] ?? offer['is_active'] ?? false;
    final String discountType = offer['discountType'] ?? 'PERCENTAGE';
    final bool isExpired = _isOfferExpired(offer);

    return InkWell(
      onTap: () => onEdit(offer),
      hoverColor: isDark
          ? AppColors.gray800.withOpacity(0.3)
          : AppColors.gray50.withOpacity(0.5),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            // Icône et indicateur de statut
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getTypeColor(discountType).withOpacity(0.15),
                    borderRadius: AppRadius.radiusMD,
                  ),
                  child: Icon(
                    _getOfferIcon(discountType),
                    color: _getTypeColor(discountType),
                    size: 24,
                  ),
                ),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isExpired
                          ? AppColors.error
                          : isActive
                              ? AppColors.success
                              : AppColors.warning,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.gray800 : AppColors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(width: AppSpacing.md),

            // Contenu principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          offer['name'] ?? 'Offre sans nom',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textLight
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildTypeChip(discountType, isDark),
                    ],
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    offer['description'] ?? 'Aucune description',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.gray300 : AppColors.gray600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      // Valeur de la remise
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: AppRadius.radiusSM,
                        ),
                        child: Text(
                          _formatDiscountValue(offer),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      // Période
                      if (offer['endDate'] != null)
                        Text(
                          'Expire le ${_formatDate(offer['endDate'])}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isExpired
                                ? AppColors.error
                                : isDark
                                    ? AppColors.gray400
                                    : AppColors.gray600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: AppSpacing.md),

            // Actions
            Column(
              children: [
                _buildStatusBadge(isActive, isExpired, isDark),
                SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        isActive ? Icons.toggle_on : Icons.toggle_off,
                        color: isActive ? AppColors.success : AppColors.gray400,
                        size: 28,
                      ),
                      onPressed: () => onToggleStatus(offer),
                      tooltip: isActive ? 'Désactiver' : 'Activer',
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit(offer);
                            break;
                          case 'delete':
                            onDelete(offer);
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String discountType, bool isDark) {
    final color = _getTypeColor(discountType);
    final label = _getTypeLabel(discountType);

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
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive, bool isExpired, bool isDark) {
    Color color;
    String text;

    if (isExpired) {
      color = AppColors.error;
      text = 'Expirée';
    } else if (isActive) {
      color = AppColors.success;
      text = 'Active';
    } else {
      color = AppColors.warning;
      text = 'Inactive';
    }

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
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getOfferIcon(String discountType) {
    switch (discountType) {
      case 'PERCENTAGE':
        return Icons.percent;
      case 'FIXED_AMOUNT':
        return Icons.attach_money;
      case 'POINTS_EXCHANGE':
        return Icons.star;
      default:
        return Icons.local_offer;
    }
  }

  Color _getTypeColor(String discountType) {
    switch (discountType) {
      case 'PERCENTAGE':
        return AppColors.primary;
      case 'FIXED_AMOUNT':
        return AppColors.success;
      case 'POINTS_EXCHANGE':
        return AppColors.warning;
      default:
        return AppColors.gray500;
    }
  }

  String _getTypeLabel(String discountType) {
    switch (discountType) {
      case 'PERCENTAGE':
        return 'Pourcentage';
      case 'FIXED_AMOUNT':
        return 'Montant fixe';
      case 'POINTS_EXCHANGE':
        return 'Points';
      default:
        return 'Autre';
    }
  }

  String _formatDiscountValue(Map<String, dynamic> offer) {
    final discountType = offer['discountType'] ?? 'PERCENTAGE';
    final discountValue = offer['discountValue'] ?? offer['discount'] ?? 0;

    switch (discountType) {
      case 'PERCENTAGE':
        return '${discountValue.toString()}%';
      case 'FIXED_AMOUNT':
        return '${discountValue.toString()} FCFA';
      case 'POINTS_EXCHANGE':
        final points = offer['pointsRequired'] ?? 0;
        return '$points pts';
      default:
        return discountValue.toString();
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  bool _isOfferExpired(Map<String, dynamic> offer) {
    final endDate = offer['endDate'];
    if (endDate == null) return false;
    try {
      final date = DateTime.parse(endDate);
      return date.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }
}
