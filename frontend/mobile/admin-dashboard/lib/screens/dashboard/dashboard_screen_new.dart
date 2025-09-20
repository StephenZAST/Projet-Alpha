import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../constants.dart';
import '../../responsive.dart';
import '../../controllers/dashboard_controller.dart';
import '../../widgets/shared/glass_container.dart';
import 'components/header.dart';
import 'components/statistics_cards.dart';
import 'components/revenue_chart.dart';
import 'components/recent_orders.dart';
import 'components/order_status_metrics.dart';
import 'components/order_status_chart.dart';

class DashboardScreenNew extends StatefulWidget {
  const DashboardScreenNew({Key? key}) : super(key: key);

  @override
  _DashboardScreenNewState createState() => _DashboardScreenNewState();
}

class _DashboardScreenNewState extends State<DashboardScreenNew>
    with TickerProviderStateMixin {
  late AnimationController _cascadeController;
  late List<Animation<double>> _cascadeAnimations;
  final int _componentCount = 5; // Réduit de 6 à 5 (sans FAB)

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startCascadeAnimation();
  }

  void _setupAnimations() {
    _cascadeController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _cascadeAnimations = List.generate(_componentCount, (index) {
      final start = index * 0.1;
      final end = start + 0.6;
      
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _cascadeController,
        curve: Interval(
          start.clamp(0.0, 1.0),
          end.clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ));
    });
  }

  void _startCascadeAnimation() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        _cascadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _cascadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();

    return Container(
      key: Key('dashboard_container_new'),
      decoration: BoxDecoration(
        gradient: _buildBackgroundGradient(context),
      ),
      child: _ModernRefreshIndicator(
        onRefresh: () async {
          await controller.refreshDashboard();
          _cascadeController.reset();
          _startCascadeAnimation();
        },
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildModernLoadingState();
          }

          if (controller.hasError.value) {
            return _buildModernErrorState(controller);
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(defaultPadding),
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildAnimatedComponent(0, Header(title: "Tableau de bord")),
                SizedBox(height: defaultPadding),
                _buildAnimatedComponent(1, StatisticsCards()),
                SizedBox(height: defaultPadding),
                _buildAnimatedComponent(2, RevenueChart()),
                SizedBox(height: defaultPadding),
                _buildAnimatedComponent(3, OrderStatusMetrics()),
                SizedBox(height: defaultPadding),
                _buildAnimatedComponent(4, _buildMainContent(context)),
                // Pas de FAB ici - évite le problème Positioned
              ],
            ),
          );
        }),
      ),
    );
  }

  LinearGradient _buildBackgroundGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (isDark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.gray900,
          AppColors.gray800.withOpacity(0.8),
          AppColors.gray900,
        ],
        stops: [0.0, 0.5, 1.0],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.gray50,
          Colors.white.withOpacity(0.8),
          AppColors.gray100.withOpacity(0.3),
        ],
        stops: [0.0, 0.5, 1.0],
      );
    }
  }

  Widget _buildAnimatedComponent(int index, Widget child) {
    if (index >= _cascadeAnimations.length) return child;
    
    return AnimatedBuilder(
      animation: _cascadeAnimations[index],
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _cascadeAnimations[index].value)),
          child: Opacity(
            opacity: _cascadeAnimations[index].value,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildModernLoadingState() {
    return Center(
      child: GlassContainer(
        variant: GlassContainerVariant.neutral,
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PulsingLoadingIndicator(),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Chargement du tableau de bord...',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textLight
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Récupération des dernières données',
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.gray400
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernErrorState(DashboardController controller) {
    return Center(
      child: GlassContainer(
        variant: GlassContainerVariant.error,
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Erreur de chargement',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              controller.errorMessage.value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textLight
                    : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: controller.fetchDashboardData,
              icon: Icon(Icons.refresh),
              label: Text('Réessayer'),
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

  Widget _buildMainContent(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                RecentOrders(),
                SizedBox(height: defaultPadding),
              ],
            ),
          ),
          SizedBox(width: defaultPadding),
          Expanded(
            flex: 1,
            child: OrderStatusChart(),
          ),
        ],
      );
    }

    return Column(
      children: [
        OrderStatusChart(),
        SizedBox(height: defaultPadding),
        RecentOrders(),
      ],
    );
  }
}

// Composants modernes pour le dashboard
class _ModernRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const _ModernRefreshIndicator({
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.cardBgDark
          : AppColors.cardBgLight,
      color: AppColors.primary,
      strokeWidth: 3.0,
      displacement: 60.0,
      child: child,
    );
  }
}

class _PulsingLoadingIndicator extends StatefulWidget {
  @override
  _PulsingLoadingIndicatorState createState() => _PulsingLoadingIndicatorState();
}

class _PulsingLoadingIndicatorState extends State<_PulsingLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(_animation.value),
                AppColors.accent.withOpacity(_animation.value),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(_animation.value * 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
        );
      },
    );
  }
}