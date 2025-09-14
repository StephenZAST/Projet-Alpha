import 'package:flutter/material.dart';
import 'dart:ui';
import '../../constants.dart';
import '../../widgets/shared/glass_button.dart';
import '../../widgets/shared/glass_container.dart';
import 'subscription_plans_tab.dart';
import 'subscribed_users_tab.dart';
import 'components/subscription_stats_grid.dart';

class SubscriptionManagementPage extends StatefulWidget {
  const SubscriptionManagementPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionManagementPage> createState() => _SubscriptionManagementPageState();
}

class _SubscriptionManagementPageState extends State<SubscriptionManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.gray50,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec hauteur flexible
              Flexible(
                flex: 0,
                child: _buildHeader(context, isDark),
              ),
              SizedBox(height: AppSpacing.md),

              // Contenu principal scrollable
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Statistiques globales
                      SubscriptionStatsGrid(),
                      SizedBox(height: AppSpacing.lg),

                      // Onglets avec design moderne
                      _buildModernTabBar(context, isDark),
                      SizedBox(height: AppSpacing.md),

                      // Contenu des onglets avec hauteur contrainte
                      Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            SubscriptionPlansTab(),
                            SubscribedUsersTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestion des Abonnements',
              style: AppTextStyles.h1.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'Gérez vos plans d\'abonnement et suivez vos abonnés',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            GlassButton(
              label: 'Rapports',
              icon: Icons.analytics_outlined,
              variant: GlassButtonVariant.info,
              onPressed: () => _showReportsDialog(),
            ),
            SizedBox(width: AppSpacing.sm),
            GlassButton(
              label: 'Actualiser',
              icon: Icons.refresh_outlined,
              variant: GlassButtonVariant.secondary,
              size: GlassButtonSize.small,
              onPressed: () {
                // Force le rebuild des tabs
                setState(() {});
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernTabBar(BuildContext context, bool isDark) {
    return GlassContainer(
      padding: EdgeInsets.all(AppSpacing.xs),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary.withOpacity(0.15),
          borderRadius: AppRadius.radiusMD,
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.primary,
        unselectedLabelColor: isDark ? AppColors.gray400 : AppColors.gray600,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.bodyMedium,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.subscriptions_outlined, size: 18),
                SizedBox(width: AppSpacing.xs),
                Text('Plans d\'abonnement'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 18),
                SizedBox(width: AppSpacing.xs),
                Text('Utilisateurs abonnés'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReportsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassContainer(
          width: 600,
          height: 400,
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.analytics_outlined, color: AppColors.primary),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Rapports d\'Abonnements',
                    style: AppTextStyles.h3.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textLight
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bar_chart_outlined,
                        size: 64,
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'Rapports détaillés',
                        style: AppTextStyles.h4,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        'Fonctionnalité en cours de développement',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              GlassButton(
                label: 'Fermer',
                variant: GlassButtonVariant.secondary,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
