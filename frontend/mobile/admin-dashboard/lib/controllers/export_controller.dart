import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import 'package:get/get.dart';
import '../services/export_service.dart';

enum ExportFormat { PDF, EXCEL }

class ExportController extends GetxController {
  final isExporting = false.obs;

  Future<void> exportData(
      List<Map<String, dynamic>> data, String type, ExportFormat format) async {
    isExporting.value = true;
    try {
      final bytes = format == ExportFormat.PDF
          ? await ExportService.generatePDF(data, type)
          : await ExportService.generateExcel(data, type);

      await FileSaver.instance.saveFile(
        name: 'report_${DateTime.now().toIso8601String()}',
        bytes: Uint8List.fromList(bytes),
        ext: format == ExportFormat.PDF ? 'pdf' : 'xlsx',
      );

      Get.snackbar('Success', 'Export completed');
    } catch (e) {
      Get.snackbar('Error', 'Export failed: ${e.toString()}');
    } finally {
      isExporting.value = false;
    }
  }
}
