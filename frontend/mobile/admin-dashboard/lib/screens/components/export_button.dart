import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/export_controller.dart';

class ExportButton extends StatelessWidget {
  final List<dynamic> data;
  final String type;

  const ExportButton({
    required this.data,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExportController>();

    return PopupMenuButton<ExportFormat>(
      icon: Icon(Icons.download),
      onSelected: (format) => controller.exportData(data, type, format),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: ExportFormat.PDF,
          child: Text('Export as PDF'),
        ),
        PopupMenuItem(
          value: ExportFormat.EXCEL,
          child: Text('Export as Excel'),
        ),
      ],
    );
  }
}
