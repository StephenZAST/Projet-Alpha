import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  // Helper for role icon
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
        return Icons.person_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<UsersController>();

    return Dialog(
      backgroundColor: isDark ? AppColors.gray900 : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLG),
      child: Container(
        width: 500,
        padding: EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.gray900.withOpacity(0.95)
              : Colors.white.withOpacity(0.95),
          borderRadius: AppRadius.radiusLG,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Créer un utilisateur',
                style: AppTextStyles.h3.copyWith(
                  color: isDark ? Colors.white : AppColors.gray900,
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: 'Prénom',
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.radiusSM,
                          borderSide: BorderSide(color: AppColors.gray300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.radiusSM,
                          borderSide: BorderSide(color: AppColors.gray300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadius.radiusSM,
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Prénom requis' : null,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Nom',
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.radiusSM,
                          borderSide: BorderSide(color: AppColors.gray300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.radiusSM,
                          borderSide: BorderSide(color: AppColors.gray300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadius.radiusSM,
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Nom requis' : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusSM,
                    borderSide: BorderSide(color: AppColors.gray300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.radiusSM,
                    borderSide: BorderSide(color: AppColors.gray300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.radiusSM,
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Email requis';
                  if (!GetUtils.isEmail(value!)) return 'Email invalide';
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusSM,
                    borderSide: BorderSide(color: AppColors.gray300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.radiusSM,
                    borderSide: BorderSide(color: AppColors.gray300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.radiusSM,
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Téléphone requis';
                  if (!GetUtils.isPhoneNumber(value!))
                    return 'Téléphone invalide';
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusSM,
                    borderSide: BorderSide(color: AppColors.gray300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.radiusSM,
                    borderSide: BorderSide(color: AppColors.gray300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.radiusSM,
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Mot de passe requis';
                  if (value.length < 8)
                    return 'Le mot de passe doit contenir au moins 8 caractères';
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.md),
              Container(
                margin: EdgeInsets.only(bottom: AppSpacing.md),
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.gray800.withOpacity(0.7)
                      : AppColors.gray100,
                  borderRadius: AppRadius.radiusSM,
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        "L'adresse pourra être complétée plus tard par le client ou par l'admin. Elle est nécessaire pour la livraison, mais pas obligatoire à la création du compte.",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textLight
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Role selector with icon
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gray300),
                  borderRadius: AppRadius.radiusSM,
                ),
                child: Obx(() => DropdownButton<UserRole>(
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
                              Icon(_getRoleIcon(role),
                                  color: role.color, size: 18),
                              SizedBox(width: 8),
                              Text(role.label,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.gray900,
                                  )),
                            ],
                          ),
                        );
                      }).toList(),
                      isExpanded: true,
                      underline: SizedBox(),
                      icon:
                          Icon(Icons.arrow_drop_down, color: AppColors.primary),
                      dropdownColor: isDark ? AppColors.gray800 : Colors.white,
                    )),
              ),
              SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlassButton(
                    label: 'Annuler',
                    variant: GlassButtonVariant.secondary,
                    onPressed: () => Get.back(),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Obx(() => GlassButton(
                        label: 'Créer',
                        variant: GlassButtonVariant.primary,
                        isLoading: _isSubmitting.value,
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          _isSubmitting.value = true;
                          try {
                            final userData = {
                              'email': _emailController.text,
                              'password': _passwordController.text,
                              'firstName': _firstNameController.text,
                              'lastName': _lastNameController.text,
                              'phone': _phoneController.text,
                              'role': _selectedRole.value
                                  .toString()
                                  .split('.')
                                  .last,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
