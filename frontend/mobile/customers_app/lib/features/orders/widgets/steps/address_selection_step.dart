import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants.dart';
import '../../../../components/glass_components.dart';
import '../../../../shared/providers/order_draft_provider.dart';
import '../../../../core/models/address.dart';

/// 📍 Étape de Sélection d'Adresse - Alpha Client App
///
/// Première étape du workflow : sélection de l'adresse de livraison.
/// Interface optimisée pour mobile avec gestion des adresses existantes.
class AddressSelectionStep extends StatelessWidget {
  const AddressSelectionStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderDraftProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(context),
              const SizedBox(height: 24),
              
              if (provider.addresses.isEmpty)
                _buildEmptyState(context)
              else
                _buildAddressList(context, provider),
              
              const SizedBox(height: 24),
              _buildAddNewAddressButton(context),
              const SizedBox(height: 100), // Bottom padding
            ],
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
          'Adresse de Livraison',
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choisissez l\'adresse où vous souhaitez recevoir votre commande.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  /// 📋 Liste des adresses
  Widget _buildAddressList(BuildContext context, OrderDraftProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vos Adresses',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        ...provider.addresses.map((address) => _buildAddressCard(
          context,
          address,
          provider.selectedAddress?.id == address.id,
          () => provider.selectAddress(address),
        )),
      ],
    );
  }

  /// 📍 Carte d'adresse
  Widget _buildAddressCard(
    BuildContext context,
    Address address,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        onTap: onTap,
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
            
            // Icône d'adresse
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                address.isDefault ? Icons.home : Icons.location_on,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            
            // Informations de l'adresse
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.name ?? 'Adresse',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Par défaut',
                            style: AppTextStyles.overline.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${address.street}, ${address.city}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (address.postalCode != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      address.postalCode!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary(context),
                      ),
                    ),
                  ],
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

  /// 🚫 État vide
  Widget _buildEmptyState(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.location_off_outlined,
              color: AppColors.info,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucune Adresse',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous devez ajouter une adresse de livraison pour continuer.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// ➕ Bouton d'ajout d'adresse
  Widget _buildAddNewAddressButton(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      onTap: () => _showAddAddressDialog(context),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.add_location_outlined,
              color: AppColors.success,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ajouter une Nouvelle Adresse',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Créez une nouvelle adresse de livraison',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: AppColors.textSecondary(context),
            size: 16,
          ),
        ],
      ),
    );
  }

  /// 📍 Dialog d'ajout d'adresse
  void _showAddAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.add_location_outlined,
              color: AppColors.success,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Nouvelle Adresse',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cette fonctionnalité sera bientôt disponible. Vous pourrez gérer vos adresses depuis votre profil.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fermer',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}