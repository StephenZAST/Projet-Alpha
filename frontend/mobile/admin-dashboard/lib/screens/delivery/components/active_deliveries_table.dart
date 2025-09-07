import 'package:flutter/material.dart';
import '../../../constants.dart';

class ActiveDeliveriesTable extends StatelessWidget {
  const ActiveDeliveriesTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.radiusMD,
      ),
      child: Center(child: Text('Active deliveries placeholder')),
    );
  }
}
