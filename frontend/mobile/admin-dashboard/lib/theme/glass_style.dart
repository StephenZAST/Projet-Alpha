import 'package:flutter/material.dart';
import '../constants.dart';

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
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: color.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: isSelected
          ? [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ]
          : null,
    );
  }
}
