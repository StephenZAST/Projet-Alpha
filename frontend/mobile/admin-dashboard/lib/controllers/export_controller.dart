import 'package:get/get.dart';
import 'package:filesaver/filesaver.dart';
import '../services/export_service.dart';

enum ExportFormat { PDF, EXCEL }

class ExportController extends GetxController {
  final isExporting = false.obs;

  Future<void> exportData(
      List<dynamic> data, String type, ExportFormat format) async {
    isExporting.value = true;
    try {
      final bytes = format == ExportFormat.PDF
          ? await ExportService.generatePDF(data, type)
          : await ExportService.generateExcel(data, type);

      await FileSaver.instance.saveFile(
        'report_${DateTime.now().toIso8601String()}',
        bytes,
        format == ExportFormat.PDF ? 'pdf' : 'xlsx',
      );

      Get.snackbar('Success', 'Export completed');
    } catch (e) {
      Get.snackbar('Error', 'Export failed: ${e.toString()}');
    } finally {
      isExporting.value = false;
    }
  }
}
