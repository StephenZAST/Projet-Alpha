import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../widgets/shared/glass_container.dart';

class StatisticsCards extends StatelessWidget {
  final currencyFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'FCFA',
    decimalDigits: 0,
  );

  double _calculateGrowth(DashboardController controller) {
    final data = controller.chartData;
    if (data.length < 2) return 0;

    final currentValue = data.last;
    final previousValue = data[data.length - 2];
    if (previousValue == 0) return 0;

    return ((currentValue - previousValue) / previousValue) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState(isDark);
      }

      final revenueGrowth = _calculateGrowth(controller);

      return _AnimatedStatsGrid(
        children: [
          _ModernStatCard(
            title: 'Revenus Totaux',
            value: currencyFormat.format(controller.totalRevenue.value),
            icon: Icons.monetization_on_outlined,
            iconColor: AppColors.success,
            change: revenueGrowth,
            index: 0,
          ),
          _ModernStatCard(
            title: 'Commandes',
            value: controller.totalOrders.toString(),
            icon: Icons.shopping_cart_outlined,
            iconColor: AppColors.primary,
            change: 12.5,
            index: 1,
          ),
          _ModernStatCard(
            title: 'Clients',
            value: controller.totalCustomers.toString(),
            icon: Icons.people_outline,
            iconColor: AppColors.accent,
            change: 8.2,
            index: 2,
          ),
          _ModernStatCard(
            title: 'En cours',
            value: controller.getOrderCountByStatus('PROCESSING').toString(),
            icon: Icons.pending_actions_outlined,
            iconColor: AppColors.warning,
            change: -2.1,
            index: 3,
          ),
        ],
      );
    });
  }

  Widget _buildLoadingState(bool isDark) {
    return _AnimatedStatsGrid(
      children: List.generate(4, (index) => _SkeletonStatCard(index: index)),
    );
  }
}

// Composants modernes pour les statistiques
class _AnimatedStatsGrid extends StatelessWidget {
  final List<Widget> children;

  const _AnimatedStatsGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        final childAspectRatio = _getChildAspectRatio(constraints.maxWidth);

        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) {
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 600 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: children[index],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    if (width > 1200) return 4;
    if (width > 800) return 2;
    return 1;
  }

  double _getChildAspectRatio(double width) {
    if (width > 1200) return 1.2; // Même ratio que affiliate_stats_grid
    if (width > 800) return 1.4;
    return 1.2;
  }
}

class _ModernStatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final double change;
  final int index;

  const _ModernStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.change,
    required this.index,
  });

  @override
  _ModernStatCardState createState() => _ModernStatCardState();
}

class _ModernStatCardState extends State<_ModernStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _hoverController.forward();
      },
      onExit: (_) {
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GlassStatsCard(
              title: widget.title,
              value: widget.value,
              icon: widget.icon,
              iconColor: widget.iconColor,
              subtitle: _buildSubtitle(),
              onTap: () => _handleCardTap(),
            ),
          );
        },
      ),
    );
  }

  String _buildSubtitle() {
    if (widget.change == 0) return '';
    final isPositive = widget.change >= 0;
    final prefix = isPositive ? '+' : '';
    return '$prefix${widget.change.toStringAsFixed(1)}% ce mois';
  }

  void _handleCardTap() {
    // Animation de feedback au tap
    _hoverController.forward().then((_) {
      _hoverController.reverse();
    });

    // Logique de navigation ou action selon le type de carte
    switch (widget.index) {
      case 0: // Revenus
        // Naviguer vers les détails des revenus
        break;
      case 1: // Commandes
        // Naviguer vers la liste des commandes
        break;
      case 2: // Clients
        // Naviguer vers la liste des clients
        break;
      case 3: // En cours
        // Naviguer vers les commandes en cours
        break;
    }
  }
}

class _SkeletonStatCard extends StatefulWidget {
  final int index;

  const _SkeletonStatCard({required this.index});

  @override
  _SkeletonStatCardState createState() => _SkeletonStatCardState();
}

class _SkeletonStatCardState extends State<_SkeletonStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ShimmerBox(
                width: 44,
                height: 44,
                borderRadius: AppRadius.sm,
              ),
              _ShimmerBox(
                width: 60,
                height: 24,
                borderRadius: AppRadius.sm,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerBox(
                width: 120,
                height: 32,
                borderRadius: AppRadius.xs,
              ),
              SizedBox(height: AppSpacing.xs),
              _ShimmerBox(
                width: 80,
                height: 16,
                borderRadius: AppRadius.xs,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.gray700 : AppColors.gray200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// Ancien composant conservé pour compatibilité
