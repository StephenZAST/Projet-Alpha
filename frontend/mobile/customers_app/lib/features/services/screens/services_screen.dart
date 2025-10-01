import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';

/// 🏪 Écran des Services - Alpha Client App
///
/// Catalogue des services Alpha Pressing avec catégories,
/// recherche et détails complets des prestations.
class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> 
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
        'Nos Services',
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
          _buildHeroSection(),
          const SizedBox(height: 24),
          _buildCategoriesSection(),
          const SizedBox(height: 24),
          _buildPopularServicesSection(),
          const SizedBox(height: 100), // Bottom padding pour navigation
        ],
      ),
    );
  }

  /// 🎯 Section hero
  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.glassPrimary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.local_laundry_service,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Excellence Alpha',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Services premium de pressing',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Découvrez notre gamme complète de services de pressing professionnel avec des finitions impeccables.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  /// 📂 Section catégories
  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégories de Services',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildCategoryCard(
              'Nettoyage à Sec',
              'Vêtements délicats',
              Icons.dry_cleaning,
              AppColors.primary,
            ),
            _buildCategoryCard(
              'Repassage',
              'Finition parfaite',
              Icons.iron,
              AppColors.warning,
            ),
            _buildCategoryCard(
              'Retouches',
              'Ajustements précis',
              Icons.content_cut,
              AppColors.info,
            ),
            _buildCategoryCard(
              'Express 24h',
              'Service rapide',
              Icons.flash_on,
              AppColors.success,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String title, String subtitle, IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// ⭐ Section services populaires
  Widget _buildPopularServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services Populaires',
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
            'Catalogue Complet',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Le catalogue détaillé de nos services sera bientôt disponible.\nTarifs, descriptions et options personnalisées.',
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

  /// 🔍 Dialog de recherche
  void _showSearchDialog() {
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
              Icons.search,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Rechercher un service',
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
            TextField(
              decoration: InputDecoration(
                hintText: 'Tapez votre recherche...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary(context),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.textSecondary(context),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.border(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                // TODO: Implémenter la logique de recherche en temps réel
              },
            ),
            const SizedBox(height: 16),
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
                      'La recherche sera disponible avec le catalogue complet.',
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