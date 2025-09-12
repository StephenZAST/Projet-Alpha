import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../widgets/shared/glass_container.dart';
import '../../../widgets/shared/glass_button.dart';

class OfferTable extends StatelessWidget {
  final List<Map<String, dynamic>> offers;
  final void Function(Map<String, dynamic>) onEdit;
  final void Function(Map<String, dynamic>) onDelete;
  final void Function(Map<String, dynamic>) onToggleStatus;

  const OfferTable({
    Key? key,
    required this.offers,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
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
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final offer = offers[index];
                return _buildTableRow(context, isDark, offer, index);
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
            flex: 3,
            child: Text(
              'Offre',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Type',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Valeur',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Période',
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
          SizedBox(width: 100), // Espace pour les actions
        ],
      ),
    );
  }

  Widget _buildTableRow(
      BuildContext context, bool isDark, Map<String, dynamic> offer, int index) {
    final bool isActive = offer['isActive'] ?? offer['is_active'] ?? false;
    final String discountType = offer['discountType'] ?? 'PERCENTAGE';
    final bool isExpired = _isOfferExpired(offer);

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
        onTap: () => onEdit(offer),
        hoverColor: isDark
            ? AppColors.gray800.withOpacity(0.3)
            : AppColors.gray50.withOpacity(0.5),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Offre (nom + description)
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isExpired
                                ? AppColors.error
                                : isActive
                                    ? AppColors.success
                                    : AppColors.warning,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            offer['name'] ?? 'Offre sans nom',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textLight
                                  : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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
                  ],
                ),
              ),

              // Type
              Expanded(
                flex: 2,
                child: _buildTypeChip(discountType, isDark),
              ),

              // Valeur
              Expanded(
                flex: 2,
                child: Text(
                  _formatDiscountValue(offer),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),

              // Période
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(offer['startDate']),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.textLight : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'au ${_formatDate(offer['endDate'])}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.gray300 : AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),

              // Statut
              Expanded(
                flex: 1,
                child: _buildStatusBadge(isActive, isExpired, isDark),
              ),

              // Actions
              SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        isActive ? Icons.toggle_on : Icons.toggle_off,
                        color: isActive ? AppColors.success : AppColors.gray400,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String discountType, bool isDark) {
    IconData icon;
    Color color;
    String label;

    switch (discountType) {
      case 'PERCENTAGE':
        icon = Icons.percent;
        color = AppColors.primary;
        label = 'Pourcentage';
        break;
      case 'FIXED_AMOUNT':
        icon = Icons.attach_money;
        color = AppColors.success;
        label = 'Montant fixe';
        break;
      case 'POINTS_EXCHANGE':
        icon = Icons.star;
        color = AppColors.warning;
        label = 'Points';
        break;
      default:
        icon = Icons.local_offer;
        color = AppColors.gray500;
        label = 'Autre';
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive, bool isExpired, bool isDark) {
    Color color;
    String text;
    IconData icon;

    if (isExpired) {
      color = AppColors.error;
      text = 'Expirée';
      icon = Icons.schedule;
    } else if (isActive) {
      color = AppColors.success;
      text = 'Active';
      icon = Icons.check_circle;
    } else {
      color = AppColors.warning;
      text = 'Inactive';
      icon = Icons.pause_circle;
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