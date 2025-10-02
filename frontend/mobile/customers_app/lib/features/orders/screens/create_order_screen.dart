import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../shared/providers/order_draft_provider.dart';
import '../../../shared/utils/notification_utils.dart';
import '../widgets/order_stepper_indicator.dart';
import '../widgets/steps/address_selection_step.dart';
import '../widgets/steps/service_selection_step.dart';
import '../widgets/steps/article_selection_step.dart';
import '../widgets/steps/order_info_step.dart';
import '../widgets/steps/order_summary_step.dart';

/// 🛍️ Écran de Création de Commande Complète - Alpha Client App
///
/// Workflow optimisé pour mobile : Adresse → Service → Articles → Infos → Résumé
/// Basé sur le système admin mais adapté pour l'expérience client.
class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({Key? key}) : super(key: key);

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late PageController _pageController;

  final List<StepInfo> _steps = [
    StepInfo(
      title: 'Adresse',
      subtitle: 'Choisissez votre adresse de livraison',
      icon: Icons.location_on_outlined,
      color: AppColors.primary,
    ),
    StepInfo(
      title: 'Service',
      subtitle: 'Sélectionnez le type de service',
      icon: Icons.design_services_outlined,
      color: AppColors.info,
    ),
    StepInfo(
      title: 'Articles',
      subtitle: 'Choisissez vos articles',
      icon: Icons.inventory_2_outlined,
      color: AppColors.warning,
    ),
    StepInfo(
      title: 'Informations',
      subtitle: 'Dates et options',
      icon: Icons.event_note_outlined,
      color: AppColors.success,
    ),
    StepInfo(
      title: 'Résumé',
      subtitle: 'Vérifiez et confirmez',
      icon: Icons.receipt_long_outlined,
      color: AppColors.accent,
    ),
  ];

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

    _pageController = PageController();
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  void _initializeProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<OrderDraftProvider>(context, listen: false);
      provider.initialize();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pageController.dispose();
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
      bottomNavigationBar: _buildBottomNavigation(),
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
        onPressed: () => _handleBackPressed(),
      ),
      title: Text(
        'Nouvelle Commande',
        style: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.textPrimary(context),
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Consumer<OrderDraftProvider>(
          builder: (context, provider, child) {
            final itemCount = provider.orderDraft.totalItems;
            return Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.shopping_cart_outlined,
                    color: AppColors.textPrimary(context),
                  ),
                  onPressed: itemCount > 0 ? () => _showCartSummary() : null,
                ),
                if (itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Center(
                        child: Text(
                          '$itemCount',
                          style: AppTextStyles.overline.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// 🎨 Corps principal
  Widget _buildBody() {
    return Consumer<OrderDraftProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingState();
        }

        if (provider.error != null) {
          return _buildErrorState(provider.error!);
        }

        return Column(
          children: [
            // Indicateur de progression
            OrderStepperIndicator(
              steps: _steps,
              currentStep: provider.currentStep,
              onStepTapped: (step) {
                if (step < provider.currentStep) {
                  provider.goToStep(step);
                  _animateToPage(step);
                }
              },
            ),
            
            // Contenu des étapes
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  // Synchroniser avec le provider si l'utilisateur swipe
                  if (index != provider.currentStep) {
                    provider.goToStep(index);
                  }
                },
                children: [
                  // Étape 0: Sélection d'adresse
                  AddressSelectionStep(),
                  
                  // Étape 1: Sélection de service
                  ServiceSelectionStep(),
                  
                  // Étape 2: Sélection d'articles
                  ArticleSelectionStep(),
                  
                  // Étape 3: Informations complémentaires
                  OrderInfoStep(),
                  
                  // Étape 4: Résumé et confirmation
                  OrderSummaryStep(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// 🔄 Navigation en bas
  Widget _buildBottomNavigation() {
    return Consumer<OrderDraftProvider>(
      builder: (context, provider, child) {
        final isLastStep = provider.currentStep == 4;
        
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            border: Border(
              top: BorderSide(
                color: AppColors.border(context),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Bouton Précédent
                if (provider.canGoToPreviousStep)
                  Expanded(
                    child: TextButton(
                      onPressed: provider.isSubmitting ? null : () {
                        provider.previousStep();
                        _animateToPage(provider.currentStep);
                      },
                      child: Text(
                        'Précédent',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                  ),
                
                if (provider.canGoToPreviousStep) const SizedBox(width: 16),
                
                // Bouton Suivant/Confirmer
                Expanded(
                  flex: provider.canGoToPreviousStep ? 2 : 1,
                  child: PremiumButton(
                    text: _getNextButtonText(provider),
                    onPressed: _getNextButtonAction(provider),
                    icon: _getNextButtonIcon(provider),
                    isLoading: provider.isSubmitting,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
            'Chargement...',
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
                final provider = Provider.of<OrderDraftProvider>(context, listen: false);
                provider.initialize();
              },
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 Gestionnaires d'événements
  void _handleBackPressed() {
    final provider = Provider.of<OrderDraftProvider>(context, listen: false);
    
    if (provider.canGoToPreviousStep) {
      provider.previousStep();
      _animateToPage(provider.currentStep);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: AppAnimations.medium,
      curve: AppAnimations.slideIn,
    );
  }

  /// 🛒 Afficher le résumé du panier
  void _showCartSummary() {
    final provider = Provider.of<OrderDraftProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
            
            // En-tête
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Votre Panier',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.textPrimary(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${provider.orderDraft.totalItems} article(s) • ${provider.orderDraft.estimatedTotal.toStringAsFixed(2)} FCFA',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Liste des articles
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: provider.orderDraft.items.length,
                itemBuilder: (context, index) {
                  final item = provider.orderDraft.items[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.articleName,
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.textPrimary(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${item.quantity}x • ${item.isPremium ? 'Premium' : 'Standard'}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${item.estimatedPrice.toStringAsFixed(2)} FCFA',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 Helpers pour la navigation
  String _getNextButtonText(OrderDraftProvider provider) {
    switch (provider.currentStep) {
      case 0:
        return 'Choisir le Service';
      case 1:
        return 'Sélectionner Articles';
      case 2:
        return 'Informations';
      case 3:
        return 'Voir le Résumé';
      case 4:
        return provider.isSubmitting ? 'Création...' : 'Confirmer Commande';
      default:
        return 'Suivant';
    }
  }

  VoidCallback? _getNextButtonAction(OrderDraftProvider provider) {
    if (provider.isSubmitting) return null;
    
    switch (provider.currentStep) {
      case 4:
        return () async {
          final success = await provider.submitOrder(context);
          if (success) {
            Navigator.of(context).pop();
          }
        };
      default:
        return provider.canGoToNextStep ? () {
          provider.nextStep();
          _animateToPage(provider.currentStep);
        } : null;
    }
  }

  IconData _getNextButtonIcon(OrderDraftProvider provider) {
    switch (provider.currentStep) {
      case 4:
        return Icons.check_circle;
      default:
        return Icons.arrow_forward;
    }
  }
}

/// 📊 Information d'une étape
class StepInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  StepInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}