import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';

/// 📋 Écran des Commandes - Alpha Client App
///
/// Interface pour visualiser et gérer l'historique des commandes
/// avec filtres, recherche et détails complets.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> 
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
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildBody(),
      ),
    );
  }

  /// 📱 AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface(context),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        'Mes Commandes',
        style: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.textPrimary(context),
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.search,
            color: AppColors.textPrimary(context),
          ),
          onPressed: () => _showSearchDialog(),
        ),
        IconButton(
          icon: Icon(
            Icons.filter_list,
            color: AppColors.textPrimary(context),
          ),
          onPressed: () => _showFiltersDialog(),
        ),
      ],
    );
  }

  /// 🎨 Corps principal
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildStatsSection(),
          const SizedBox(height: 24),
          _buildOrdersSection(),
          const SizedBox(height: 100), // Bottom padding pour navigation
        ],
      ),
    );
  }

  /// 📊 Section statistiques
  Widget _buildStatsSection() {
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
                  '12',
                  Icons.receipt_long,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'En cours',
                  '3',
                  Icons.refresh,
                  AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Terminées',
                  '9',
                  Icons.check_circle,
                  AppColors.success,
                ),
              ),
            ],
          ),
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

  /// 📋 Section des commandes
  Widget _buildOrdersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historique des Commandes',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildComingSoonCard(),
      ],
    );
  }

  /// 🚧 Carte "Bientôt disponible"
  Widget _buildComingSoonCard() {
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
              Icons.construction,
              color: AppColors.info,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Historique des Commandes',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cette fonctionnalité sera bientôt disponible.\nVous pourrez consulter et gérer toutes vos commandes ici.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.info.withOpacity(0.3),
              ),
            ),
            child: Text(
              'En développement',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.info,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}