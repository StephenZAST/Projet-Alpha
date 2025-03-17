import 'package:admin/screens/users/components/user_edit_dialog.dart';
import 'package:admin/widgets/shared/action_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/user.dart';
import '../../../controllers/users_controller.dart';
import '../../../constants.dart';

class UserListItem extends StatelessWidget {
  final User user;
  final UsersController controller = Get.find();

  UserListItem({required this.user, Key? key}) : super(key: key);

  // Ajout des méthodes onEdit et onDelete
  void onEdit() {
    Get.dialog(
      UserEditDialog(user: user),
      barrierDismissible: false,
    );
  }

  void onDelete() {
    controller.deleteUser(user.id, user.fullName);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      title: Row(
        children: [
          Text(
            '${user.firstName} ${user.lastName}',
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(width: 8),
          _buildRoleBadge(user.role),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.email),
          if (user.phone != null) Text(user.phone!),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ActionButton(
            icon: Icons.edit_rounded,
            label: '', // Pas de label pour la vue liste
            color: AppColors.primary, // Bleu pour modifier
            onTap: onEdit, // Utilisation de la méthode onEdit
            variant: ActionButtonVariant.ghost,
            isCompact: true,
          ),
          SizedBox(width: AppSpacing.xs),
          ActionButton(
            icon: Icons.delete_rounded,
            label: '', // Pas de label pour la vue liste
            color: AppColors.error, // Rouge pour supprimer
            onTap: onDelete, // Utilisation de la méthode onDelete
            variant: ActionButtonVariant.ghost,
            isCompact: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getRoleColor(role).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getRoleColor(role)),
      ),
      child: Text(
        _getRoleLabel(role),
        style: TextStyle(
          color: _getRoleColor(role),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
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
      default:
        return role.toString().split('.').last;
    }
  }
}
