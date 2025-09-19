import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../controllers/flash_orders_controller.dart';
import '../../../constants.dart';
import '../../../widgets/shared/glass_container.dart';
import 'components/flash_order_card.dart';
import 'components/flash_order_stepper.dart';
import '../../../controllers/flash_order_stepper_controller.dart';
import '../../../routes/admin_routes.dart';

class FlashOrdersScreen extends StatefulWidget {
  @override
  _FlashOrdersScreenState createState() => _FlashOrdersScreenState();
}

class _FlashOrdersScreenState extends State<FlashOrdersScreen>
    with TickerProviderStateMixin {
  final FlashOrdersController controller = Get.find<FlashOrdersController>();
  late AnimationController _animationController;
  late AnimationController _headerAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _headerFadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOut,
    ));

    _headerAnimationController.forward();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Column(
        children: [
          _buildModernAppBar(isDark),
          Expanded(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildBody(isDark),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernAppBar(bool isDark) {
    return AnimatedBuilder(
      animation: _headerAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _headerFadeAnimation,
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + AppSpacing.md,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.warning.withOpacity(0.1),
                  AppColors.accent.withOpacity(0.05),
                ],
              ),
            ),
            child: Row(
              children: [
                _ModernBackButton(
                  onPressed: () => Get.offAllNamed(AdminRoutes.orders),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.warning, AppColors.warning.withOpacity(0.8)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.flash_on,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'Commandes Flash',
                            style: AppTextStyles.h2.copyWith(
                              color: isDark ? AppColors.textLight : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'Convertissez les commandes flash en commandes complètes',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                _ModernStatsCard(controller: controller, isDark: isDark),
                SizedBox(width: AppSpacing.md),
                _ModernRefreshButton(
                  onPressed: controller.refreshOrders,
                  isLoading: controller.isLoading,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState(isDark);
        }

        if (controller.hasError.value) {
          return _buildErrorState(isDark);
        }

        if (controller.draftOrders.isEmpty) {
          return _buildEmptyState(isDark);
        }

        return _buildOrdersList(isDark);
      }),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.warning, AppColors.warning.withOpacity(0.6)],
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Chargement des commandes flash...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: GlassContainer(
        variant: GlassContainerVariant.error,
        padding: EdgeInsets.all(AppSpacing.xl),
        borderRadius: AppRadius.xl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 32,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Erreur de chargement',
              style: AppTextStyles.h3.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              controller.errorMessage.value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.gray700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            _ModernActionButton(
              label: 'Réessayer',
              icon: Icons.refresh,
              onPressed: controller.refreshOrders,
              variant: _FlashActionVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: GlassContainer(
        variant: GlassContainerVariant.neutral,
        padding: EdgeInsets.all(AppSpacing.xl),
        borderRadius: AppRadius.xl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.warning.withOpacity(0.2),
                    AppColors.warning.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.flash_off,
                color: AppColors.warning,
                size: 40,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Aucune commande flash',
              style: AppTextStyles.h3.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Il n\'y a actuellement aucune commande flash en attente de conversion.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.gray700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            _ModernActionButton(
              label: 'Actualiser',
              icon: Icons.refresh,
              onPressed: controller.refreshOrders,
              variant: _FlashActionVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(bool isDark) {
    return RefreshIndicator(
      onRefresh: controller.refreshOrders,
      color: AppColors.warning,
      child: ListView.separated(
        itemCount: controller.draftOrders.length,
        separatorBuilder: (context, index) => SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final order = controller.draftOrders[index];
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: FlashOrderCard(
                    order: order,
                    onTap: () => _showConversionDialog(order),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showConversionDialog(Order order) {
    final stepperController = Get.put(FlashOrderStepperController());
    stepperController.initDraftFromFlashOrder(order);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 900,
          height: MediaQuery.of(context).size.height * 0.9,
          child: GlassContainer(
            variant: GlassContainerVariant.neutral,
            padding: EdgeInsets.zero,
            borderRadius: AppRadius.xl,
            child: FlashOrderStepper(),
          ),
        ),
      ),
    );
  }
}

// Composants modernes pour l'écran Flash Orders
enum _FlashActionVariant { primary, secondary }

class _ModernBackButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _ModernBackButton({required this.onPressed});

  @override
  _ModernBackButtonState createState() => _ModernBackButtonState();
}

class _ModernBackButtonState extends State<_ModernBackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isHovered
                    ? (isDark ? AppColors.gray700 : AppColors.gray100)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.gray600 : AppColors.gray300,
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(24),
                  child: Center(
                    child: Icon(
                      Icons.arrow_back,
                      color: isDark ? AppColors.textLight : AppColors.textPrimary,
                      size: 24,
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

class _ModernStatsCard extends StatelessWidget {
  final FlashOrdersController controller;
  final bool isDark;

  const _ModernStatsCard({
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.draftOrders.length;
      
      return GlassContainer(
        variant: GlassContainerVariant.warning,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        borderRadius: AppRadius.lg,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'En attente',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  count == 1 ? 'commande' : 'commandes',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _ModernRefreshButton extends StatefulWidget {
  final VoidCallback onPressed;
  final RxBool isLoading;

  const _ModernRefreshButton({
    required this.onPressed,
    required this.isLoading,
  });

  @override
  _ModernRefreshButtonState createState() => _ModernRefreshButtonState();
}

class _ModernRefreshButtonState extends State<_ModernRefreshButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GlassContainer(
              variant: GlassContainerVariant.accent,
              padding: EdgeInsets.all(AppSpacing.md),
              borderRadius: AppRadius.lg,
              onTap: widget.onPressed,
              child: Obx(() {
                return AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  child: widget.isLoading.value
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Transform.rotate(
                          angle: _rotationAnimation.value * 2 * 3.14159,
                          child: Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}

class _ModernActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final _FlashActionVariant variant;

  const _ModernActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.variant,
  });

  @override
  _ModernActionButtonState createState() => _ModernActionButtonState();
}

class _ModernActionButtonState extends State<_ModernActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getVariantColor() {
    switch (widget.variant) {
      case _FlashActionVariant.primary:
        return AppColors.warning;
      case _FlashActionVariant.secondary:
        return AppColors.gray600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final variantColor = _getVariantColor();

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GlassContainer(
              variant: widget.variant == _FlashActionVariant.primary
                  ? GlassContainerVariant.warning
                  : GlassContainerVariant.neutral,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              borderRadius: AppRadius.lg,
              onTap: widget.onPressed,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.variant == _FlashActionVariant.primary
                        ? Colors.white
                        : variantColor,
                    size: 20,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.label,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: widget.variant == _FlashActionVariant.primary
                          ? Colors.white
                          : variantColor,
                      fontWeight: FontWeight.w600,
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
