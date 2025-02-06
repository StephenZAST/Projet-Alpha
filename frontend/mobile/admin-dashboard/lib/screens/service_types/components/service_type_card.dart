import 'package:admin/constants.dart';
import 'package:admin/models/service.dart';
import 'package:admin/models/service_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ServiceTypeCard extends StatelessWidget {
  final ServiceType serviceType;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ServiceTypeCard({
    Key? key,
    required this.serviceType,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        title: Text(serviceType.name, style: AppTextStyles.h4),
        subtitle: serviceType.description != null
            ? Text(serviceType.description!, style: AppTextStyles.bodyMedium)
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: AppColors.primary),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: AppColors.error),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
