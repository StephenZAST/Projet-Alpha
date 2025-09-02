import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../models/user.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.radiusMD,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                _headerCell('ID', flex: 2),
                _headerCell('Nom', flex: 3),
                _headerCell('Prénom', flex: 3),
                _headerCell('Téléphone', flex: 3),
                _headerCell('Email', flex: 4),
                _headerCell('Rôle', flex: 2),
                _headerCell('Actions', flex: 3),
              ],
            ),
          ),
          // Data rows
          if (users.isEmpty)
            Container(
              height: 120,
              alignment: Alignment.center,
              child: Text('Aucun utilisateur trouvé',
                  style: AppTextStyles.bodyMedium),
            )
          else
            SizedBox(
              height:
                  420, // hauteur fixe pour le scroll, à ajuster selon besoin
              child: ListView.separated(
                itemCount: users.length,
                separatorBuilder: (_, __) => Divider(height: 1),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return InkWell(
                    onTap: () => onUserSelect(user.id),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: index % 2 == 0
                            ? (isDark ? AppColors.gray900 : AppColors.gray50)
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          _dataCell(user.id, flex: 2),
                          _dataCell(user.firstName, flex: 3),
                          _dataCell(user.lastName, flex: 3),
                          _dataCell(user.phone ?? '-', flex: 3),
                          _dataCell(user.email, flex: 4),
                          _roleCell(user.role, flex: 2),
                          _actionsCell(context, user.id, flex: 3),
                        ],
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

  Widget _headerCell(String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: AppTextStyles.bodyBold,
      ),
    );
  }

  Widget _dataCell(String value, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        value,
        style: AppTextStyles.bodySmall,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _roleCell(UserRole role, {int flex = 1}) {
    final color = _getRoleColor(role);
    final icon = _getRoleIcon(role);
    final label = _getRoleLabel(role);
    return Expanded(
      flex: flex,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          SizedBox(width: 6),
          Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _actionsCell(BuildContext context, String userId, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.visibility, color: AppColors.primary),
            tooltip: 'Voir détails',
            onPressed: () => onUserSelect(userId),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: AppColors.accent),
            tooltip: 'Éditer',
            onPressed: () => onEdit(userId),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: AppColors.error),
            tooltip: 'Supprimer',
            onPressed: () => onDelete(userId),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.SUPER_ADMIN:
        return Colors.deepPurple;
      case UserRole.ADMIN:
        return Colors.blue;
      case UserRole.AFFILIATE:
        return Colors.orange;
      case UserRole.CLIENT:
        return Colors.green;
      case UserRole.DELIVERY:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.SUPER_ADMIN:
        return Icons.security;
      case UserRole.ADMIN:
        return Icons.admin_panel_settings;
      case UserRole.AFFILIATE:
        return Icons.handshake;
      case UserRole.CLIENT:
        return Icons.person;
      case UserRole.DELIVERY:
        return Icons.delivery_dining;
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
