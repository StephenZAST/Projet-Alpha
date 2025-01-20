import 'package:flutter/material.dart';

class StatusUpdateDialog extends StatelessWidget {
  final String orderId;
  final String currentStatus;

  StatusUpdateDialog({
    required this.orderId,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update Order Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
            value: currentStatus,
            items: ['PENDING', 'PROCESSING', 'COMPLETED', 'CANCELLED']
                .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    ))
                .toList(),
            onChanged: (value) {
              // Update status logic
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: Text('Update'),
          onPressed: () {
            // Save status update
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
