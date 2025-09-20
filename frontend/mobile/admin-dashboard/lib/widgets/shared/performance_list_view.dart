import 'package:flutter/material.dart';
import '../../constants.dart';

/// Widget optimisé pour afficher de grandes listes avec de bonnes performances
class PerformanceListView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final double? itemExtent;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final int? maxItemsBeforeOptimization;

  const PerformanceListView({
    Key? key,
    required this.items,
    required this.itemBuilder,
    this.separatorBuilder,
    this.itemExtent,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.maxItemsBeforeOptimization = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Si la liste est petite, utiliser ListView.separated pour les animations
    if (items.length <= (maxItemsBeforeOptimization ?? 20)) {
      return _buildSmallList();
    }
    
    // Pour les grandes listes, utiliser ListView.builder optimisé
    return _buildOptimizedList();
  }

  Widget _buildSmallList() {
    if (separatorBuilder != null) {
      return ListView.separated(
        controller: controller,
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics,
        itemCount: items.length,
        separatorBuilder: separatorBuilder!,
        itemBuilder: (context, index) => itemBuilder(context, items[index], index),
      );
    }

    return ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: items.length,
      itemExtent: itemExtent,
      itemBuilder: (context, index) => itemBuilder(context, items[index], index),
    );
  }

  Widget _buildOptimizedList() {
    return ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: items.length,
      itemExtent: itemExtent ?? 80, // Hauteur fixe pour de meilleures performances
      cacheExtent: 500, // Cache plus d'éléments pour un scroll fluide
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: itemBuilder(context, items[index], index),
        );
      },
    );
  }
}

/// Widget pour afficher un indicateur de performance
class PerformanceIndicator extends StatelessWidget {
  final int itemCount;
  final bool isOptimized;

  const PerformanceIndicator({
    Key? key,
    required this.itemCount,
    required this.isOptimized,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isOptimized 
            ? AppColors.success.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.1),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(
          color: isOptimized 
              ? AppColors.success.withOpacity(0.3)
              : AppColors.warning.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOptimized ? Icons.speed : Icons.info_outline,
            size: 14,
            color: isOptimized ? AppColors.success : AppColors.warning,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            isOptimized 
                ? 'Mode optimisé ($itemCount éléments)'
                : 'Mode standard ($itemCount éléments)',
            style: AppTextStyles.caption.copyWith(
              color: isOptimized ? AppColors.success : AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}