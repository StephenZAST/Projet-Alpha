import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../constants.dart';
import '../../../../components/glass_components.dart';
import '../../../../shared/providers/order_draft_provider.dart';
import '../../../../core/models/service_type.dart';
import '../../../../core/models/service.dart';

/// 🛠️ Étape de Sélection de Service - Alpha Client App
///
/// Deuxième étape du workflow : sélection du type de service puis du service.
/// Workflow en cascade optimisé pour mobile : ServiceType → Service
class ServiceSelectionStep extends StatefulWidget {
  const ServiceSelectionStep({Key? key}) : super(key: key);

  @override
  State<ServiceSelectionStep> createState() => _ServiceSelectionStepState();
}

class _ServiceSelectionStepState extends State<ServiceSelectionStep> 
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: AppAnimations.fadeIn,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderDraftProvider>(
      builder: (context, provider, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(context),
                const SizedBox(height: 24),
                
                // Sélection du type de service
                _buildServiceTypeSection(context, provider),
                
                // Sélection du service (si type sélectionné)
                if (provider.selectedServiceType != null) ...[
                  const SizedBox(height: 32),
                  _buildServiceSection(context, provider),
                ],
                
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        );
      },
    );
  }

  /// 📋 En-tête de l'étape
  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type de Service',
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choisissez le type de service qui correspond à vos besoins.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  /// 🏷️ Section des types de service
  Widget _buildServiceTypeSection(BuildContext context, OrderDraftProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Types Disponibles',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        if (provider.serviceTypes.isEmpty)
          _buildEmptyState(context, 'Aucun type de service disponible')
        else
          ...provider.serviceTypes.map((serviceType) => 
            _buildServiceTypeCard(context, serviceType, provider)
          ),
      ],
    );
  }

  /// 🏷️ Carte de type de service
  Widget _buildServiceTypeCard(
    BuildContext context,
    ServiceType serviceType,
    OrderDraftProvider provider,
  ) {
    final isSelected = provider.selectedServiceType?.id == serviceType.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        onTap: () {
          HapticFeedback.lightImpact();
          provider.selectServiceType(serviceType);
        },
        child: Row(
          children: [
            // Indicateur de sélection
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border(context),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            
            // Icône du type de service
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getServiceTypeColor(serviceType).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getServiceTypeIcon(serviceType),
                color: _getServiceTypeColor(serviceType),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Informations du type de service
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        serviceType.name,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (serviceType.supportsPremium) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Premium',
                            style: AppTextStyles.overline.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    serviceType.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildServiceTypeFeature(
                        context,
                        serviceType.pricingTypeEnum.displayName,
                        Icons.attach_money,
                        AppColors.success,
                      ),
                      if (serviceType.requiresWeight) ...[
                        const SizedBox(width: 12),
                        _buildServiceTypeFeature(
                          context,
                          'Pesée requise',
                          Icons.scale,
                          AppColors.info,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Indicateur de sélection visuel
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  /// 🛠️ Section des services
  Widget _buildServiceSection(BuildContext context, OrderDraftProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.arrow_forward,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Services Disponibles',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (provider.isLoading)
          _buildLoadingState(context)
        else if (provider.services.isEmpty)
          _buildEmptyState(context, 'Aucun service disponible pour ce type')
        else
          ...provider.services.map((service) => 
            _buildServiceCard(context, service, provider)
          ),
      ],
    );
  }

  /// 🛠️ Carte de service
  Widget _buildServiceCard(
    BuildContext context,
    Service service,
    OrderDraftProvider provider,
  ) {
    final isSelected = provider.selectedService?.id == service.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        onTap: () {
          HapticFeedback.lightImpact();
          provider.selectService(service);
        },
        child: Row(
          children: [
            // Indicateur de sélection
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.info : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.info : AppColors.border(context),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            
            // Icône du service
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getServiceIcon(service),
                color: AppColors.info,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // Informations du service
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (service.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      service.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            // Indicateur de sélection visuel
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.info,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  /// 🏷️ Feature du type de service
  Widget _buildServiceTypeFeature(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.overline.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 💀 État de chargement
  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Chargement des services...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🚫 État vide
  Widget _buildEmptyState(BuildContext context, String message) {
    return GlassContainer(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.info_outline,
              color: AppColors.info,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 🎨 Helpers pour les couleurs et icônes
  Color _getServiceTypeColor(ServiceType serviceType) {
    switch (serviceType.pricingType) {
      case 'FIXED':
        return AppColors.primary;
      case 'WEIGHT_BASED':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  IconData _getServiceTypeIcon(ServiceType serviceType) {
    switch (serviceType.pricingType) {
      case 'FIXED':
        return Icons.attach_money;
      case 'WEIGHT_BASED':
        return Icons.scale;
      default:
        return Icons.design_services;
    }
  }

  IconData _getServiceIcon(Service service) {
    final name = service.name.toLowerCase();
    if (name.contains('nettoyage')) return Icons.dry_cleaning;
    if (name.contains('repassage')) return Icons.iron;
    if (name.contains('retouche')) return Icons.content_cut;
    if (name.contains('express')) return Icons.flash_on;
    return Icons.cleaning_services;
  }
}