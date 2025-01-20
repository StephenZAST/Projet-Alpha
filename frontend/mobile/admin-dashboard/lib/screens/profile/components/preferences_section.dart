import 'package:flutter/material.dart';
import '../../../constants.dart';

class PreferencesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preferences', style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: defaultPadding),
        SwitchListTile(
          title: Text('Receive Notifications'),
          value: true,
          onChanged: (value) {
            // TODO: Implement preference change logic
          },
        ),
        SwitchListTile(
          title: Text('Dark Mode'),
          value: false,
          onChanged: (value) {
            // TODO: Implement preference change logic
          },
        ),
      ],
    );
  }
}
