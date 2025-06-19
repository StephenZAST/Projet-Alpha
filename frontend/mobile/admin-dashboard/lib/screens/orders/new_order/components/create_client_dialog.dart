import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants.dart';
import '../../../../controllers/orders_controller.dart';
import '../../../users/components/address_edit_dialog.dart';
import '../../../../services/address_service.dart';
import '../../../../widgets/shared/glass_button.dart';

class CreateClientDialog extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final controller = Get.find<OrdersController>();
  final addressData = Rxn<Map<String, dynamic>>();

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
              // Bouton pour ajouter une adresse
              Align(
                alignment: Alignment.centerLeft,
                child: GlassButton(
                  label: "Ajouter une adresse (optionnel)",
                  icon: Icons.location_on_outlined,
                  variant: GlassButtonVariant.info,
                  onPressed: () async {
                    final result = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (context) => AddressEditDialog(
                        userId:
                            '', // L'utilisateur n'est pas encore créé, on stocke l'adresse temporairement
                        initialAddress: null,
                        onAddressSaved: (address) {
                          addressData.value = address.toJson();
                          Get.back(result: address.toJson());
                        },
                      ),
                    );
                    if (result != null) {
                      addressData.value = result;
                    }
                  },
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlassButton(
                    label: 'Annuler',
                    variant: GlassButtonVariant.secondary,
                    onPressed: () => Get.back(),
                  ),
                  SizedBox(width: AppSpacing.md),
                  GlassButton(
                    label: 'Créer le client',
                    variant: GlassButtonVariant.primary,
                    onPressed: _submitForm,
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

  void _submitForm() async {
    if (formKey.currentState?.validate() ?? false) {
      final clientData = {
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
      };
      // Création du client sans l'adresse
      final user = await controller.createClient(clientData);
      // Si une adresse a été saisie, on la crée avec le user_id retourné
      if (user != null && addressData.value != null) {
        final address = Map<String, dynamic>.from(addressData.value!);
        address['userId'] = user.id;
        await AddressService.createAddress(address);
      }
      Get.back(result: user);
    }
  }
}
