import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/admin_controller.dart';
import '../../../models/admin.dart';

class ProfileForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  ProfileForm({required this.formKey});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    return Obx(() {
      final admin = controller.admin.value;
      if (admin != null) {
        nameController.text = admin.name;
        emailController.text = admin.email;
      }

      return Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value!.isEmpty ? 'Name is required' : null,
            ),
            SizedBox(height: defaultPadding),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value!.isEmpty ? 'Email is required' : null,
            ),
            SizedBox(height: defaultPadding),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final dto = AdminUpdateDTO(
                    name: nameController.text,
                    email: emailController.text,
                  );
                  controller.updateProfile(dto);
                }
              },
              child: Text('Update Profile'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      );
    });
  }
}
