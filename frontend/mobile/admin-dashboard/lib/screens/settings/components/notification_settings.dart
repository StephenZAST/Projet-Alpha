import 'package:flutter/material.dart';

class NotificationSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text('Receive Notifications'),
      value: true,
      onChanged: (value) {
        // TODO: Implement preference change logic
      },
    );
  }
}
