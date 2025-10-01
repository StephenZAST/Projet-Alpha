import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../shared/providers/flash_order_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../core/models/flash_order.dart';
import '../widgets/flash_order_item_card.dart';
import '../widgets/flash_order_summary.dart';
import '../widgets/popular_items_grid.dart';

/// ⚡ Écran de Commande Flash - Alpha Client App
///
/// Interface premium pour créer des commandes flash rapides
/// avec sélection d'articles populaires et validation instantanée.
class FlashOrderScreen extends StatefulWidget {
  const FlashOrderScreen({Key? key}) : super(key: key);

  @override
  State<FlashOrderScreen> createState() => _FlashOrderScreenState();
}

class _FlashOrderScreenState extends State<FlashOrderScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _notesController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _showSummary = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeFlashOrder();
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

  void _initializeFlashOrder() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final flashOrderProvider =
          Provider.of<FlashOrderProvider>(context, listen: false);
      flashOrderProvider.initialize();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
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
      bottomNavigationBar: _buildBottomBar(),
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
            'Commande Flash',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Sélection rapide',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
      actions: [
        Consumer<FlashOrderProvider>(
          builder: (context, provider, child) {
            if (provider.hasItems) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: IconButton(
                  icon: Stack(
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      if (provider.totalItems > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${provider.totalItems}',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () {
                    setState(() {
                      _showSummary = !_showSummary;
                    });
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  /// 🎨 Corps principal
  Widget _buildBody() {
    return Consumer<FlashOrderProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingState();
        }

        if (provider.error != null) {
          return _buildErrorState(provider.error!);
        }

        return SingleChildScrollView(
          controller: _scrollController,
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildPopularItemsSection(),
              const SizedBox(height: 24),
              if (provider.hasItems) ...[
                _buildCurrentOrderSection(),
                const SizedBox(height: 24),
              ],
              _buildNotesSection(),
              const SizedBox(
                  height: 100), // Bottom padding pour le bouton flottant
            ],
          ),
        );
      },
    );
  }

  /// 👋 Section d'accueil
  Widget _buildWelcomeSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.accent, AppColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.flash_on,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Commande Flash',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.textPrimary(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Sélectionnez vos articles favoris pour une commande rapide',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: AppRadius.radiusSM,
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
                        'Votre commande sera créée en brouillon et validée par notre équipe.',
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
        );
      },
    );
  }

  /// 🎯 Section articles populaires
  Widget _buildPopularItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Articles Populaires',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        const PopularItemsGrid(),
      ],
    );
  }

  /// 🛍️ Section commande actuelle
  Widget _buildCurrentOrderSection() {
    return Consumer<FlashOrderProvider>(
      builder: (context, provider, child) {
        if (!provider.hasItems) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Votre Commande',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _showClearOrderDialog();
                  },
                  child: Text(
                    'Vider',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...provider.currentFlashOrder!.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FlashOrderItemCard(item: item),
              ),
            ),
            const SizedBox(height: 16),
            const FlashOrderSummary(),
          ],
        );
      },
    );
  }

  /// 📝 Section notes
  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (optionnel)',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Instructions spéciales, préférences...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary(context),
              ),
              border: InputBorder.none,
            ),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary(context),
            ),
            onChanged: (value) {
              final provider =
                  Provider.of<FlashOrderProvider>(context, listen: false);
              provider.updateNotes(value);
            },
          ),
        ),
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
            'Chargement des articles...',
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
                final provider =
                    Provider.of<FlashOrderProvider>(context, listen: false);
                provider.initialize();
              },
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  /// 📊 Barre inférieure avec résumé et validation
  Widget? _buildBottomBar() {
    return Consumer<FlashOrderProvider>(
      builder: (context, provider, child) {
        if (!provider.hasItems) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${provider.totalItems} article${provider.totalItems > 1 ? 's' : ''}',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                        Text(
                          '€${provider.totalPrice.toStringAsFixed(2)}',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    PremiumButton(
                      text: 'Créer la commande',
                      onPressed:
                          provider.canCreateOrder && !provider.isCreatingOrder
                              ? _handleCreateOrder
                              : null,
                      isLoading: provider.isCreatingOrder,
                      icon: Icons.flash_on,
                      width: 180,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ⚡ Gestionnaire de création de commande
  void _handleCreateOrder() async {
    HapticFeedback.lightImpact();

    final provider = Provider.of<FlashOrderProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Vérifier les prérequis
    if (!authProvider.canMakeFlashOrders) {
      _showAddressRequiredDialog();
      return;
    }

    // Créer la commande
    final success = await provider.submitFlashOrder();

    if (success && mounted) {
      _showSuccessDialog(provider.lastOrderResult!);
    } else if (provider.error != null && mounted) {
      _showErrorSnackBar(provider.error!);
    }
  }

  /// 📍 Dialog adresse requise
  void _showAddressRequiredDialog() {
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
              Icons.location_on_outlined,
              color: AppColors.warning,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Adresse requise',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
        content: Text(
          'Pour créer une commande flash, vous devez configurer une adresse par défaut dans votre profil.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Plus tard',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          PremiumButton(
            text: 'Configurer',
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to address setup
              _showErrorSnackBar(
                  'Configuration adresse - Bientôt disponible !');
            },
            width: 120,
            height: 40,
          ),
        ],
      ),
    );
  }

  /// ✅ Dialog de succès
  void _showSuccessDialog(FlashOrderResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Commande créée !',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Référence: ${result.orderReference}',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              result.message ??
                  'Votre commande flash a été créée avec succès. Notre équipe va la valider rapidement.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PremiumButton(
              text: 'Parfait !',
              onPressed: () {
                Navigator.pop(context); // Fermer le dialog
                Navigator.pop(context); // Retourner à l'accueil
              },
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  /// 🗑️ Dialog de confirmation pour vider la commande
  void _showClearOrderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Vider la commande ?',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
          ),
        ),
        content: Text(
          'Tous les articles seront supprimés de votre commande.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary(context),
          ),
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
            text: 'Vider',
            onPressed: () {
              final provider =
                  Provider.of<FlashOrderProvider>(context, listen: false);
              provider.clearCurrentOrder();
              Navigator.pop(context);
            },
            backgroundColor: AppColors.error,
            width: 100,
            height: 40,
          ),
        ],
      ),
    );
  }

  /// 📱 Afficher SnackBar d'erreur
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
