import 'package:flutter/material.dart';
import 'components/notification_settings.dart';
import 'components/export_settings.dart';
import 'components/email_template_settings.dart';
import 'components/security_settings.dart';

class SystemSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        NotificationSettings(),
        ExportSettings(),
        EmailTemplateSettings(),
        SecuritySettings(),
      ],
    );
  }
}
