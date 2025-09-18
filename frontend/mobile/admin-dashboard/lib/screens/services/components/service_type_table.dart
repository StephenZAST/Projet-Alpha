import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../widgets/shared/glass_container.dart';
import '../../../models/service_type.dart';

class ServiceTypeTable extends StatelessWidget {
  final List<ServiceType> serviceTypes;
  final void Function(ServiceType) onEdit;
  final void Function(ServiceType) onDelete;
  final void Function(ServiceType) onToggleStatus;

  const ServiceTypeTable({
    Key? key,
    required this.serviceTypes,
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
              itemCount: serviceTypes.length,
              itemBuilder: (context, index) {
                final serviceType = serviceTypes[index];
                return _buildTableRow(context, isDark, serviceType, index);
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
              'Type de Service',
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
            flex: 2,
            child: Text(
              'Caractéristiques',
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
      BuildContext context, bool isDark, ServiceType serviceType, int index) {
    return Container(
      // Effet de zébrage
      color: index % 2 == 0
          ? (isDark ? AppColors.gray900 : AppColors.gray50)
          : Colors.transparent,
      child: Container(
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
          onTap: () => onEdit(serviceType),
          hoverColor: isDark
              ? AppColors.gray800.withOpacity(0.3)
              : AppColors.gray50.withOpacity(0.5),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Type de service (nom + description)
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getPricingTypeColor(serviceType.pricingType)
                              .withOpacity(0.15),
                          borderRadius: AppRadius.radiusSM,
                        ),
                        child: Icon(
                          _getPricingTypeIcon(serviceType.pricingType),
                          color: _getPricingTypeColor(serviceType.pricingType),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              serviceType.name,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textLight
                                    : AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (serviceType.description != null &&
                                serviceType.description!.isNotEmpty)
                              Text(
                                serviceType.description!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isDark
                                      ? AppColors.gray300
                                      : AppColors.gray600,
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

                // Type de tarification
                Expanded(
                  flex: 2,
                  child: _buildPricingTypeChip(serviceType.pricingType, isDark),
                ),

                // Caractéristiques
                Expanded(
                  flex: 2,
                  child: _buildCharacteristicsChips(serviceType, isDark),
                ),

                // Statut
                Expanded(
                  flex: 1,
                  child:
                      _buildStatusBadge(serviceType.isActive ?? true, isDark),
                ),

                // Actions
                SizedBox(
                  width: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          serviceType.isActive == true
                              ? Icons.toggle_on
                              : Icons.toggle_off,
                          color: serviceType.isActive == true
                              ? AppColors.success
                              : AppColors.gray400,
                          size: 28,
                        ),
                        onPressed: () => onToggleStatus(serviceType),
                        tooltip: serviceType.isActive == true
                            ? 'Désactiver'
                            : 'Activer',
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              onEdit(serviceType);
                              break;
                            case 'delete':
                              onDelete(serviceType);
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
                        color: isDark
                            ? AppColors.cardBgDark
                            : AppColors.cardBgLight,
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
      ),
    );
  }

  Widget _buildPricingTypeChip(String? pricingType, bool isDark) {
    final color = _getPricingTypeColor(pricingType);
    final text = _getPricingTypeLabel(pricingType);
    final icon = _getPricingTypeIcon(pricingType);

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
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacteristicsChips(ServiceType serviceType, bool isDark) {
    List<Widget> chips = [];

    if (serviceType.requiresWeight == true) {
      chips.add(
          _buildFeatureChip('Poids', Icons.scale, AppColors.warning, isDark));
    }

    if (serviceType.supportsPremium == true) {
      chips.add(
          _buildFeatureChip('Premium', Icons.star, AppColors.violet, isDark));
    }

    if (serviceType.isDefault == true) {
      chips
          .add(_buildFeatureChip('Défaut', Icons.flag, AppColors.info, isDark));
    }

    if (chips.isEmpty) {
      return Text(
        'Aucune',
        style: AppTextStyles.bodySmall.copyWith(
          color: isDark ? AppColors.gray400 : AppColors.gray600,
        ),
      );
    }

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children:
          chips.take(2).toList(), // Limite à 2 chips pour éviter le débordement
    );
  }

  Widget _buildFeatureChip(
      String label, IconData icon, Color color, bool isDark) {
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

  Widget _buildStatusBadge(bool isActive, bool isDark) {
    Color color = isActive ? AppColors.success : AppColors.error;
    String text = isActive ? 'Actif' : 'Inactif';
    IconData icon = isActive ? Icons.check_circle : Icons.cancel;

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

  String _getPricingTypeLabel(String? pricingType) {
    switch (pricingType) {
      case 'FIXED':
        return 'Prix fixe';
      case 'WEIGHT_BASED':
        return 'Au poids';
      case 'SUBSCRIPTION':
        return 'Abonnement';
      case 'CUSTOM':
        return 'Personnalisé';
      default:
        return 'Non défini';
    }
  }
}
