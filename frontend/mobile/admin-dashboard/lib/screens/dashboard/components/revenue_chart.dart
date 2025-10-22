import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../widgets/shared/glass_container.dart';

class RevenueChart extends StatefulWidget {
  @override
  _RevenueChartState createState() => _RevenueChartState();
}

class _RevenueChartState extends State<RevenueChart>
    with SingleTickerProviderStateMixin {
  final currencyFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'FCFA',
    decimalDigits: 0,
  );

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
          child: SlideTransition(
            position: _slideAnimation,
            child: GlassSectionContainer(
              title: 'Évolution des Revenus',
              subtitle: 'Analyse des performances financières',
              icon: Icons.trending_up,
              iconColor: AppColors.success,
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
                  icon: Icons.fullscreen,
                  onPressed: () => _showFullScreenChart(context),
                  tooltip: 'Plein écran',
                ),
              ],
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildLoadingState(isDark);
                }

                final labels = controller.chartLabels;
                final data = controller.chartData;

                if (labels.isEmpty || data.isEmpty) {
                  return _buildEmptyState(isDark);
                }

                return _buildChart(labels, data, isDark);
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PulsingChartIndicator(),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Chargement des données...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Analyse en cours',
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
      height: 300,
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
                Icons.show_chart,
                size: 48,
                color: isDark ? AppColors.gray400 : AppColors.gray500,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Aucune donnée disponible',
              style: AppTextStyles.bodyLarge.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Les données de revenus apparaîtront ici',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<String> labels, List<double> data, bool isDark) {
    return Container(
      height: 320,
      child: Stack(
        children: [
          // Gradient background pour le graphique
          Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
              borderRadius: AppRadius.radiusSM,
            ),
          ),
          SfCartesianChart(
            plotAreaBorderWidth: 0,
            backgroundColor: Colors.transparent,
            margin: EdgeInsets.all(AppSpacing.sm),
            primaryXAxis: CategoryAxis(
              majorGridLines: MajorGridLines(width: 0),
              axisLine: AxisLine(width: 0),
              labelStyle: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.gray600,
                fontWeight: FontWeight.w500,
              ),
              labelRotation: -45,
              interval: 1,
            ),
            primaryYAxis: NumericAxis(
              numberFormat: currencyFormat,
              majorGridLines: MajorGridLines(
                width: 1,
                color: (isDark ? AppColors.gray700 : AppColors.gray200)
                    .withOpacity(0.5),
                dashArray: [5, 5],
              ),
              axisLine: AxisLine(width: 0),
              labelStyle: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.gray600,
                fontWeight: FontWeight.w500,
              ),
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              format: 'point.x : point.y FCFA',
              color: isDark ? AppColors.cardBgDark : AppColors.cardBgLight,
              textStyle: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              borderColor: isDark ? AppColors.gray600 : AppColors.gray300,
              borderWidth: 1,
              elevation: 8,
              canShowMarker: true,
              header: '',
              duration: 1000,
            ),
            series: <CartesianSeries>[
              AreaSeries<_RevenueData, String>(
                dataSource: List.generate(
                  labels.length,
                  (index) => _RevenueData(labels[index], data[index]),
                ),
                xValueMapper: (_RevenueData revenue, _) => revenue.date,
                yValueMapper: (_RevenueData revenue, _) => revenue.amount,
                name: 'Revenus',
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.4),
                    AppColors.primary.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
                borderGradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.accent,
                  ],
                ),
                borderWidth: 3,
                animationDuration: 2000,
                enableTooltip: true,
                markerSettings: MarkerSettings(
                  isVisible: true,
                  shape: DataMarkerType.circle,
                  width: 8,
                  height: 8,
                  borderWidth: 3,
                  borderColor: AppColors.primary,
                  color: isDark ? AppColors.cardBgDark : AppColors.cardBgLight,
                ),
              ),
            ],
          ),
          // Statistiques overlay
          Positioned(
            top: AppSpacing.md,
            right: AppSpacing.md,
            child: _buildStatsOverlay(data, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverlay(List<double> data, bool isDark) {
    if (data.isEmpty) return SizedBox.shrink();

    final total = data.reduce((a, b) => a + b);
    final average = total / data.length;
    final maxValue = data.reduce((a, b) => a > b ? a : b);

    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatItem(
            label: 'Total',
            value: currencyFormat.format(total),
            color: AppColors.success,
            isDark: isDark,
          ),
          SizedBox(height: AppSpacing.xs),
          _StatItem(
            label: 'Moyenne',
            value: currencyFormat.format(average),
            color: AppColors.primary,
            isDark: isDark,
          ),
          SizedBox(height: AppSpacing.xs),
          _StatItem(
            label: 'Maximum',
            value: currencyFormat.format(maxValue),
            color: AppColors.accent,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  void _showFullScreenChart(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: GlassContainer(
            variant: GlassContainerVariant.neutral,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Graphique des Revenus',
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
                  child: RevenueChart(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RevenueData {
  final String date;
  final double amount;

  _RevenueData(this.date, this.amount);
}

// Composants modernes pour le graphique des revenus
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

class _PulsingChartIndicator extends StatefulWidget {
  @override
  _PulsingChartIndicatorState createState() => _PulsingChartIndicatorState();
}

class _PulsingChartIndicatorState extends State<_PulsingChartIndicator>
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
                AppColors.success.withOpacity(_animation.value),
                AppColors.primary.withOpacity(_animation.value),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withOpacity(_animation.value * 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.trending_up,
              color: Colors.white,
              size: 32,
            ),
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.xs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
