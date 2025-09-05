import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../models/user.dart';
import '../../../widgets/shared/glass_button.dart';
import '../../../controllers/users_controller.dart';

class UserCreateDialog extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _selectedRole = UserRole.CLIENT.obs;
  final _isSubmitting = false.obs;
  final _obscurePassword = true.obs;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<UsersController>();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 600,
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPersonalInfoSection(context, isDark),
                            SizedBox(height: AppSpacing.lg),
                            _buildCredentialsSection(context, isDark),
                            SizedBox(height: AppSpacing.lg),
                            _buildRoleSection(context, isDark),
                            SizedBox(height: AppSpacing.lg),
                            _buildInfoCard(context, isDark),
                            SizedBox(height: AppSpacing.xl),
                            _buildActions(context, controller),
                          ],
                        ),
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
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.2),
                  AppColors.primary.withOpacity(0.1),
                ],
              ),
              borderRadius: AppRadius.radiusMD,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.person_add_alt_1,
              size: 28,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Créer un utilisateur',
                  style: AppTextStyles.h2.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Ajouter un nouvel utilisateur au système',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                ),
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

  Widget _buildPersonalInfoSection(BuildContext context, bool isDark) {
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
                  controller: _firstNameController,
                  label: 'Prénom',
                  icon: Icons.person_outline,
                  isDark: isDark,
                  validator: (value) => value?.isEmpty ?? true ? 'Prénom requis' : null,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildGlassTextField(
                  controller: _lastNameController,
                  label: 'Nom',
                  icon: Icons.person_outline,
                  isDark: isDark,
                  validator: (value) => value?.isEmpty ?? true ? 'Nom requis' : null,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _buildGlassTextField(
            controller: _phoneController,
            label: 'Téléphone',
            icon: Icons.phone_outlined,
            isDark: isDark,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Téléphone requis';
              if (!GetUtils.isPhoneNumber(value!)) return 'Téléphone invalide';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialsSection(BuildContext context, bool isDark) {
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
            children: [
              Icon(
                Icons.security_outlined,
                color: AppColors.info,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Identifiants de connexion',
                style: AppTextStyles.h4.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _buildGlassTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            isDark: isDark,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Email requis';
              if (!GetUtils.isEmail(value!)) return 'Email invalide';
              return null;
            },
          ),
          SizedBox(height: AppSpacing.md),
          Obx(() => _buildGlassTextField(
            controller: _passwordController,
            label: 'Mot de passe',
            icon: Icons.lock_outline,
            isDark: isDark,
            obscureText: _obscurePassword.value,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword.value ? Icons.visibility : Icons.visibility_off,
                color: AppColors.primary,
              ),
              onPressed: () => _obscurePassword.value = !_obscurePassword.value,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Mot de passe requis';
              if (value.length < 8) return 'Au moins 8 caractères requis';
              return null;
            },
          )),
        ],
      ),
    );
  }

  Widget _buildRoleSection(BuildContext context, bool isDark) {
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
            children: [
              Icon(
                Icons.admin_panel_settings_outlined,
                color: AppColors.accent,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Rôle et permissions',
                style: AppTextStyles.h4.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Obx(() => Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark 
                  ? AppColors.gray900.withOpacity(0.3)
                  : Colors.white.withOpacity(0.6),
              borderRadius: AppRadius.radiusSM,
              border: Border.all(
                color: _getRoleColor(_selectedRole.value).withOpacity(0.3),
              ),
            ),
            child: DropdownButton<UserRole>(
              value: _selectedRole.value,
              onChanged: (UserRole? newValue) {
                if (newValue != null) {
                  _selectedRole.value = newValue;
                }
              },
              items: UserRole.values.map((UserRole role) {
                return DropdownMenuItem<UserRole>(
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
                      Text(
                        role.label,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? Colors.white : AppColors.gray900,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              isExpanded: true,
              underline: SizedBox(),
              icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
              dropdownColor: isDark ? AppColors.gray800 : Colors.white,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(
          color: AppColors.info.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.info,
            size: 20,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              "L'adresse pourra être complétée plus tard par le client ou par l'admin. Elle est nécessaire pour la livraison, mais pas obligatoire à la création du compte.",
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
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
        obscureText: obscureText,
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
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppSpacing.md),
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.gray400 : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, UsersController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GlassButton(
          label: 'Annuler',
          icon: Icons.close,
          variant: GlassButtonVariant.secondary,
          onPressed: () => Get.back(),
        ),
        SizedBox(width: AppSpacing.md),
        Obx(() => GlassButton(
          label: 'Créer l\'utilisateur',
          icon: Icons.person_add_alt_1,
          variant: GlassButtonVariant.primary,
          isLoading: _isSubmitting.value,
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            _isSubmitting.value = true;
            try {
              final userData = {
                'email': _emailController.text.trim(),
                'password': _passwordController.text,
                'firstName': _firstNameController.text.trim(),
                'lastName': _lastNameController.text.trim(),
                'phone': _phoneController.text.trim(),
                'role': _selectedRole.value.toString().split('.').last,
              };
              await controller.createUser(userData);
            } catch (e) {
              // Error snackbar is handled by controller.safeCall
            } finally {
              _isSubmitting.value = false;
            }
          },
        )),
      ],
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
}