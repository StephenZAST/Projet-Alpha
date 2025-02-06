import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/service_type_controller.dart';
import '../../../models/service_type.dart';

class ServiceTypeFormDialog extends StatelessWidget {
  final ServiceType? serviceType; // Reste nullable pour supporter les deux cas
  final bool isEditing; // Nouveau paramètre pour indiquer le mode

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  ServiceTypeFormDialog({
    Key? key,
    this.serviceType,
  })  : isEditing = serviceType != null,
        super(key: key) {
    if (isEditing) {
      _nameController.text = serviceType!.name;
      _descriptionController.text = serviceType!.description ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: EdgeInsets.all(defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEditing ? 'Modifier le Type' : 'Nouveau Type de Service',
                style: AppTextStyles.h3,
              ),
              SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
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
                    onPressed: _submitForm,
                    child: Text(isEditing ? 'Mettre à jour' : 'Créer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final controller = Get.find<ServiceTypeController>();

      if (isEditing) {
        // Mode édition
        controller.updateServiceType(
          id: serviceType!.id, // Safe to use ! here because isEditing is true
          name: _nameController.text,
          description: _descriptionController.text,
        );
      } else {
        // Mode création
        controller.createServiceType(
          name: _nameController.text,
          description: _descriptionController.text,
        );
      }
    }
  }
}
