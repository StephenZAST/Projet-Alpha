import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../core/models/service.dart';

/// 🛠️ Card Service - Alpha Client App
///
/// Affiche un service avec ses détails
class ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback? onTap;
  final bool showDetails;

  const ServiceCard({
    Key? key,
    required this.service,
    this.onTap,
    this.showDetails = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _getColorForService(service.name);
    
    return GlassContainer(
      onTap: onTap,
      isInteractive: onTap != null,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Icône
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getIconForService(service.name),
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          
          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  service.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showDetails && service.serviceTypeName != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      service.serviceTypeName!,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Flèche
          if (onTap != null)
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textTertiary(context),
              size: 16,
            ),
        ],
      ),
    );
  }

  Color _getColorForService(String serviceName) {
    final name = serviceName.toLowerCase();
    if (name.contains('nettoyage') || name.contains('sec')) {
      return AppColors.primary;
    } else if (name.contains('repassage') || name.contains('iron')) {
      return AppColors.warning;
    } else if (name.contains('retouche') || name.contains('ajust')) {
      return AppColors.info;
    } else if (name.contains('express') || name.contains('rapide')) {
      return AppColors.success;
    } else if (name.contains('premium') || name.contains('luxe')) {
      return AppColors.secondary;
    }
    return AppColors.accent;
  }

  IconData _getIconForService(String serviceName) {
    final name = serviceName.toLowerCase();
    if (name.contains('nettoyage') || name.contains('sec')) {
      return Icons.dry_cleaning;
    } else if (name.contains('repassage') || name.contains('iron')) {
      return Icons.iron;
    } else if (name.contains('retouche') || name.contains('ajust')) {
      return Icons.content_cut;
    } else if (name.contains('express') || name.contains('rapide')) {
      return Icons.flash_on;
    } else if (name.contains('premium') || name.contains('luxe')) {
      return Icons.workspace_premium;
    }
    return Icons.local_laundry_service;
  }
}
