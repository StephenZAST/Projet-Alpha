import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/delivery.dart';
import '../../../controllers/delivery_controller.dart';
import '../../../constants.dart';

class UpdateStatusDialog extends StatefulWidget {
  final Delivery delivery;

  const UpdateStatusDialog({
    Key? key,
    required this.delivery,
  }) : super(key: key);

  @override
  State<UpdateStatusDialog> createState() => _UpdateStatusDialogState();
}

class _UpdateStatusDialogState extends State<UpdateStatusDialog> {
  late DeliveryStatus selectedStatus;
  final notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.delivery.status;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMD),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mettre à jour - Commande #${widget.delivery.orderId}',
              style: AppTextStyles.h4,
            ),
            SizedBox(height: AppSpacing.lg),
            _buildStatusDropdown(isDark),
            SizedBox(height: AppSpacing.md),
            _buildNotesField(isDark),
            SizedBox(height: AppSpacing.lg),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  // ... rest of the implementation with the helper methods ...
}
