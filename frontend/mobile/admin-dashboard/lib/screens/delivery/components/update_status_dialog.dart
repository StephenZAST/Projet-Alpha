import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/delivery.dart';
import '../../../models/enums.dart';
import '../../../constants.dart';
import '../../../controllers/delivery_controller.dart';

class UpdateStatusDialog extends StatefulWidget {
  final DeliveryOrder delivery;

  const UpdateStatusDialog({
    Key? key,
    required this.delivery,
  }) : super(key: key);

  @override
  State<UpdateStatusDialog> createState() => _UpdateStatusDialogState();
}

class _UpdateStatusDialogState extends State<UpdateStatusDialog> {
  late OrderStatus selectedStatus;
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
              'Mettre à jour - Commande #${widget.delivery.id}',
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

  Widget _buildStatusDropdown(bool isDark) {
    return DropdownButtonFormField<OrderStatus>(
      value: selectedStatus,
      decoration: InputDecoration(
        labelText: 'Statut',
        border: OutlineInputBorder(borderRadius: AppRadius.radiusMD),
        filled: true,
        fillColor: isDark ? AppColors.gray700 : AppColors.gray100,
      ),
      items: OrderStatus.values.map((OrderStatus status) {
        return DropdownMenuItem<OrderStatus>(
          value: status,
          child: Text(status.toDisplayString()),
        );
      }).toList(),
      onChanged: (OrderStatus? newValue) {
        setState(() {
          selectedStatus = newValue!;
        });
      },
    );
  }

  Widget _buildNotesField(bool isDark) {
    return TextField(
      controller: notesController,
      decoration: InputDecoration(
        labelText: 'Notes',
        border: OutlineInputBorder(borderRadius: AppRadius.radiusMD),
        filled: true,
        fillColor: isDark ? AppColors.gray700 : AppColors.gray100,
      ),
      maxLines: 3,
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Annuler'),
        ),
        SizedBox(width: AppSpacing.md),
        ElevatedButton(
          onPressed: () async {
            final controller = Get.find<DeliveryController>();
            try {
              // Call controller to update status
              await controller.updateOrderStatus(
                widget.delivery.id,
                selectedStatus.name,
                note: notesController.text.isNotEmpty
                    ? notesController.text
                    : null,
              );

              Navigator.of(context).pop();
            } catch (e) {
              Get.snackbar('Erreur', 'Impossible de mettre à jour le statut');
            }
          },
          child: Text('Mettre à jour'),
        ),
      ],
    );
  }
  // ... rest of the implementation with the helper methods ...
}
