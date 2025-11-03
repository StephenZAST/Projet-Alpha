import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../core/models/offer.dart';
import '../../../providers/offers_provider.dart';
import '../widgets/offer_card.dart';
import '../widgets/offer_details_dialog.dart';

/// 🎁 Écran Offres - Alpha Client App
///
/// Affiche les offres disponibles et les abonnements de l'utilisateur.
class OffersScreen extends StatefulWidget {
  const OffersScreen({Key? key}) : super(key: key);

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initAnimations();
    _loadOffers();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: AppAnimations.slideIn),
    );

    _fadeController.forward();
  }

  Future<void> _loadOffers() async {
    final provider = Provider.of<OffersProvider>(context, listen: false);
    await provider.initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// 📱 AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.local_offer,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Offres Spéciales',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: AppColors.textPrimary(context),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// 🎨 Corps principal
  Widget _buildBody() {
    return Consumer<OffersProvider>(
      builder: (context, offersProvider, child) {
        if (offersProvider.isLoading && offersProvider.availableOffers.isEmpty) {
          return _buildLoadingState();
        }

        return FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Barre d'onglets
              _buildTabBar(),
              // Contenu des onglets
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAvailableOffersTab(offersProvider),
                    _buildMySubscriptionsTab(offersProvider),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 📑 Barre d'onglets
  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      margin: AppSpacing.pagePadding,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary(context),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.labelMedium,
        tabs: const [
          Tab(
            icon: Icon(Icons.local_offer_outlined, size: 18),
            text: 'Toutes les offres',
            height: 60,
          ),
          Tab(
            icon: Icon(Icons.bookmark_outlined, size: 18),
            text: 'Mes abonnements',
            height: 60,
          ),
        ],
      ),
    );
  }

  /// 🎁 Onglet Toutes les offres
  Widget _buildAvailableOffersTab(OffersProvider offersProvider) {
    final offers = offersProvider.availableOffers;

    if (offers.isEmpty) {
      return _buildEmptyState(
        icon: Icons.local_offer_outlined,
        title: 'Aucune offre disponible',
        subtitle: 'Revenez bientôt pour découvrir nos offres spéciales',
      );
    }

    return RefreshIndicator(
      onRefresh: () => offersProvider.refresh(),
      child: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${offers.length} offre${offers.length > 1 ? 's' : ''} disponible${offers.length > 1 ? 's' : ''}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 16),
            ...offers.map((offer) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OfferCard(
                    offer: offer,
                    onTap: () => _showOfferDetails(offer),
                    onSubscribe: () => _handleSubscribe(offer),
                  ),
                )),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 📌 Onglet Mes abonnements
  Widget _buildMySubscriptionsTab(OffersProvider offersProvider) {
    final subscriptions = offersProvider.userSubscriptions;

    if (subscriptions.isEmpty) {
      return _buildEmptyState(
        icon: Icons.bookmark_outline,
        title: 'Aucun abonnement',
        subtitle: 'Abonnez-vous à une offre pour la voir ici',
      );
    }

    return RefreshIndicator(
      onRefresh: () => offersProvider.refresh(),
      child: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${subscriptions.length} abonnement${subscriptions.length > 1 ? 's' : ''}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 16),
            ...subscriptions.map((offer) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OfferCard(
                    offer: offer.copyWith(isSubscribed: true),
                    onTap: () => _showOfferDetails(offer),
                    onSubscribe: () => _handleUnsubscribe(offer),
                  ),
                )),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 💀 État de chargement
  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GlassContainer(
              padding: AppSpacing.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLoader(width: 200, height: 20),
                  const SizedBox(height: 12),
                  const SkeletonLoader(width: double.infinity, height: 16),
                  const SizedBox(height: 8),
                  const SkeletonLoader(width: 150, height: 14),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const SkeletonLoader(width: 80, height: 40),
                      const Spacer(),
                      const SkeletonLoader(width: 80, height: 40),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 📭 État vide
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.textTertiary(context),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 📖 Afficher les détails d'une offre
  void _showOfferDetails(Offer offer) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => OfferDetailsDialog(offer: offer),
    );
  }

  /// ✅ Gérer l'abonnement
  Future<void> _handleSubscribe(Offer offer) async {
    HapticFeedback.lightImpact();
    final provider = Provider.of<OffersProvider>(context, listen: false);

    try {
      await provider.subscribeToOffer(offer.id);
      _showSnackBar(
        'Vous êtes abonné à "${offer.name}"',
        isSuccess: true,
      );
    } catch (e) {
      _showSnackBar('Erreur lors de l\'abonnement');
    }
  }

  /// ❌ Gérer la désinscription
  Future<void> _handleUnsubscribe(Offer offer) async {
    HapticFeedback.lightImpact();
    final provider = Provider.of<OffersProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Confirmer la désinscription',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir vous désabonner de "${offer.name}" ?',
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
            text: 'Désabonner',
            onPressed: () async {
              Navigator.pop(context);
              try {
                await provider.unsubscribeFromOffer(offer.id);
                _showSnackBar(
                  'Vous êtes désabonné de "${offer.name}"',
                  isSuccess: true,
                );
              } catch (e) {
                _showSnackBar('Erreur lors de la désinscription');
              }
            },
            width: 120,
            height: 40,
          ),
        ],
      ),
    );
  }

  /// 📱 Afficher SnackBar
  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error_outline,
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
        backgroundColor: isSuccess ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMD,
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
