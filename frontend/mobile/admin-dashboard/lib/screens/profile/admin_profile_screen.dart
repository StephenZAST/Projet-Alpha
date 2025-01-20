import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/admin_controller.dart';
import 'components/profile_header.dart';
import 'components/profile_form.dart';
import 'components/password_change_section.dart';
import 'components/preferences_section.dart';

class AdminProfileScreen extends StatelessWidget {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    return Scaffold(
      appBar: AppBar(title: Text('Admin Profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            ProfileHeader(),
            SizedBox(height: defaultPadding),
            ProfileForm(formKey: formKey),
            SizedBox(height: defaultPadding),
            PasswordChangeSection(),
            SizedBox(height: defaultPadding),
            PreferencesSection(),
          ],
        ),
      ),
    );
  }
}
