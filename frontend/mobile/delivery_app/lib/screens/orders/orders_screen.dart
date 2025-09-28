import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants.dart';
import '../../controllers/orders_controller.dart';
import '../../models/delivery_order.dart';
import '../../widgets/cards/order_card_mobile.dart';
import '../../widgets/shared/glass_container.dart';

/// 📦 Écran Liste des Commandes - Alpha Delivery App
///
/// Interface mobile-first pour la gestion des commandes livreur.
/// Fonctionnalités : filtres, recherche, pull-to-refresh, navigation détails.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.gray50,
      body: CustomScrollView(
        slivers: [
          // =================================================================
          // 📱 APP BAR AVEC RECHERCHE
          // =================================================================
          _buildSliverAppBar(context, controller, isDark),

          // =================================================================
          // 🔍 FILTRES RAPIDES
          // =================================================================
          SliverToBoxAdapter(
            child: _buildFiltersSection(controller, isDark),
          ),

          // =================================================================
          // 📊 STATISTIQUES RAPIDES
          // =================================================================
          SliverToBoxAdapter(
            child: _buildStatsSection(controller, isDark),
          ),

          // =================================================================
          // 📦 LISTE DES COMMANDES
          // =================================================================
          Obx(() {
            if (controller.isLoading.value && controller.orders.isEmpty) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (controller.hasError.value && controller.orders.isEmpty) {
              return SliverFillRemaining(
                child: _buildErrorState(controller, isDark),
              );
            }

            if (controller.filteredOrders.isEmpty) {
              return SliverFillRemaining(
                child: _buildEmptyState(controller, isDark),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final order = controller.filteredOrders[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: OrderCardMobile(
                        order: order,
                        onTap: () => _navigateToDetails(order),
                        onStatusUpdate: (newStatus) =>
                            controller.updateOrderStatus(order.id, newStatus),
                      ),
                    );
                  },
                  childCount: controller.filteredOrders.length,
                ),
              ),
            );
          }),
        ],
      ),

      // =================================================================
      // 🔄 BOUTON D'ACTUALISATION FLOTTANT
      // =================================================================
      floatingActionButton: Obx(() => AnimatedOpacity(
            opacity: controller.isLoading.value ? 0.5 : 1.0,
            duration: AppAnimations.fast,
            child: FloatingActionButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () => controller.refreshOrders(),
              backgroundColor: AppColors.primary,
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.refresh, color: Colors.white),
            ),
          )),
    );
  }

  /// 📱 App Bar avec recherche intégrée (corrigée)
  Widget _buildSliverAppBar(
    BuildContext context,
    OrdersController controller,
    bool isDark,
  ) {
    return SliverAppBar(
      expandedHeight: 140.0, // Augmenté pour éviter l'overflow
      floating: true,
      pinned: true,
      backgroundColor: isDark ? AppColors.gray800 : AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(
          left: 16,
          bottom: 80, // Ajusté pour laisser place à la recherche
        ),
        title: const Text(
          'Mes Commandes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18, // Taille réduite pour éviter l'overflow
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => Get.toNamed('/orders/search'),
          icon: const Icon(Icons.manage_search, color: Colors.white),
          tooltip: 'Recherche avancée',
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(70), // Augmenté
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: SafeArea(
            top: false,
            child: TextField(
              onChanged: controller.searchOrders,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher par ID, client...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white.withOpacity(0.7),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.radiusMD,
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔍 Section des filtres rapides
  Widget _buildFiltersSection(OrdersController controller, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtres rapides',
            style: AppTextStyles.h4.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 40,
            child: Obx(() => ListView(
                  scrollDirection: Axis.horizontal,
                  children: OrderStatusFilter.values.map((filter) {
                    final isSelected = controller.currentFilter.value == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: FilterChip(
                        label: Text(_getFilterLabel(filter)),
                        selected: isSelected,
                        onSelected: (_) => controller.setFilter(filter),
                        backgroundColor: isDark
                            ? AppColors.gray700
                            : AppColors.gray100,
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.textLight
                                  : AppColors.textPrimary),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    );
                  }).toList(),
                )),
          ),
        ],
      ),
    );
  }

  /// 📊 Section des statistiques rapides
  Widget _buildStatsSection(OrdersController controller, bool isDark) {
    return Obx(() {
      final counts = controller.getOrderCounts();
      final urgentOrders = controller.getUrgentOrders();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: GlassContainer(
                child: Column(
                  children: [
                    Text(
                      '${controller.filteredOrders.length}',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Commandes',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GlassContainer(
                child: Column(
                  children: [
                    Text(
                      '${urgentOrders.length}',
                      style: AppTextStyles.h2.copyWith(
                        color: urgentOrders.isNotEmpty
                            ? AppColors.warning
                            : AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Urgentes',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GlassContainer(
                child: Column(
                  children: [
                    Text(
                      '${counts[OrderStatus.DELIVERED] ?? 0}',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Livrées',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// ❌ État d'erreur
  Widget _buildErrorState(OrdersController controller, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Erreur de chargement',
              style: AppTextStyles.h3.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => controller.fetchOrders(),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📭 État vide
  Widget _buildEmptyState(OrdersController controller, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: isDark ? AppColors.gray400 : AppColors.gray500,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Aucune commande',
              style: AppTextStyles.h3.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              controller.currentFilter.value == OrderStatusFilter.all
                  ? 'Vous n\'avez aucune commande assignée pour le moment'
                  : 'Aucune commande ne correspond à ce filtre',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => controller.refreshOrders(),
              icon: const Icon(Icons.refresh),
              label: const Text('Actualiser'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🧭 Navigation vers les détails
  void _navigateToDetails(DeliveryOrder order) {
    Get.toNamed('/orders/details', arguments: {'order': order});
  }

  /// 🏷️ Labels des filtres
  String _getFilterLabel(OrderStatusFilter filter) {
    switch (filter) {
      case OrderStatusFilter.all:
        return 'Toutes';
      case OrderStatusFilter.pending:
        return 'En attente';
      case OrderStatusFilter.inProgress:
        return 'En cours';
      case OrderStatusFilter.collected:
        return 'Collectées';
      case OrderStatusFilter.delivered:
        return 'Livrées';
    }
  }
}