import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants.dart';
import '../../../../controllers/orders_controller.dart';

class CreateClientDialog extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController =
      TextEditingController(); // Ajout du controller pour le mot de passe
  final controller = Get.find<OrdersController>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        width: 500,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Créer un nouveau client', style: AppTextStyles.h3),
              SizedBox(height: AppSpacing.lg),
              _buildTextField(
                controller: firstNameController,
                label: 'Prénom',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ce champ est requis' : null,
              ),
              SizedBox(height: AppSpacing.md),
              _buildTextField(
                controller: lastNameController,
                label: 'Nom',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ce champ est requis' : null,
              ),
              SizedBox(height: AppSpacing.md),
              _buildTextField(
                controller: emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Ce champ est requis';
                  if (!GetUtils.isEmail(value!)) return 'Email invalide';
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.md),
              _buildTextField(
                controller: phoneController,
                label: 'Téléphone',
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: AppSpacing.md),
              _buildTextField(
                controller: passwordController,
                label: 'Mot de passe temporaire',
                isPassword: true,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ce champ est requis' : null,
              ),
              SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Annuler'),
                  ),
                  SizedBox(width: AppSpacing.md),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Créer le client'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  void _submitForm() {
    if (formKey.currentState?.validate() ?? false) {
      controller.createClient({
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'password': passwordController.text, // Ajout du mot de passe
      });
    }
  }
}
