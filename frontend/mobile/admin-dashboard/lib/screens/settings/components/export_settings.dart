import 'package:flutter/material.dart';

class ExportSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text('Enable Export'),
      value: true,
      onChanged: (value) {
        // TODO: Implement preference change logic
      },
    );
  }
}
