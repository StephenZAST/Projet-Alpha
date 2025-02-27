import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/users_controller.dart';
import '../../../models/user.dart';

class UserCreateDialog extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _selectedRole = UserRole.CLIENT.obs;

  @override
  Widget build(BuildContext context) {
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
              Text(
                'Créer un utilisateur',
                style: AppTextStyles.h3,
              ),
              SizedBox(height: AppSpacing.lg),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Email requis' : null,
              ),
              SizedBox(height: AppSpacing.md),

              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Mot de passe requis' : null,
              ),

              // Autres champs...

              SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Annuler'),
                  ),
                  SizedBox(width: AppSpacing.md),
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    child: Text('Créer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final controller = Get.find<UsersController>();
      controller.createUser({
        'email': _emailController.text,
        'password': _passwordController.text,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'phone': _phoneController.text,
        'role': _selectedRole.value.toString().split('.').last,
      });
    }
  }
}
