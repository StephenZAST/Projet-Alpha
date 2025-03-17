import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../constants.dart';

class RoleBadge extends StatelessWidget {
  final UserRole role;
  final double? fontSize;
  final bool showIcon;

  const RoleBadge({
    Key? key,
    required this.role,
    this.fontSize,
    this.showIcon = true,
  }) : super(key: key);

  Color _getRoleColor() {
    switch (role) {
      case UserRole.SUPER_ADMIN:
        return Colors.purple;
      case UserRole.ADMIN:
        return AppColors.error;
      case UserRole.AFFILIATE:
        return AppColors.accent;
      case UserRole.CLIENT:
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getRoleIcon() {
    switch (role) {
      case UserRole.SUPER_ADMIN:
        return Icons.security;
      case UserRole.ADMIN:
        return Icons.admin_panel_settings;
      case UserRole.AFFILIATE:
        return Icons.handshake;
      case UserRole.CLIENT:
        return Icons.person;
      default:
        return Icons.person_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getRoleColor();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              _getRoleIcon(),
              size: 14,
              color: color,
            ),
            SizedBox(width: 6),
          ],
          Text(
            role.label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
