import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../constants.dart';

class UserGridItem extends StatelessWidget {
  final User user;

  const UserGridItem({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  radius: 16,
                  child: Text(
                    '${user.firstName[0]}${user.lastName[0]}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
                Icon(
                  user.isActive ? Icons.check_circle : Icons.cancel,
                  color: user.isActive ? AppColors.success : AppColors.error,
                  size: 16,
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              '${user.firstName} ${user.lastName}',
              style: textTheme.titleSmall?.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              user.email,
              style: textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getRoleColor(user.role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                user.role.toString().split('.').last,
                style: TextStyle(
                  color: _getRoleColor(user.role),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.ADMIN:
      case UserRole.SUPER_ADMIN:
        return AppColors.error;
      case UserRole.AFFILIATE:
        return AppColors.accent;
      case UserRole.CLIENT:
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }
}
