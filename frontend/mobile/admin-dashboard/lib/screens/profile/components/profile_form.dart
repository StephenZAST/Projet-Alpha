import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/admin_controller.dart';
import '../../../models/admin.dart';

class ProfileForm extends StatefulWidget {
  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final controller = Get.find<AdminController>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final admin = controller.admin.value;
    _firstNameController = TextEditingController(text: admin?.firstName ?? '');
    _lastNameController = TextEditingController(text: admin?.lastName ?? '');
    _emailController = TextEditingController(text: admin?.email ?? '');
    _phoneController = TextEditingController(text: admin?.phone ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final dto = AdminUpdateDTO(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      controller.updateProfile(dto.toJson());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Form(
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
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
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
                    controller: _lastNameController,
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
              controller: _emailController,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Entrez votre email',
              ),
            ),
            SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _phoneController,
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
            SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Obx(() => ElevatedButton(
                      onPressed:
                          controller.isLoading.value ? null : _handleSubmit,
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
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
