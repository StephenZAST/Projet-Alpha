import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/service_controller.dart';
import '../../../models/service.dart';

class ServiceFormScreen extends StatelessWidget {
  final Service? service;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  ServiceFormScreen({this.service}) {
    if (service != null) {
      _nameController.text = service!.name;
      _priceController.text = service!.price.toString();
      _descriptionController.text = service!.description ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceController>();

    return Dialog(
      child: Container(
        width: 600,
        padding: EdgeInsets.all(defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service == null ? 'Nouveau service' : 'Modifier le service',
                style: AppTextStyles.h3,
              ),
              SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom du service',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Prix',
                  border: OutlineInputBorder(),
                  suffixText: 'FCFA',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le prix est requis';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Prix invalide';
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (service == null) {
                          controller.createService(
                            name: _nameController.text,
                            price: double.parse(_priceController.text),
                            description: _descriptionController.text,
                          );
                        } else {
                          controller.updateService(
                            id: service!.id,
                            name: _nameController.text,
                            price: double.parse(_priceController.text),
                            description: _descriptionController.text,
                          );
                        }
                      }
                    },
                    child: Text(service == null ? 'Créer' : 'Mettre à jour'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
