import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/service_controller.dart';
import '../../../models/service.dart';
import '../../../constants.dart';

class ServiceForm extends StatelessWidget {
  final ServiceController controller = Get.find();
  final Service? service;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  ServiceForm({this.service}) {
    if (service != null) {
      nameController.text = service!.name;
      priceController.text = service!.price.toString();
      descriptionController.text = service!.description ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(service == null ? 'Créer un service' : 'Modifier le service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nom du service'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Prix'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prix';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un prix valide';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (service == null) {
                      controller.createService(
                        name: nameController.text,
                        price: double.parse(priceController.text),
                        description: descriptionController.text,
                      );
                    } else {
                      controller.updateService(
                        id: service!.id,
                        name: nameController.text,
                        price: double.parse(priceController.text),
                        description: descriptionController.text,
                      );
                    }
                  }
                },
                child: Text(service == null ? 'Créer' : 'Mettre à jour'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
