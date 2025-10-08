import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../shared/providers/address_provider.dart';
import '../../../core/models/address.dart';
import '../widgets/address_card.dart';
import '../widgets/enhanced_address_form_dialog.dart';

/// 🏠 Écran de Gestion des Adresses - Alpha Client App
///
/// Interface premium pour gérer les adresses utilisateur
/// avec CRUD complet et design glassmorphism.
class AddressManagementScreen extends StatefulWidget {
  const AddressManagementScreen({Key? key}) : super(key: key);

  @override
  State<AddressManagementScreen> createState() => _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeAddresses();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: AppAnimations.fadeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: AppAnimations.slideIn,
    ));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _slideController.forward();
    });
  }

  void _initializeAddresses() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      addressProvider.initialize();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildBody(),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// 📱 AppBar Premium
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface(context),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppColors.textPrimary(context),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mes Adresses',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          Consumer<AddressProvider>(
            builder: (context, provider, child) {
              return Text(
                '${provider.totalAddresses} adresse${provider.totalAddresses > 1 ? 's' : ''}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        Consumer<AddressProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }
            return IconButton(
              icon: Icon(
                Icons.refresh,
                color: AppColors.textPrimary(context),
              ),
              onPressed: () => provider.refresh(),
            );
          },
        ),
      ],
    );
  }

  /// 🎨 Corps principal
  Widget _buildBody() {
    return Consumer<AddressProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && !provider.hasAddresses) {
          return _buildLoadingState();
        }

        if (provider.error != null) {
          return _buildErrorState(provider.error!);
        }

        if (!provider.hasAddresses) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: provider.refresh,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildStatsSection(provider),
                const SizedBox(height: 24),
                _buildAddressesSection(provider),
                const SizedBox(height: 100), // Bottom padding pour le FAB
              ],
            ),
          ),
        );
      },
    );
  }

  /// 📊 Section statistiques
  Widget _buildStatsSection(AddressProvider provider) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Aperçu',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  '${provider.totalAddresses}',
                  Icons.location_on,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Par défaut',
                  provider.hasDefaultAddress ? '1' : '0',
                  Icons.home,
                  provider.hasDefaultAddress ? AppColors.success : AppColors.warning,
                ),
              ),
            ],
          ),
          if (!provider.hasDefaultAddress) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_outlined,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Définissez une adresse par défaut pour utiliser les commandes flash',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  /// 🏠 Section des adresses
  Widget _buildAddressesSection(AddressProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vos Adresses',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...provider.addresses.map((address) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AddressCard(
            address: address,
            onTap: () => _showAddressOptions(address),
            onEdit: () => _showEditAddressDialog(address),
            onDelete: () => _showDeleteConfirmation(address),
            onSetDefault: () => _setDefaultAddress(address),
          ),
        )),
      ],
    );
  }

  /// 💀 État de chargement
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chargement des adresses...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  /// ❌ État d'erreur
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Erreur de chargement',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PremiumButton(
              text: 'Réessayer',
              onPressed: () {
                final provider = Provider.of<AddressProvider>(context, listen: false);
                provider.refresh();
              },
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  /// 📭 État vide
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.location_on_outlined,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Aucune adresse',
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez votre première adresse pour commencer à passer des commandes',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PremiumButton(
              text: 'Ajouter une adresse',
              onPressed: _showCreateAddressDialog,
              icon: Icons.add_location,
              width: 200,
            ),
          ],
        ),
      ),
    );
  }

  /// ➕ Bouton d'action flottant
  Widget _buildFloatingActionButton() {
    return Consumer<AddressProvider>(
      builder: (context, provider, child) {
        if (!provider.hasAddresses) return const SizedBox.shrink();
        
        return FloatingActionButton.extended(
          onPressed: _showCreateAddressDialog,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_location),
          label: const Text('Ajouter'),
        );
      },
    );
  }

  /// 📋 Afficher les options d'adresse
  void _showAddressOptions(Address address) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.textTertiary(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Titre
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  address.name,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              
              // Options
              if (!address.isDefault)
                ListTile(
                  leading: Icon(Icons.home, color: AppColors.success),
                  title: Text('Définir par défaut'),
                  onTap: () {
                    Navigator.pop(context);
                    _setDefaultAddress(address);
                  },
                ),
              ListTile(
                leading: Icon(Icons.edit, color: AppColors.info),
                title: Text('Modifier'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditAddressDialog(address);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: AppColors.error),
                title: Text('Supprimer'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(address);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// ➕ Afficher le dialog de création d'adresse
  void _showCreateAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => EnhancedAddressFormDialog(
        title: 'Nouvelle Adresse',
        onSave: (request) async {
          final provider = Provider.of<AddressProvider>(context, listen: false);
          final success = await provider.createAddress(request);
          
          if (success) {
            _showSuccessSnackBar('Adresse créée avec succès');
          } else if (provider.error != null) {
            _showErrorSnackBar(provider.error!);
          }
          
          return success;
        },
      ),
    );
  }

  /// ✏️ Afficher le dialog d'édition d'adresse
  void _showEditAddressDialog(Address address) {
    showDialog(
      context: context,
      builder: (context) => EnhancedAddressFormDialog(
        title: 'Modifier Adresse',
        initialAddress: address,
        onSave: (request) async {
          final provider = Provider.of<AddressProvider>(context, listen: false);
          final updateRequest = UpdateAddressRequest(
            name: request.name,
            street: request.street,
            city: request.city,
            postalCode: request.postalCode,
            gpsLatitude: request.gpsLatitude,
            gpsLongitude: request.gpsLongitude,
            isDefault: request.isDefault,
          );
          
          final success = await provider.updateAddress(address.id, updateRequest);
          
          if (success) {
            _showSuccessSnackBar('Adresse modifiée avec succès');
          } else if (provider.error != null) {
            _showErrorSnackBar(provider.error!);
          }
          
          return success;
        },
      ),
    );
  }

  /// 🗑️ Afficher la confirmation de suppression
  void _showDeleteConfirmation(Address address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Supprimer l\'adresse ?',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Êtes-vous sûr de vouloir supprimer cette adresse ?',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                address.fullAddress,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            if (address.isDefault) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_outlined,
                      color: AppColors.warning,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Cette adresse est votre adresse par défaut',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          PremiumButton(
            text: 'Supprimer',
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAddress(address);
            },
            backgroundColor: AppColors.error,
            width: 100,
            height: 40,
          ),
        ],
      ),
    );
  }

  /// 🏠 Définir une adresse par défaut
  Future<void> _setDefaultAddress(Address address) async {
    HapticFeedback.lightImpact();
    
    final provider = Provider.of<AddressProvider>(context, listen: false);
    final success = await provider.setDefaultAddress(address.id);
    
    if (success) {
      _showSuccessSnackBar('${address.name} définie comme adresse par défaut');
    } else if (provider.error != null) {
      _showErrorSnackBar(provider.error!);
    }
  }

  /// 🗑️ Supprimer une adresse
  Future<void> _deleteAddress(Address address) async {
    HapticFeedback.lightImpact();
    
    final provider = Provider.of<AddressProvider>(context, listen: false);
    final success = await provider.deleteAddress(address.id);
    
    if (success) {
      _showSuccessSnackBar('Adresse supprimée avec succès');
    } else if (provider.error != null) {
      _showErrorSnackBar(provider.error!);
    }
  }

  /// ✅ Afficher SnackBar de succès
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMD,
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// ❌ Afficher SnackBar d'erreur
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMD,
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}