import 'package:flutter/material.dart';
import '../constants.dart';
import 'dart:ui';

class GlassStyle {
  static BoxDecoration containerDecoration({
    required BuildContext context,
    Color? color,
    double opacity = 0.1,
    double borderOpacity = 0.2,
    double borderRadius = 12.0,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = color ?? (isDark ? AppColors.gray800 : Colors.white);

    return BoxDecoration(
      color: baseColor.withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: (color ?? (isDark ? AppColors.gray700 : AppColors.gray200))
            .withOpacity(borderOpacity),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black12 : Colors.black.withOpacity(0.03),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration buttonDecoration({
    required BuildContext context,
    required Color color,
    bool isSelected = false,
    double blurRadius = 5,
    double backgroundOpacity = 0.1,
    double borderOpacity = 0.2,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: color.withOpacity(isSelected ? 0.15 : 0.1),
      borderRadius: AppRadius.radiusFull,
      border: Border.all(
        color: color.withOpacity(borderOpacity),
        width: 1,
      ),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(backgroundOpacity),
          color.withOpacity(backgroundOpacity * 0.8),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.1),
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
        BoxShadow(
          color: isDark ? Colors.black12 : Colors.white.withOpacity(0.5),
          blurRadius: blurRadius,
          offset: Offset(-1, -1),
        ),
      ],
    );
  }

  static BoxDecoration modalDecoration({
    required BuildContext context,
    Color? color,
    double opacity = 0.1,
    double borderOpacity = 0.2,
    double borderRadius = 12.0,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = color ?? (isDark ? AppColors.gray800 : Colors.white);

    return BoxDecoration(
      color: baseColor.withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: (color ?? (isDark ? AppColors.gray700 : AppColors.gray200))
            .withOpacity(borderOpacity),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black12 : Colors.black.withOpacity(0.03),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          baseColor.withOpacity(opacity * 1.2),
          baseColor.withOpacity(opacity * 0.8),
        ],
      ),
    );
  }
}
