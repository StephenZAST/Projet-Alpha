import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/admin_controller.dart';

class PasswordChangeSection extends StatelessWidget {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Change Password',
              style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: defaultPadding),
          TextFormField(
            controller: currentPasswordController,
            decoration: InputDecoration(
              labelText: 'Current Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) =>
                value!.isEmpty ? 'Current password is required' : null,
          ),
          SizedBox(height: defaultPadding),
          TextFormField(
            controller: newPasswordController,
            decoration: InputDecoration(
              labelText: 'New Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) =>
                value!.isEmpty ? 'New password is required' : null,
          ),
          SizedBox(height: defaultPadding),
          TextFormField(
            controller: confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) => value != newPasswordController.text
                ? 'Passwords do not match'
                : null,
          ),
          SizedBox(height: defaultPadding),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // TODO: Implement password change logic
                Get.snackbar('Success', 'Password changed successfully');
              }
            },
            child: Text('Change Password'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }
}
