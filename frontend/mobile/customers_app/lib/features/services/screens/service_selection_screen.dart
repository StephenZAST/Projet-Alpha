import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../shared/providers/article_service_provider.dart';
import '../../../shared/utils/notification_utils.dart';
import '../../../core/models/service_type.dart';
import '../../../core/models/service.dart';
import '../../../core/models/article_service_price.dart';
import '../widgets/service_type_selector.dart';
import '../widgets/service_selector.dart';
import '../widgets/article_service_grid.dart';
import '../widgets/premium_toggle.dart';

/// 🛍️ Écran de Sélection Service - Alpha Client App
///
/// Workflow optimisé : ServiceType → Service → ArticleServicePrice
/// avec switch Premium/Basic selon les spécifications Alpha.
class ServiceSelectionScreen extends StatefulWidget {
  const ServiceSelectionScreen({Key? key}) : super(key: key);

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeProvider();
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
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  void _initializeProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ArticleServiceProvider>(context, listen: false);
      provider.initialize();
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
      title: Text(
        'Sélection de Services',
        style: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.textPrimary(context),
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Consumer<ArticleServiceProvider>(
          builder: (context, provider, child) {
            return IconButton(
              icon: Icon(
                Icons.refresh,
                color: AppColors.textPrimary(context),
              ),
              onPressed: provider.isLoading ? null : () {
                HapticFeedback.lightImpact();
                provider.initialize();
                NotificationUtils.showInfo(context, 'Actualisation en cours...');
              },
            );
          },
        ),
      ],
    );
  }

  /// 🎨 Corps principal
  Widget _buildBody() {
    return Consumer<ArticleServiceProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingState();
        }

        if (provider.error != null) {
          return _buildErrorState(provider.error!);
        }

        return SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildWorkflowHeader(provider),
              const SizedBox(height: 24),
              _buildServiceTypeSection(provider),
              if (provider.hasServiceTypeSelected) ...[
                const SizedBox(height: 24),
                _buildServiceSection(provider),
              ],
              if (provider.hasServiceSelected) ...[
                const SizedBox(height: 24),
                _buildPremiumToggleSection(provider),
                const SizedBox(height: 24),
                _buildArticleServiceSection(provider),
              ],
              const SizedBox(height: 100), // Bottom padding
            ],
          ),
        );
      },
    );
  }

  /// 📋 En-tête du workflow
  Widget _buildWorkflowHeader(ArticleServiceProvider provider) {
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
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.auto_awesome,
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
                      'Workflow de Sélection',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Suivez les étapes pour configurer votre commande',
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
          _buildWorkflowSteps(provider),
        ],
      ),
    );
  }

  /// 📊 Étapes du workflow
  Widget _buildWorkflowSteps(ArticleServiceProvider provider) {
    return Row(
      children: [
        _buildWorkflowStep(
          '1',
          'Type de Service',
          provider.hasServiceTypeSelected,
          AppColors.primary,
        ),
        _buildWorkflowConnector(provider.hasServiceTypeSelected),
        _buildWorkflowStep(
          '2',
          'Service',
          provider.hasServiceSelected,
          AppColors.info,
        ),
        _buildWorkflowConnector(provider.hasServiceSelected),
        _buildWorkflowStep(
          '3',
          'Articles',
          provider.canSelectCouples,
          AppColors.success,
        ),
      ],
    );
  }

  Widget _buildWorkflowStep(String number, String label, bool isCompleted, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted ? color : color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: isCompleted
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    )
                  : Text(
                      number,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isCompleted ? Colors.white : color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isCompleted 
                  ? AppColors.textPrimary(context)
                  : AppColors.textTertiary(context),
              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowConnector(bool isActive) {
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isActive 
            ? AppColors.primary 
            : AppColors.border(context),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  /// 🏷️ Section Type de Service
  Widget _buildServiceTypeSection(ArticleServiceProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Étape 1 : Choisissez le Type de Service',
          Icons.category_outlined,
          AppColors.primary,
        ),
        const SizedBox(height: 16),
        ServiceTypeSelector(
          serviceTypes: provider.serviceTypes,
          selectedServiceType: provider.selectedServiceType,
          onServiceTypeSelected: (serviceType) {
            HapticFeedback.lightImpact();
            provider.selectServiceType(serviceType);
          },
        ),
      ],
    );
  }

  /// 🛠️ Section Service
  Widget _buildServiceSection(ArticleServiceProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Étape 2 : Sélectionnez le Service',
          Icons.build_outlined,
          AppColors.info,
        ),
        const SizedBox(height: 16),
        ServiceSelector(
          services: provider.services,
          selectedService: provider.selectedService,
          isLoading: provider.isLoadingServices,
          onServiceSelected: (service) {
            HapticFeedback.lightImpact();
            provider.selectService(service);
          },
        ),
      ],
    );
  }

  /// 💎 Section Toggle Premium
  Widget _buildPremiumToggleSection(ArticleServiceProvider provider) {
    final stats = provider.stats;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Options de Tarification',
          Icons.star_outline,
          AppColors.warning,
        ),
        const SizedBox(height: 16),
        PremiumToggle(
          isPremium: provider.isPremium,
          supportsPremium: stats.premiumSupportedCouples > 0,
          onToggle: (isPremium) {
            HapticFeedback.lightImpact();
            provider.setPremium(isPremium);
          },
        ),
      ],
    );
  }

  /// 📦 Section Articles-Services
  Widget _buildArticleServiceSection(ArticleServiceProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Étape 3 : Choisissez vos Articles',
          Icons.inventory_2_outlined,
          AppColors.success,
        ),
        const SizedBox(height: 16),
        ArticleServiceGrid(
          couples: provider.availableCouples,
          isPremium: provider.isPremium,
          isLoading: provider.isLoadingCouples,
          onCoupleSelected: (couple) {
            HapticFeedback.lightImpact();
            _showCoupleDetails(couple, provider);
          },
        ),
      ],
    );
  }

  /// 📋 En-tête de section
  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
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
            'Chargement des services...',
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
                final provider = Provider.of<ArticleServiceProvider>(context, listen: false);
                provider.initialize();
              },
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  /// 📋 Afficher les détails d'un couple
  void _showCoupleDetails(ArticleServicePrice couple, ArticleServiceProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
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
            
            // Contenu
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.inventory_2,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                couple.articleName ?? 'Article',
                                style: AppTextStyles.headlineMedium.copyWith(
                                  color: AppColors.textPrimary(context),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                couple.serviceName ?? 'Service',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Prix
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tarification',
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: AppColors.textPrimary(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildPriceCard(
                                  'Prix Basic',
                                  '${couple.basePrice.toStringAsFixed(0)} FCFA',
                                  AppColors.info,
                                  !provider.isPremium,
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (couple.supportsPremium)
                                Expanded(
                                  child: _buildPriceCard(
                                    'Prix Premium',
                                    '${couple.premiumPrice.toStringAsFixed(0)} FCFA',
                                    AppColors.warning,
                                    provider.isPremium,
                                  ),
                                ),
                            ],
                          ),
                          if (couple.requiresWeight && couple.pricePerKg != null) ...[
                            const SizedBox(height: 12),
                            _buildPriceCard(
                              'Prix au Kilo',
                              '${couple.pricePerKg!.toStringAsFixed(0)} FCFA/kg',
                              AppColors.success,
                              false,
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Fermer',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: PremiumButton(
                            text: 'Ajouter au Panier',
                            onPressed: () {
                              Navigator.pop(context);
                              NotificationUtils.showSuccess(
                                context,
                                '${couple.articleName} ajouté au panier',
                              );
                            },
                            icon: Icons.add_shopping_cart,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard(String label, String price, Color color, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : AppColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? color : AppColors.border(context),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? color : AppColors.textSecondary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: AppTextStyles.headlineSmall.copyWith(
              color: isSelected ? color : AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}