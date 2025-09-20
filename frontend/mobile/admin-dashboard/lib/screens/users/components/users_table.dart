import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../models/user.dart';
import '../../../widgets/shared/glass_container.dart';
import '../../../widgets/shared/glass_button.dart';

class UsersTable extends StatelessWidget {
  final List<User> users;
  final Function(String) onUserSelect;
  final Function(String) onEdit;
  final Function(String) onDelete;

  const UsersTable({
    Key? key,
    required this.users,
    required this.onUserSelect,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    print('[UsersTable] build: users.length = ${users.length}');

    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header row
          Container(
            padding: EdgeInsets.symmetric(
                vertical: AppSpacing.md, horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? AppColors.headerBgDark : AppColors.headerBgLight,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.md),
                topRight: Radius.circular(AppRadius.md),
              ),
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? AppColors.gray700
                          .withOpacity(AppColors.glassBorderDarkOpacity)
                      : AppColors.gray300
                          .withOpacity(AppColors.glassBorderLightOpacity),
                ),
              ),
            ),
            child: Row(
              children: [
                _headerCell('Avatar', flex: 1, isDark: isDark),
                _headerCell('Nom complet', flex: 3, isDark: isDark),
                _headerCell('Email', flex: 3, isDark: isDark),
                _headerCell('Téléphone', flex: 2, isDark: isDark),
                _headerCell('Rôle', flex: 2, isDark: isDark),
                _headerCell('Statut', flex: 1, isDark: isDark),
                _headerCell('Actions', flex: 2, isDark: isDark),
              ],
            ),
          ),

          // Data rows
          if (users.isEmpty)
            Container(
              height: 200,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 48,
                    color: isDark ? AppColors.gray400 : AppColors.gray500,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Aucun utilisateur trouvé',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color:
                          isDark ? AppColors.gray300 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final isEven = index % 2 == 0;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onUserSelect(user.id),
                      hoverColor: _getRoleColor(user.role).withOpacity(0.05),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                          horizontal: AppSpacing.lg,
                        ),
                        decoration: BoxDecoration(
                          // Effet zébrage cohérent avec les autres tables
                          color: isEven
                              ? (isDark ? AppColors.gray900 : AppColors.gray50)
                              : Colors.transparent,
                          border: Border(
                            bottom: BorderSide(
                              color: isDark
                                  ? AppColors.gray700.withOpacity(0.3)
                                  : AppColors.gray200.withOpacity(0.5),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            _avatarCell(user, flex: 1),
                            _nameCell(user, isDark: isDark, flex: 3),
                            _emailCell(user.email, isDark: isDark, flex: 3),
                            _phoneCell(user.phone ?? '-',
                                isDark: isDark, flex: 2),
                            _roleCell(user.role, isDark: isDark, flex: 2),
                            _statusCell(user.isActive, isDark: isDark, flex: 1),
                            _actionsCell(context, user,
                                isDark: isDark, flex: 2),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _headerCell(String label, {int flex = 1, required bool isDark}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.textLight : AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _avatarCell(User user, {int flex = 1}) {
    final roleColor = _getRoleColor(user.role);
    final initials =
        '${user.firstName.substring(0, 1)}${user.lastName.substring(0, 1)}';

    return Expanded(
      flex: flex,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              roleColor.withOpacity(0.2),
              roleColor.withOpacity(0.1),
            ],
          ),
          shape: BoxShape.circle, // Changé pour un avatar full rounded
          border: Border.all(
            color: roleColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            initials,
            style: AppTextStyles.bodySmall.copyWith(
              color: roleColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _nameCell(User user, {int flex = 1, required bool isDark}) {
    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${user.firstName} ${user.lastName}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (user.id.isNotEmpty)
            Text(
              'ID: ${user.id.length > 8 ? user.id.substring(0, 8) + '...' : user.id}',
              style: AppTextStyles.caption.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.textMuted,
              ),
            ),
        ],
      ),
    );
  }

  Widget _emailCell(String email, {int flex = 1, required bool isDark}) {
    return Expanded(
      flex: flex,
      child: Text(
        email,
        style: AppTextStyles.bodySmall.copyWith(
          color: isDark ? AppColors.gray300 : AppColors.textSecondary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _phoneCell(String phone, {int flex = 1, required bool isDark}) {
    return Expanded(
      flex: flex,
      child: Text(
        phone,
        style: AppTextStyles.bodySmall.copyWith(
          color: isDark ? AppColors.gray300 : AppColors.textSecondary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _roleCell(UserRole role, {int flex = 1, required bool isDark}) {
    final color = _getRoleColor(role);
    final icon = _getRoleIcon(role);
    final label = _getRoleLabel(role);

    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: AppRadius.radiusXS,
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusCell(bool isActive, {int flex = 1, required bool isDark}) {
    final color = isActive ? AppColors.success : AppColors.error;
    final icon = isActive ? Icons.check_circle : Icons.cancel;

    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: AppRadius.radiusXS,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 12),
            SizedBox(width: 4),
            Text(
              isActive ? 'Actif' : 'Inactif',
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionsCell(BuildContext context, User user,
      {int flex = 1, required bool isDark}) {
    return Expanded(
      flex: flex,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassButton(
            label: '',
            icon: Icons.visibility_outlined,
            variant: GlassButtonVariant.info,
            size: GlassButtonSize.small,
            onPressed: () => onUserSelect(user.id),
          ),
          SizedBox(width: AppSpacing.xs),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  onEdit(user.id);
                  break;
                case 'delete':
                  onDelete(user.id);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined, size: 18),
                  title: Text('Modifier'),
                  dense: true,
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline,
                      size: 18, color: AppColors.error),
                  title: Text('Supprimer',
                      style: TextStyle(color: AppColors.error)),
                  dense: true,
                ),
              ),
            ],
            icon: Icon(
              Icons.more_vert,
              color: isDark ? AppColors.gray300 : AppColors.gray600,
              size: 18,
            ),
            color: isDark ? AppColors.cardBgDark : AppColors.cardBgLight,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.radiusMD,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.SUPER_ADMIN:
        return AppColors.violet;
      case UserRole.ADMIN:
        return AppColors.primary;
      case UserRole.AFFILIATE:
        return AppColors.orange;
      case UserRole.CLIENT:
        return AppColors.success;
      case UserRole.DELIVERY:
        return AppColors.teal;
      default:
        return AppColors.gray500;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.SUPER_ADMIN:
        return Icons.security;
      case UserRole.ADMIN:
        return Icons.admin_panel_settings;
      case UserRole.AFFILIATE:
        return Icons.handshake_outlined;
      case UserRole.CLIENT:
        return Icons.person_outline;
      case UserRole.DELIVERY:
        return Icons.delivery_dining_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.SUPER_ADMIN:
        return 'Super Admin';
      case UserRole.ADMIN:
        return 'Admin';
      case UserRole.AFFILIATE:
        return 'Affilié';
      case UserRole.CLIENT:
        return 'Client';
      case UserRole.DELIVERY:
        return 'Livreur';
      default:
        return 'Inconnu';
    }
  }
}
