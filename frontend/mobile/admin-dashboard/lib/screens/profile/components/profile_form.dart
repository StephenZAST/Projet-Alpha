import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/admin_profile_controller.dart';
import '../../../widgets/shared/glass_button.dart';

class ProfileForm extends StatefulWidget {
  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final controller = Get.find<AdminProfileController>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() => Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: AppRadius.radiusMD,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informations personnelles',
                  style: AppTextStyles.h3.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                if (!controller.isEditing.value) ...[
                  _buildReadOnlyFields(context, isDark),
                ] else ...[
                  _buildEditableFields(context, isDark),
                ],
                SizedBox(height: AppSpacing.xl),
                _buildActionButtons(context),
              ],
            ),
          ),
        ));
  }

  Widget _buildReadOnlyFields(BuildContext context, bool isDark) {
    final profile = controller.profile.value;
    if (profile == null) return SizedBox.shrink();

    return Column(
      children: [
        _buildInfoRow('Prénom', profile.firstName),
        SizedBox(height: AppSpacing.md),
        _buildInfoRow('Nom', profile.lastName),
        SizedBox(height: AppSpacing.md),
        _buildInfoRow('Email', profile.email),
        SizedBox(height: AppSpacing.md),
        _buildInfoRow('Téléphone', profile.phone ?? 'Non renseigné'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableFields(BuildContext context, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller.firstNameController,
                style: TextStyle(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Prénom',
                  hintText: 'Entrez votre prénom',
                  labelStyle: TextStyle(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.gray400 : AppColors.textMuted,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.gray700
                              .withOpacity(AppColors.glassBorderDarkOpacity)
                          : AppColors.gray200
                              .withOpacity(AppColors.glassBorderLightOpacity),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.gray700
                              .withOpacity(AppColors.glassBorderDarkOpacity)
                          : AppColors.gray200
                              .withOpacity(AppColors.glassBorderLightOpacity),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(
                      color: AppColors.primary.withOpacity(0.8),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.cardBgDark.withOpacity(0.6)
                      : AppColors.cardBgLight.withOpacity(0.6),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le prénom est requis';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextFormField(
                controller: controller.lastNameController,
                style: TextStyle(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Nom',
                  hintText: 'Entrez votre nom',
                  labelStyle: TextStyle(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.gray400 : AppColors.textMuted,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.gray700
                              .withOpacity(AppColors.glassBorderDarkOpacity)
                          : AppColors.gray200
                              .withOpacity(AppColors.glassBorderLightOpacity),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.gray700
                              .withOpacity(AppColors.glassBorderDarkOpacity)
                          : AppColors.gray200
                              .withOpacity(AppColors.glassBorderLightOpacity),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(
                      color: AppColors.primary.withOpacity(0.8),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.cardBgDark.withOpacity(0.6)
                      : AppColors.cardBgLight.withOpacity(0.6),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        TextFormField(
          initialValue: controller.profile.value?.email ?? '',
          enabled: false,
          style: TextStyle(
            color: isDark ? AppColors.gray400 : AppColors.textMuted,
          ),
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Entrez votre email',
            labelStyle: TextStyle(
              color: isDark ? AppColors.gray400 : AppColors.textMuted,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: isDark ? AppColors.gray700 : AppColors.gray300,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: isDark ? AppColors.gray700 : AppColors.gray300,
              ),
            ),
            filled: true,
            fillColor: isDark
                ? AppColors.gray800.withOpacity(0.5)
                : AppColors.gray100.withOpacity(0.5),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: controller.phoneController,
          style: TextStyle(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            labelText: 'Téléphone',
            hintText: 'Entrez votre numéro de téléphone',
            labelStyle: TextStyle(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
            hintStyle: TextStyle(
              color: isDark ? AppColors.gray400 : AppColors.textMuted,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.gray700
                        .withOpacity(AppColors.glassBorderDarkOpacity)
                    : AppColors.gray200
                        .withOpacity(AppColors.glassBorderLightOpacity),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.gray700
                        .withOpacity(AppColors.glassBorderDarkOpacity)
                    : AppColors.gray200
                        .withOpacity(AppColors.glassBorderLightOpacity),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: AppColors.primary.withOpacity(0.8),
                width: 2,
              ),
            ),
            filled: true,
            fillColor: isDark
                ? AppColors.cardBgDark.withOpacity(0.6)
                : AppColors.cardBgLight.withOpacity(0.6),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!RegExp(r'^\+?[\d\s-]+$').hasMatch(value)) {
                return 'Numéro de téléphone invalide';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!controller.isEditing.value) ...[
          GlassButton(
            label: 'Modifier',
            icon: Icons.edit_outlined,
            variant: GlassButtonVariant.primary,
            onPressed: controller.startEditing,
          ),
        ] else ...[
          GlassButton(
            label: 'Annuler',
            icon: Icons.close_outlined,
            variant: GlassButtonVariant.secondary,
            isOutlined: true,
            onPressed: controller.cancelEditing,
          ),
          SizedBox(width: AppSpacing.md),
          GlassButton(
            label: 'Enregistrer',
            icon: Icons.save_outlined,
            variant: GlassButtonVariant.success,
            isLoading: controller.isLoading.value,
            onPressed: controller.isLoading.value
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      controller.updateProfile();
                    }
                  },
          ),
        ],
      ],
    );
  }
}
