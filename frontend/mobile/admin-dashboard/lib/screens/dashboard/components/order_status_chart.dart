import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../models/enums.dart';
import '../../../widgets/shared/glass_container.dart';

class OrderStatusChart extends StatefulWidget {
  @override
  _OrderStatusChartState createState() => _OrderStatusChartState();
}

class _OrderStatusChartState extends State<OrderStatusChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: GlassSectionContainer(
            title: 'Répartition des Commandes',
            subtitle: 'Analyse des statuts en temps réel',
            icon: Icons.pie_chart,
            iconColor: AppColors.accent,
            actions: [
              _ModernChartButton(
                icon: Icons.refresh,
                onPressed: () {
                  controller.refreshDashboard();
                  _animationController.reset();
                  _animationController.forward();
                },
                tooltip: 'Actualiser',
              ),
              SizedBox(width: AppSpacing.sm),
              _ModernChartButton(
                icon: Icons.analytics,
                onPressed: () => _showDetailedAnalysis(context),
                tooltip: 'Analyse détaillée',
              ),
            ],
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState(isDark);
              }

              if (controller.orderStatusCount.isEmpty) {
                return _buildEmptyState(isDark);
              }

              return _buildChart(controller, isDark);
            }),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Container(
      height: 350,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PulsingPieIndicator(),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Analyse des commandes...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Calcul des statistiques',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      height: 350,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.gray700 : AppColors.gray200)
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.pie_chart_outline,
                size: 48,
                color: isDark ? AppColors.gray400 : AppColors.gray500,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Aucune commande trouvée',
              style: AppTextStyles.bodyLarge.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Les statistiques apparaîtront ici',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(DashboardController controller, bool isDark) {
    final displayedStatuses = [
      OrderStatus.PENDING,
      OrderStatus.PROCESSING,
      OrderStatus.DELIVERING,
      OrderStatus.DELIVERED,
      OrderStatus.CANCELLED,
    ];

    final data = displayedStatuses
        .map((status) {
          final count = controller.getOrderCountByStatus(status.name);
          return _ChartData(
            status.label,
            count.toDouble(),
            status.color,
          );
        })
        .where((item) => item.value > 0)
        .toList();

    final total = data.fold<double>(0, (sum, item) => sum + item.value);

    return Container(
      height: 380,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Gradient background
                Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.8,
                      colors: [
                        AppColors.primary.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: _rotationAnimation.value * 0.1,
                  child: SfCircularChart(
                    backgroundColor: Colors.transparent,
                    legend: Legend(isVisible: false),
                    annotations: [
                      CircularChartAnnotation(
                        widget: _buildCenterAnnotation(total, isDark),
                      ),
                    ],
                    series: <CircularSeries>[
                      DoughnutSeries<_ChartData, String>(
                        dataSource: data,
                        xValueMapper: (_ChartData data, _) => data.label,
                        yValueMapper: (_ChartData data, _) => data.value,
                        pointColorMapper: (_ChartData data, _) => data.color,
                        animationDuration: 2000,
                        innerRadius: '65%',
                        radius: '85%',
                        strokeWidth: 2,
                        strokeColor: isDark 
                            ? AppColors.cardBgDark 
                            : AppColors.cardBgLight,
                        dataLabelSettings: DataLabelSettings(
                          isVisible: false,
                        ),
                        enableTooltip: true,
                      ),
                    ],
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      color: isDark ? AppColors.cardBgDark : AppColors.cardBgLight,
                      textStyle: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.textLight : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      borderColor: isDark ? AppColors.gray600 : AppColors.gray300,
                      borderWidth: 1,
                      elevation: 8,
                      duration: 1000,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          _buildModernLegend(data, total, isDark),
        ],
      ),
    );
  }

  Widget _buildCenterAnnotation(double total, bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.md),
      borderRadius: 50,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            total.toInt().toString(),
            style: AppTextStyles.h1.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Commandes',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernLegend(List<_ChartData> data, double total, bool isDark) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.center,
      children: data.map((item) => _ModernLegendItem(
        color: item.color,
        label: item.label,
        value: item.value.toInt(),
        total: total,
        isDark: isDark,
      )).toList(),
    );
  }

  void _showDetailedAnalysis(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.7,
          child: GlassContainer(
            variant: GlassContainerVariant.neutral,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Analyse Détaillée des Commandes',
                      style: AppTextStyles.h3.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.textLight
                            : AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Expanded(
                  child: OrderStatusChart(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartData {
  final String label;
  final double value;
  final Color color;

  _ChartData(this.label, this.value, this.color);
}

// Composants modernes pour le graphique des statuts
class _ModernChartButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const _ModernChartButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  _ModernChartButtonState createState() => _ModernChartButtonState();
}

class _ModernChartButtonState extends State<_ModernChartButton>
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
              decoration: BoxDecoration(
                color: _isHovered
                    ? (isDark ? AppColors.gray700 : AppColors.gray100)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(
                  widget.icon,
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  size: 20,
                ),
                onPressed: widget.onPressed,
                tooltip: widget.tooltip,
                splashRadius: 20,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PulsingPieIndicator extends StatefulWidget {
  @override
  _PulsingPieIndicatorState createState() => _PulsingPieIndicatorState();
}

class _PulsingPieIndicatorState extends State<_PulsingPieIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.6,
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
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accent.withOpacity(_animation.value),
                AppColors.primary.withOpacity(_animation.value),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(_animation.value * 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.pie_chart,
              color: Colors.white,
              size: 32,
            ),
          ),
        );
      },
    );
  }
}

class _ModernLegendItem extends StatefulWidget {
  final Color color;
  final String label;
  final int value;
  final double total;
  final bool isDark;

  const _ModernLegendItem({
    required this.color,
    required this.label,
    required this.value,
    required this.total,
    required this.isDark,
  });

  @override
  _ModernLegendItemState createState() => _ModernLegendItemState();
}

class _ModernLegendItemState extends State<_ModernLegendItem>
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

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.value / widget.total * 100).toStringAsFixed(1);

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
              variant: GlassContainerVariant.neutral,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              borderRadius: AppRadius.lg,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withOpacity(0.4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.label,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: widget.isDark 
                              ? AppColors.textLight 
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${widget.value} · $percentage%',
                        style: AppTextStyles.caption.copyWith(
                          color: widget.isDark 
                              ? AppColors.gray400 
                              : AppColors.gray600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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

// Ancien composant conservé pour compatibilité
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  final double total;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value / total * 100).toStringAsFixed(1);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4),
          Text(
            '($value · $percentage%)',
            style: AppTextStyles.bodySmall.copyWith(
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
