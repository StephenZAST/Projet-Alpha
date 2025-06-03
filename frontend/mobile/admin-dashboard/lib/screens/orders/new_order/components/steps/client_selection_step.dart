import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../constants.dart';
import '../client_search.dart';

class ClientSelectionStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sélectionner un client', style: AppTextStyles.h3),
          SizedBox(height: AppSpacing.md),
          Expanded(child: ClientSearch()),
        ],
      ),
    );
  }
}
