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

class DashboardScreen extends StatefulWidget {
  static GlobalKey<State<StatefulWidget>> dashboardKey =
      GlobalKey(debugLabel: 'dashboard_screen');

  DashboardScreen({Key? key}) : super(key: key ?? GlobalKey());

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _cascadeController;
  late List<Animation<double>> _cascadeAnimations;
  final int _componentCount = 6; // Nombre de composants à animer

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
      key: Key('dashboard_container'),
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

          return Stack(
            children: [
              SingleChildScrollView(
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
                  ],
                ),
              ),
              // FAB directement dans le Stack sans animation wrapper
              _buildModernFAB(controller),
            ],
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
            _ModernButton(
              onPressed: controller.fetchDashboardData,
              icon: Icons.refresh,
              label: 'Réessayer',
              variant: _ModernButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFAB(DashboardController controller) {
    return Positioned(
      right: defaultPadding,
      bottom: defaultPadding,
      child: _FloatingRefreshButton(
        onPressed: () async {
          await controller.refreshDashboard();
          _cascadeController.reset();
          _startCascadeAnimation();
        },
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

enum _ModernButtonVariant { primary, secondary, success, error }

class _ModernButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final _ModernButtonVariant variant;

  const _ModernButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.variant,
  });

  @override
  _ModernButtonState createState() => _ModernButtonState();
}

class _ModernButtonState extends State<_ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getVariantColor() {
    switch (widget.variant) {
      case _ModernButtonVariant.primary:
        return AppColors.primary;
      case _ModernButtonVariant.secondary:
        return AppColors.gray600;
      case _ModernButtonVariant.success:
        return AppColors.success;
      case _ModernButtonVariant.error:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final variantColor = _getVariantColor();

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    variantColor,
                    variantColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: AppRadius.radiusMD,
                boxShadow: [
                  BoxShadow(
                    color: variantColor.withOpacity(0.3),
                    blurRadius: _isPressed ? 8 : 12,
                    offset: Offset(0, _isPressed ? 2 : 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.label,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FloatingRefreshButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _FloatingRefreshButton({required this.onPressed});

  @override
  _FloatingRefreshButtonState createState() => _FloatingRefreshButtonState();
}

class _FloatingRefreshButtonState extends State<_FloatingRefreshButton>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _scaleController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _scaleController.reverse();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotationAnimation, _scaleAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GlassContainer(
              variant: GlassContainerVariant.primary,
              padding: EdgeInsets.all(AppSpacing.md),
              borderRadius: 28,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _rotationController.forward().then((_) {
                      _rotationController.reset();
                    });
                    widget.onPressed();
                  },
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    width: 56,
                    height: 56,
                    child: Center(
                      child: Transform.rotate(
                        angle: _rotationAnimation.value * 2 * 3.14159,
                        child: Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
