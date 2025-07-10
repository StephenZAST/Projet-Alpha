import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/user.dart';
import '../../../controllers/users_controller.dart';
import '../../../controllers/auth_controller.dart'; // Ajout de l'import manquant
import '../../../constants.dart';
import 'address_edit_dialog.dart';
import '../../../models/address.dart';
import '../../../services/user_service.dart';
import '../../../services/address_service.dart';
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
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late UserRole selectedRole;
  late bool isActive;
  final _formKey = GlobalKey<FormState>();
  bool isSaving = false;
  List<Address> _addresses = [];
  bool isLoadingAddresses = false;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.user.firstName);
    lastNameController = TextEditingController(text: widget.user.lastName);
    emailController = TextEditingController(text: widget.user.email);
    phoneController = TextEditingController(text: widget.user.phone ?? '');
    selectedRole = widget.user.role;
    isActive = widget.user.isActive;
    _loadAddresses();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    setState(() => isLoadingAddresses = true);
    try {
      _addresses = await UserService.getUserAddresses(widget.user.id);
    } catch (e) {
      _showGlassySnackbar(
          message: 'Impossible de charger les adresses',
          icon: Icons.error_outline,
          color: AppColors.error,
          duration: Duration(seconds: 3));
    }
    setState(() => isLoadingAddresses = false);
  }

  Future<void> _saveUserInfo() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isSaving = true);
    final controller = Get.find<UsersController>();
    await controller.updateUser(
      userId: widget.user.id,
      email: emailController.text.trim(),
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      phone: phoneController.text.trim(),
      role: selectedRole,
      isActive: isActive,
    );
    setState(() => isSaving = false);
    // Le dialog sera fermé et la notification affichée par le controller
  }

  void _showGlassySnackbar(
      {required String message,
      IconData icon = Icons.check_circle,
      Color? color,
      Duration? duration}) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
          ),
        ],
      ),
      backgroundColor: (color ?? AppColors.success).withOpacity(0.85),
      borderRadius: 16,
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      snackPosition: SnackPosition.TOP,
      duration: duration ?? Duration(seconds: 2),
      boxShadows: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
      isDismissible: true,
      overlayBlur: 2.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Détails de l\'utilisateur',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _buildEditForm(),
              const SizedBox(height: 16),
              _buildAddressesSection(),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: firstNameController,
            decoration: InputDecoration(labelText: 'Prénom'),
            validator: (v) => v == null || v.isEmpty ? 'Prénom requis' : null,
          ),
          TextFormField(
            controller: lastNameController,
            decoration: InputDecoration(labelText: 'Nom'),
            validator: (v) => v == null || v.isEmpty ? 'Nom requis' : null,
          ),
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(labelText: 'Email'),
            validator: (v) => v == null || v.isEmpty ? 'Email requis' : null,
          ),
          TextFormField(
            controller: phoneController,
            decoration: InputDecoration(labelText: 'Téléphone'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<UserRole>(
                  value: selectedRole,
                  decoration: InputDecoration(labelText: 'Rôle'),
                  items: UserRole.values.map((role) {
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
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Text('Actif'),
                  Switch(
                    value: isActive,
                    onChanged: (value) => setState(() => isActive = value),
                    activeColor: AppColors.success,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GlassButton(
              label: 'Enregistrer les modifications',
              variant: GlassButtonVariant.primary,
              isLoading: isSaving,
              onPressed: isSaving ? null : _saveUserInfo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Adresses', style: Theme.of(context).textTheme.titleMedium),
            GlassButton(
              label: 'Ajouter',
              icon: Icons.add_location_alt,
              variant: GlassButtonVariant.info,
              size: GlassButtonSize.small,
              onPressed: () async {
                await Get.dialog(AddressEditDialog(
                  userId: widget.user.id,
                  onAddressSaved: (address) => _loadAddresses(),
                ));
              },
            ),
          ],
        ),
        isLoadingAddresses
            ? Center(child: CircularProgressIndicator())
            : _addresses.isEmpty
                ? Text('Aucune adresse enregistrée')
                : Column(
                    children: _addresses
                        .map((address) => ListTile(
                              title: Text(address.fullAddress),
                              subtitle: Text(address.name ?? ''),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () async {
                                      await Get.dialog(AddressEditDialog(
                                        userId: widget.user.id,
                                        initialAddress: address,
                                        onAddressSaved: (a) => _loadAddresses(),
                                      ));
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () async {
                                      final confirm = await Get.dialog<bool>(
                                        AlertDialog(
                                          title:
                                              Text('Confirmer la suppression'),
                                          content: Text(
                                              'Voulez-vous vraiment supprimer cette adresse ?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Get.back(result: false),
                                              child: Text('Annuler'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Get.back(result: true),
                                              child: Text('Supprimer',
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        try {
                                          await AddressService.deleteAddress(
                                              address.id);
                                          _showGlassySnackbar(
                                            message:
                                                'Adresse supprimée avec succès',
                                            icon: Icons.delete,
                                            color: AppColors.success,
                                          );
                                          _loadAddresses();
                                        } catch (e) {
                                          _showGlassySnackbar(
                                            message: 'Suppression impossible',
                                            icon: Icons.error_outline,
                                            color: AppColors.error,
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
      ],
    );
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
}
