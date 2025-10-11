import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../core/models/service_type.dart';

/// 🏷️ Card Type de Service - Alpha Client App
///
/// Affiche un type de service avec ses caractéristiques
class ServiceTypeCard extends StatelessWidget {
  final ServiceType serviceType;
  final VoidCallback? onTap;
  final bool isSelected;

  const ServiceTypeCard({
    Key? key,
    required this.serviceType,
    this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _getColorForType(serviceType.pricingType);
    
    return GlassContainer(
      onTap: onTap,
      isInteractive: onTap != null,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 12),
      boxShadow: isSelected 
          ? [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
              const BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ]
          : AppShadows.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icône
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(color: color, width: 2)
                      : null,
                ),
                child: Icon(
                  _getIconForType(serviceType.pricingType),
                  color: color,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              
              // Nom et type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceType.name,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getTypeLabel(serviceType.pricingType),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Indicateur de sélection
              if (isSelected)
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            serviceType.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Caractéristiques
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (serviceType.requiresWeight)
                _buildFeatureBadge(
                  context,
                  'Pesée requise',
                  Icons.scale,
                  AppColors.info,
                ),
              if (serviceType.supportsPremium)
                _buildFeatureBadge(
                  context,
                  'Option Premium',
                  Icons.workspace_premium,
                  AppColors.secondary,
                ),
              _buildFeatureBadge(
                context,
                serviceType.pricingType == 'FIXED' 
                    ? 'Prix fixe' 
                    : 'Prix au kg',
                Icons.attach_money,
                color,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForType(String pricingType) {
    switch (pricingType) {
      case 'FIXED':
        return AppColors.primary;
      case 'WEIGHT_BASED':
        return AppColors.accent;
      default:
        return AppColors.info;
    }
  }

  IconData _getIconForType(String pricingType) {
    switch (pricingType) {
      case 'FIXED':
        return Icons.inventory_2_outlined;
      case 'WEIGHT_BASED':
        return Icons.scale_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  String _getTypeLabel(String pricingType) {
    switch (pricingType) {
      case 'FIXED':
        return 'Tarification par article';
      case 'WEIGHT_BASED':
        return 'Tarification au poids';
      default:
        return 'Tarification mixte';
    }
  }
}
