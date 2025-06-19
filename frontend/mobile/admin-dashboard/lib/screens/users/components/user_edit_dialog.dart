import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/user.dart';
import '../../../controllers/users_controller.dart';
import '../../../controllers/auth_controller.dart'; // Ajout de l'import manquant
import '../../../constants.dart';
import 'address_edit_dialog.dart';
import '../../../models/address.dart';
import '../../../services/user_service.dart';
import '../../../widgets/shared/glass_button.dart';

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
    selectedRole = widget.user.role; // Initialiser avec le rôle actuel
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
              SizedBox(height: AppSpacing.md),
              // Bouton pour ajouter/modifier l'adresse
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.location_on_outlined),
                  label: Text('Ajouter / Modifier l\'adresse'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                    foregroundColor: AppColors.white,
                  ),
                  onPressed: () async {
                    // Charger l'adresse principale existante du client
                    Address? initialAddress;
                    try {
                      final addresses =
                          await UserService.getUserAddresses(widget.user.id);
                      if (addresses.isNotEmpty) {
                        initialAddress = addresses.firstWhere(
                          (a) => a.isDefault,
                          orElse: () => addresses.first,
                        );
                      }
                    } catch (e) {
                      print('[UserEditDialog] Erreur chargement adresse: $e');
                    }
                    await showDialog(
                      context: context,
                      builder: (context) => AddressEditDialog(
                        userId: widget.user.id,
                        initialAddress: initialAddress,
                        onAddressSaved: (address) async {
                          // Optionnel: recharger l'utilisateur ou afficher un message
                        },
                      ),
                    );
                  },
                ),
              ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rôle actuel : ${_getRoleLabel(widget.user.role)}',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<UserRole>(
          value: selectedRole,
          decoration: InputDecoration(
            labelText: 'Nouveau rôle',
            border: OutlineInputBorder(borderRadius: AppRadius.radiusSM),
            filled: true,
            fillColor: isDark
                ? Colors.grey[800]
                : Colors.grey[100], // Remplacement des couleurs non définies
          ),
          items: _getAvailableRoles().map((role) {
            // Suppression du paramètre controller
            return DropdownMenuItem(
              value: role,
              child: Row(
                children: [
                  Icon(_getRoleIcon(role),
                      color: _getRoleColor(role), size: 18),
                  SizedBox(width: 8),
                  Text(_getRoleLabel(role)),
                ],
              ),
            );
          }).toList(),
          onChanged: (role) {
            if (role != null) setState(() => selectedRole = role);
          },
        ),
      ],
    );
  }

  List<UserRole> _getAvailableRoles() {
    // Méthode modifiée
    final currentUser = Get.find<AuthController>().user.value;
    if (currentUser?.role == UserRole.SUPER_ADMIN) {
      return UserRole.values.toList();
    }
    return UserRole.values
        .where((role) => role != UserRole.SUPER_ADMIN && role != UserRole.ADMIN)
        .toList();
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
      default:
        return Icons.person_outline;
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
        GlassButton(
          label: 'Annuler',
          variant: GlassButtonVariant.secondary,
          onPressed: () => Get.back(),
        ),
        SizedBox(width: AppSpacing.md),
        GlassButton(
          label: 'Enregistrer',
          variant: GlassButtonVariant.primary,
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
        ),
      ],
    );
  }
}
