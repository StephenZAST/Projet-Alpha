import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../models/user.dart';
import '../../../controllers/users_controller.dart';
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
        duration: Duration(seconds: 3),
      );
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
  }

  void _showGlassySnackbar({
    required String message,
    IconData icon = Icons.check_circle,
    Color? color,
    Duration? duration,
  }) {
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
                fontSize: 16,
              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 700,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        decoration: BoxDecoration(
          borderRadius: AppRadius.radiusLG,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadius.radiusLG,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.gray900.withOpacity(0.95)
                    : Colors.white.withOpacity(0.95),
                borderRadius: AppRadius.radiusLG,
                border: Border.all(
                  color: isDark 
                      ? AppColors.gray700.withOpacity(0.5)
                      : AppColors.gray200.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, isDark),
                    Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildEditForm(context, isDark),
                          SizedBox(height: AppSpacing.lg),
                          _buildAddressesSection(context, isDark),
                          SizedBox(height: AppSpacing.xl),
                          _buildActions(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getRoleColor(widget.user.role).withOpacity(0.1),
            _getRoleColor(widget.user.role).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getRoleColor(widget.user.role).withOpacity(0.2),
                  _getRoleColor(widget.user.role).withOpacity(0.1),
                ],
              ),
              borderRadius: AppRadius.radiusMD,
              border: Border.all(
                color: _getRoleColor(widget.user.role).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.edit_outlined,
              size: 32,
              color: _getRoleColor(widget.user.role),
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Éditer l\'utilisateur',
                  style: AppTextStyles.h2.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  '${widget.user.firstName} ${widget.user.lastName}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                _buildRoleBadge(widget.user.role),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
            style: IconButton.styleFrom(
              backgroundColor: isDark 
                  ? AppColors.gray800.withOpacity(0.5)
                  : AppColors.gray100.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radiusSM,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.gray800.withOpacity(0.5)
            : AppColors.gray50.withOpacity(0.8),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark 
              ? AppColors.gray700.withOpacity(0.3)
              : AppColors.gray200.withOpacity(0.5),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Informations personnelles',
                  style: AppTextStyles.h4.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildGlassTextField(
                    controller: firstNameController,
                    label: 'Prénom',
                    icon: Icons.person_outline,
                    isDark: isDark,
                    validator: (v) => v == null || v.isEmpty ? 'Prénom requis' : null,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildGlassTextField(
                    controller: lastNameController,
                    label: 'Nom',
                    icon: Icons.person_outline,
                    isDark: isDark,
                    validator: (v) => v == null || v.isEmpty ? 'Nom requis' : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            _buildGlassTextField(
              controller: emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              isDark: isDark,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v == null || v.isEmpty ? 'Email requis' : null,
            ),
            SizedBox(height: AppSpacing.md),
            _buildGlassTextField(
              controller: phoneController,
              label: 'Téléphone',
              icon: Icons.phone_outlined,
              isDark: isDark,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? AppColors.gray900.withOpacity(0.3)
                          : Colors.white.withOpacity(0.6),
                      borderRadius: AppRadius.radiusSM,
                      border: Border.all(
                        color: _getRoleColor(selectedRole).withOpacity(0.3),
                      ),
                    ),
                    child: DropdownButtonFormField<UserRole>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        labelText: 'Rôle',
                        prefixIcon: Icon(
                          Icons.admin_panel_settings_outlined,
                          color: AppColors.accent.withOpacity(0.7),
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      items: UserRole.values.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(AppSpacing.xs),
                                decoration: BoxDecoration(
                                  color: _getRoleColor(role).withOpacity(0.1),
                                  borderRadius: AppRadius.radiusXS,
                                ),
                                child: Icon(
                                  _getRoleIcon(role),
                                  color: _getRoleColor(role),
                                  size: 16,
                                ),
                              ),
                              SizedBox(width: AppSpacing.sm),
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
                ),
                SizedBox(width: AppSpacing.md),
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? AppColors.gray900.withOpacity(0.3)
                        : Colors.white.withOpacity(0.6),
                    borderRadius: AppRadius.radiusSM,
                    border: Border.all(
                      color: isActive 
                          ? AppColors.success.withOpacity(0.3)
                          : AppColors.error.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
                        color: isActive ? AppColors.success : AppColors.error,
                        size: 20,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'Statut',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? AppColors.textLight : AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Switch(
                        value: isActive,
                        onChanged: (value) => setState(() => isActive = value),
                        activeColor: AppColors.success,
                        inactiveThumbColor: AppColors.error,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            Align(
              alignment: Alignment.centerRight,
              child: GlassButton(
                label: 'Enregistrer les modifications',
                icon: Icons.save_outlined,
                variant: GlassButtonVariant.primary,
                isLoading: isSaving,
                onPressed: isSaving ? null : _saveUserInfo,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressesSection(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.gray800.withOpacity(0.5)
            : AppColors.gray50.withOpacity(0.8),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark 
              ? AppColors.gray700.withOpacity(0.3)
              : AppColors.gray200.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Adresses (${_addresses.length})',
                    style: AppTextStyles.h4.copyWith(
                      color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
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
          SizedBox(height: AppSpacing.md),
          if (isLoadingAddresses)
            Center(
              child: Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_addresses.isEmpty)
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.gray900.withOpacity(0.3)
                    : Colors.white.withOpacity(0.6),
                borderRadius: AppRadius.radiusSM,
                border: Border.all(
                  color: isDark 
                      ? AppColors.gray600.withOpacity(0.2)
                      : AppColors.gray300.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_off_outlined,
                    color: AppColors.textMuted,
                    size: 24,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Aucune adresse enregistrée',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: _addresses.map((address) => _buildAddressItem(context, isDark, address)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressItem(BuildContext context, bool isDark, Address address) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.gray900.withOpacity(0.3)
            : Colors.white.withOpacity(0.6),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(
          color: address.isDefault 
              ? AppColors.primary.withOpacity(0.3)
              : (isDark 
                  ? AppColors.gray600.withOpacity(0.2)
                  : AppColors.gray300.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: address.isDefault 
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.accent.withOpacity(0.1),
              borderRadius: AppRadius.radiusXS,
            ),
            child: Icon(
              address.isDefault ? Icons.home : Icons.location_on,
              color: address.isDefault ? AppColors.primary : AppColors.accent,
              size: 16,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (address.name != null && address.name!.isNotEmpty) ...[
                  Text(
                    address.name!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.textLight : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                ],
                Text(
                  address.fullAddress,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (address.isDefault)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: AppRadius.radiusXS,
              ),
              child: Text(
                'Défaut',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          SizedBox(width: AppSpacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlassButton(
                label: '',
                icon: Icons.edit_outlined,
                variant: GlassButtonVariant.info,
                size: GlassButtonSize.small,
                onPressed: () async {
                  await Get.dialog(AddressEditDialog(
                    userId: widget.user.id,
                    initialAddress: address,
                    onAddressSaved: (a) => _loadAddresses(),
                  ));
                },
              ),
              SizedBox(width: AppSpacing.xs),
              GlassButton(
                label: '',
                icon: Icons.delete_outline,
                variant: GlassButtonVariant.error,
                size: GlassButtonSize.small,
                onPressed: () => _confirmDeleteAddress(address),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAddress(Address address) async {
    final confirm = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.gray900.withOpacity(0.95)
                : Colors.white.withOpacity(0.95),
            borderRadius: AppRadius.radiusLG,
            border: Border.all(
              color: AppColors.error.withOpacity(0.3),
            ),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.radiusLG,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: 48,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Confirmer la suppression',
                      style: AppTextStyles.h4,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Voulez-vous vraiment supprimer cette adresse ?',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: GlassButton(
                            label: 'Annuler',
                            variant: GlassButtonVariant.secondary,
                            onPressed: () => Get.back(result: false),
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: GlassButton(
                            label: 'Supprimer',
                            variant: GlassButtonVariant.error,
                            onPressed: () => Get.back(result: true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (confirm == true) {
      try {
        await AddressService.deleteAddress(address.id);
        _showGlassySnackbar(
          message: 'Adresse supprimée avec succès',
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
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.gray900.withOpacity(0.3)
            : Colors.white.withOpacity(0.6),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(
          color: isDark 
              ? AppColors.gray600.withOpacity(0.2)
              : AppColors.gray300.withOpacity(0.3),
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? AppColors.textLight : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: AppColors.primary.withOpacity(0.7),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppSpacing.md),
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.gray400 : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GlassButton(
          label: 'Fermer',
          icon: Icons.close,
          variant: GlassButtonVariant.secondary,
          onPressed: () => Get.back(),
        ),
      ],
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    final color = _getRoleColor(role);
    final icon = _getRoleIcon(role);
    final label = _getRoleLabel(role);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: AppRadius.radiusSM,
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
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
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
        return role.toString().split('.').last;
    }
  }
}