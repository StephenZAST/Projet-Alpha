import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/user.dart';
import '../../../controllers/users_controller.dart';
import '../../../constants.dart';

class UserEditDialog extends StatefulWidget {
  final User user;

  const UserEditDialog({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<UserEditDialog> {
  late UserRole selectedRole;
  late bool isActive;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    selectedRole = widget.user.role;
    isActive = widget.user.isActive;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMD),
      child: Container(
        width: 500,
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Modifier l\'utilisateur', style: AppTextStyles.h3),
              SizedBox(height: AppSpacing.lg),
              _buildUserInfo(),
              SizedBox(height: AppSpacing.lg),
              _buildRoleSelector(controller, isDark),
              SizedBox(height: AppSpacing.md),
              _buildStatusToggle(isDark),
              SizedBox(height: AppSpacing.xl),
              _buildActionButtons(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nom complet: ${widget.user.fullName}'),
        Text('Email: ${widget.user.email}'),
        if (widget.user.phone != null) Text('Téléphone: ${widget.user.phone}'),
        Text(
            'Inscrit le: ${widget.user.createdAt.toLocal().toString().split('.')[0]}'),
      ],
    );
  }

  Widget _buildRoleSelector(UsersController controller, bool isDark) {
    return DropdownButtonFormField<UserRole>(
      value: selectedRole,
      decoration: InputDecoration(
        labelText: 'Rôle',
        border: OutlineInputBorder(borderRadius: AppRadius.radiusSM),
      ),
      items: UserRole.values
          .map((role) => DropdownMenuItem(
                value: role,
                child: Text(role.label),
              ))
          .toList(),
      onChanged: (role) {
        if (role != null) setState(() => selectedRole = role);
      },
    );
  }

  Widget _buildStatusToggle(bool isDark) {
    return Row(
      children: [
        Text('Statut du compte:', style: AppTextStyles.bodyMedium),
        SizedBox(width: AppSpacing.md),
        Switch(
          value: isActive,
          onChanged: (value) => setState(() => isActive = value),
          activeColor: AppColors.success,
        ),
        SizedBox(width: AppSpacing.sm),
        Text(
          isActive ? 'Actif' : 'Inactif',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isActive ? AppColors.success : AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(UsersController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Annuler'),
        ),
        SizedBox(width: AppSpacing.md),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              await controller.updateUser(
                userId: widget.user.id,
                role: selectedRole,
                isActive: isActive,
              );
              Get.back();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
          ),
          child: Text('Enregistrer'),
        ),
      ],
    );
  }
}
