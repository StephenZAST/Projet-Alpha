import 'package:flutter/material.dart';
import '../../../models/delivery.dart';
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

  Widget _buildStatusDropdown(bool isDark) {
    return DropdownButtonFormField<DeliveryStatus>(
      value: selectedStatus,
      decoration: InputDecoration(
        labelText: 'Statut',
        border: OutlineInputBorder(borderRadius: AppRadius.radiusMD),
        filled: true,
        fillColor: isDark ? AppColors.gray700 : AppColors.gray100,
      ),
      items: DeliveryStatus.values.map((DeliveryStatus status) {
        return DropdownMenuItem<DeliveryStatus>(
          value: status,
          child: Text(status.label),
        );
      }).toList(),
      onChanged: (DeliveryStatus? newValue) {
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
          onPressed: () {
            // TODO: Implémenter la logique de mise à jour du statut
            Navigator.of(context).pop();
          },
          child: Text('Mettre à jour'),
        ),
      ],
    );
  }
  // ... rest of the implementation with the helper methods ...
}
