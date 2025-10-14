import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../constants.dart';
import '../../../../components/glass_components.dart';
import '../../../../shared/providers/order_draft_provider.dart';
import '../../../../core/models/article.dart';
import '../../../../core/services/pricing_service.dart';
import '../article_service_couple_card.dart';

/// 📦 Étape de Sélection d'Articles - Alpha Client App
///
/// Troisième étape du workflow : sélection des articles avec prix et quantités.
/// Interface optimisée pour mobile avec toggle Premium/Basic.
class ArticleSelectionStep extends StatefulWidget {
  const ArticleSelectionStep({Key? key}) : super(key: key);

  @override
  State<ArticleSelectionStep> createState() => _ArticleSelectionStepState();
}

class _ArticleSelectionStepState extends State<ArticleSelectionStep> 
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
                _buildHeader(context, provider),
                const SizedBox(height: 24),
                
                // Toggle Premium/Basic
                if (provider.selectedServiceType?.supportsPremium == true) ...[
                  _buildPremiumToggle(context, provider),
                  const SizedBox(height: 24),
                ],
                
                // Résumé du panier
                if (provider.orderDraft.items.isNotEmpty) ...[
                  _buildCartSummary(context, provider),
                  const SizedBox(height: 24),
                ],
                
                // Liste des articles
                _buildArticlesSection(context, provider),
                
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        );
      },
    );
  }

  /// 📋 En-tête de l'étape
  Widget _buildHeader(BuildContext context, OrderDraftProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sélection d\'Articles',
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choisissez les articles à traiter avec le service "${provider.selectedService?.name ?? 'sélectionné'}".',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
        if (provider.selectedServiceType?.requiresWeight == true) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warning.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.scale,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ce service nécessite une pesée. Le prix final sera calculé selon le poids.',
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
    );
  }

  /// 💎 Toggle Premium/Basic
  Widget _buildPremiumToggle(BuildContext context, OrderDraftProvider provider) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star_outline,
                color: AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Options de Tarification',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildPricingOption(
                  context,
                  'Standard',
                  'Prix de base',
                  !provider.isPremium,
                  () => provider.togglePremium(),
                  AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPricingOption(
                  context,
                  'Premium',
                  'Finition supérieure',
                  provider.isPremium,
                  () => provider.togglePremium(),
                  AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 💰 Option de tarification
  Widget _buildPricingOption(
    BuildContext context,
    String title,
    String subtitle,
    bool isSelected,
    VoidCallback onTap,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
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
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? color : AppColors.textSecondary(context),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? color : AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 🛒 Résumé du panier
  Widget _buildCartSummary(BuildContext context, OrderDraftProvider provider) {
    final draft = provider.orderDraft;
    
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.success,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Votre Panier',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${draft.totalItems} article(s)',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total estimé',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
              Text(
                '${draft.estimatedTotal.toStringAsFixed(2)} FCFA',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 📦 Section des articles (couples article-service-price)
  Widget _buildArticlesSection(BuildContext context, OrderDraftProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Articles Disponibles',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Prix pour ${provider.selectedService?.name ?? 'ce service'}',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: 16),
        
        if (provider.isLoading)
          _buildLoadingState(context)
        else if (provider.couples.isEmpty)
          _buildEmptyState(context)
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: provider.couples.length,
            itemBuilder: (context, index) {
              final couple = provider.couples[index];
              
              // Trouver la quantité actuelle dans le panier
              final cartItem = provider.orderDraft.items.where(
                (item) => item.articleId == couple.articleId && 
                          item.isPremium == provider.isPremium,
              ).firstOrNull;
              final quantity = cartItem?.quantity ?? 0;
              
              return ArticleServiceCoupleCard(
                couple: couple,
                quantity: quantity,
                isPremium: provider.isPremium,
                onQuantityChanged: (newQuantity) {
                  if (newQuantity == 0) {
                    provider.removeArticle(couple.articleId, provider.isPremium);
                  } else if (quantity == 0) {
                    // Ajouter un nouvel article (créer un Article temporaire sans prix)
                    final article = Article(
                      id: couple.articleId,
                      name: couple.articleName ?? 'Article',
                      description: '',
                      categoryId: '',
                      isActive: true,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );
                    provider.addArticle(article, newQuantity);
                  } else {
                    // Mettre à jour la quantité
                    provider.updateArticleQuantity(
                      couple.articleId,
                      provider.isPremium,
                      newQuantity,
                    );
                  }
                },
              );
            },
          ),
      ],
    );
  }

  /// 📦 Carte d'article
  Widget _buildArticleCard(
    BuildContext context,
    Article article,
    OrderDraftProvider provider,
  ) {
    final basePrice = provider.getArticlePrice(article.id, false);
    final premiumPrice = provider.getArticlePrice(article.id, true);
    final currentPrice = provider.isPremium ? premiumPrice : basePrice;
    
    // Vérifier si l'article est dans le panier
    final cartItem = provider.orderDraft.items.where(
      (item) => item.articleId == article.id && item.isPremium == provider.isPremium,
    ).firstOrNull;
    final quantity = cartItem?.quantity ?? 0;
    
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec icône
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getArticleIcon(article),
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const Spacer(),
              if (quantity > 0)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '$quantity',
                      style: AppTextStyles.overline.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Nom de l'article
          Text(
            article.name,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          // Description
          if (article.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              article.description,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          const Spacer(),
          
          // Prix
          Row(
            children: [
              Text(
                '${currentPrice.toStringAsFixed(0)} FCFA',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (provider.isPremium && provider.selectedServiceType?.supportsPremium == true) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.star,
                  color: AppColors.warning,
                  size: 16,
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          
          // Contrôles de quantité
          if (quantity > 0)
            _buildQuantityControls(context, article, provider, quantity)
          else
            _buildAddButton(context, article, provider),
        ],
      ),
    );
  }

  /// ➕ Bouton d'ajout
  Widget _buildAddButton(
    BuildContext context,
    Article article,
    OrderDraftProvider provider,
  ) {
    return SizedBox(
      width: double.infinity,
      child: PremiumButton(
        text: 'Ajouter',
        onPressed: () {
          HapticFeedback.lightImpact();
          provider.addArticle(article, 1);
        },
        icon: Icons.add,
        height: 36,
      ),
    );
  }

  /// 🔢 Contrôles de quantité
  Widget _buildQuantityControls(
    BuildContext context,
    Article article,
    OrderDraftProvider provider,
    int quantity,
  ) {
    return Row(
      children: [
        // Bouton moins
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            if (quantity > 1) {
              provider.updateArticleQuantity(article.id, provider.isPremium, quantity - 1);
            } else {
              provider.removeArticle(article.id, provider.isPremium);
            }
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              quantity > 1 ? Icons.remove : Icons.delete_outline,
              color: AppColors.error,
              size: 16,
            ),
          ),
        ),
        
        // Quantité
        Expanded(
          child: Center(
            child: Text(
              '$quantity',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        
        // Bouton plus
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            provider.updateArticleQuantity(article.id, provider.isPremium, quantity + 1);
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.add,
              color: AppColors.success,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  /// ⏳ État de chargement
  Widget _buildLoadingState(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chargement des articles...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Récupération des prix pour ce service',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
              Icons.inventory_2_outlined,
              color: AppColors.info,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun Article',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aucun article n\'est disponible pour ce service.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 🎨 Helper pour les icônes d'articles
  IconData _getArticleIcon(Article article) {
    final name = article.name.toLowerCase();
    if (name.contains('chemise')) return Icons.checkroom;
    if (name.contains('pantalon')) return Icons.checkroom_outlined;
    if (name.contains('costume')) return Icons.work_outline;
    if (name.contains('robe')) return Icons.woman;
    if (name.contains('veste')) return Icons.checkroom;
    return Icons.inventory_2_outlined;
  }
}