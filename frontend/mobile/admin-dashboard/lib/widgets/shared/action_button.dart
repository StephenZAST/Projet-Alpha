import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../theme/glass_style.dart';

enum ActionButtonVariant {
  filled, // Fond coloré plein
  outlined, // Bordure colorée sans fond
  ghost, // Transparent avec couleur au hover
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final ActionButtonVariant variant;
  final bool isCompact; // Nouveau paramètre

  const ActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.variant = ActionButtonVariant.ghost,
    this.isCompact = false, // Par défaut, mode normal
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusFull,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? AppSpacing.sm : AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: _getButtonDecoration(isDark),
          child: Row(
            mainAxisAlignment:
                isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: isCompact ? 16 : 18,
                color: _getIconColor(isDark),
              ),
              if (!isCompact && label.isNotEmpty) ...[
                SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    label,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: _getTextColor(isDark),
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _getButtonDecoration(bool isDark) {
    switch (variant) {
      case ActionButtonVariant.filled:
        return BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: AppRadius.radiusFull,
          border: Border.all(color: color, width: 1),
        );
      case ActionButtonVariant.outlined:
        return BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: AppRadius.radiusFull,
          border: Border.all(color: color.withOpacity(0.5), width: 1),
        );
      case ActionButtonVariant.ghost:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: AppRadius.radiusFull,
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        );
    }
  }

  Color _getIconColor(bool isDark) {
    switch (variant) {
      case ActionButtonVariant.filled:
        return Colors.white;
      case ActionButtonVariant.outlined:
      case ActionButtonVariant.ghost:
        return color;
    }
  }

  Color _getTextColor(bool isDark) {
    switch (variant) {
      case ActionButtonVariant.filled:
        return Colors.white;
      case ActionButtonVariant.outlined:
      case ActionButtonVariant.ghost:
        return color;
    }
  }
}
