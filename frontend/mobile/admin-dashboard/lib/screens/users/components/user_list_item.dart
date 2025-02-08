import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../models/user.dart';
import './user_edit_dialog.dart';

class UserListItem extends StatelessWidget {
  final User user;

  const UserListItem({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: ListTile(
        contentPadding: EdgeInsets.all(AppSpacing.md),
        leading: _buildAvatar(),
        title: Text(user.fullName, style: AppTextStyles.bodyLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            SizedBox(height: AppSpacing.xs),
            _buildRoleBadge(),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIndicator(),
            SizedBox(width: AppSpacing.md),
            IconButton(
              icon: Icon(Icons.edit_outlined),
              onPressed: () => _showEditDialog(context),
              tooltip: 'Modifier',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      backgroundColor: user.role.color.withOpacity(0.2),
      child: Text(
        user.fullName[0].toUpperCase(),
        style: TextStyle(color: user.role.color),
      ),
    );
  }

  Widget _buildRoleBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: user.role.color.withOpacity(0.1),
        borderRadius: AppRadius.radiusXS,
      ),
      child: Text(
        user.role.label,
        style: AppTextStyles.bodySmall.copyWith(
          color: user.role.color,
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: user.isActive ? AppColors.successLight : AppColors.errorLight,
        borderRadius: AppRadius.radiusXS,
      ),
      child: Text(
        user.isActive ? 'Actif' : 'Inactif',
        style: AppTextStyles.bodySmall.copyWith(
          color: user.isActive ? AppColors.successDark : AppColors.errorDark,
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => UserEditDialog(user: user),
    );
  }
}
