import 'package:admin/theme/glass_style.dart';
import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../constants.dart';
import '../../../widgets/shared/action_button.dart';
import '../../../widgets/shared/role_badge.dart';

class UserGridItem extends StatelessWidget {
  final User user;
  final Function(User) onEdit;
  final Function(User) onDelete;

  const UserGridItem({
    Key? key,
    required this.user,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.transparent,
      child: Container(
        decoration: GlassStyle.containerDecoration(
          context: context,
          opacity: isDark ? 0.2 : 0.1,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Réduire la taille de l'avatar pour les écrans moyens
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircleAvatar(
                          backgroundColor: user.role.color.withOpacity(0.1),
                          child: Text(
                            user.firstName[0].toUpperCase(),
                            style: TextStyle(
                              color: user.role.color,
                              fontSize: 14, // Réduire la taille de la police
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          user.fullName,
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        user.isActive ? Icons.check_circle : Icons.cancel,
                        color:
                            user.isActive ? AppColors.success : AppColors.error,
                        size: 16,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                          fontSize: 13, // Réduire la taille de la police
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1, // Limiter à une ligne
                  ),
                  SizedBox(height: AppSpacing.sm),
                  RoleBadge(role: user.role),
                ],
              ),
            ),
            Divider(color: isDark ? AppColors.gray700 : AppColors.gray200),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, // Réduire le padding horizontal
                vertical: AppSpacing.xs, // Réduire le padding vertical
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Détermine si on doit utiliser un layout compact
                  final isCompact = constraints.maxWidth < 280;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: isCompact
                        ? _buildCompactButtons()
                        : _buildRegularButtons(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCompactButtons() {
    return [
      Expanded(
        child: ActionButton(
          icon: Icons.edit_rounded,
          label: '', // Pas de label en mode compact
          color: AppColors.primary,
          onTap: () => onEdit(user),
          variant: ActionButtonVariant.ghost,
          isCompact: true,
        ),
      ),
      SizedBox(width: AppSpacing.xs),
      Expanded(
        child: ActionButton(
          icon: Icons.delete_rounded,
          label: '', // Pas de label en mode compact
          color: AppColors.error,
          onTap: () => onDelete(user),
          variant: ActionButtonVariant.outlined,
          isCompact: true,
        ),
      ),
    ];
  }

  List<Widget> _buildRegularButtons() {
    return [
      Expanded(
        child: ActionButton(
          icon: Icons.edit_rounded,
          label: 'Modifier',
          color: AppColors.primary,
          onTap: () => onEdit(user),
          variant: ActionButtonVariant.ghost,
        ),
      ),
      SizedBox(width: AppSpacing.xs),
      Expanded(
        child: ActionButton(
          icon: Icons.delete_rounded,
          label: 'Supprimer',
          color: AppColors.error,
          onTap: () => onDelete(user),
          variant: ActionButtonVariant.outlined,
        ),
      ),
    ];
  }
}
