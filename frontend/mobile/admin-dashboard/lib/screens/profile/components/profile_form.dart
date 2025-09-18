import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/admin_profile_controller.dart';

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
                decoration: InputDecoration(
                  labelText: 'Prénom',
                  hintText: 'Entrez votre prénom',
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
                decoration: InputDecoration(
                  labelText: 'Nom',
                  hintText: 'Entrez votre nom',
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
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Entrez votre email',
          ),
        ),
        SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: controller.phoneController,
          decoration: InputDecoration(
            labelText: 'Téléphone',
            hintText: 'Entrez votre numéro de téléphone',
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
          ElevatedButton(
            onPressed: controller.startEditing,
            child: Text('Modifier'),
          ),
        ] else ...[
          TextButton(
            onPressed: controller.cancelEditing,
            child: Text('Annuler'),
          ),
          SizedBox(width: AppSpacing.md),
          ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      controller.updateProfile();
                    }
                  },
            child: controller.isLoading.value
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text('Enregistrer'),
          ),
        ],
      ],
    );
  }
}
