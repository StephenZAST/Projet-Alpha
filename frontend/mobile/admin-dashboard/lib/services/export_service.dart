import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:filesaver/filesaver.dart';

class ExportService {
  static Future<Uint8List> generatePDF(List<dynamic> data, String type) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Admin Report'),
          ),
          pw.Table.fromTextArray(
            context: context,
            data: _convertDataToArray(data),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateExcel(
      List<dynamic> data, String type) async {
    final excel = Excel.createExcel();
    final sheet = excel['Report'];

    // Add headers
    sheet.appendRow(_getHeaders(type));

    // Add data rows
    for (var item in data) {
      sheet.appendRow(_convertToRow(item));
    }

    return excel.encode()!;
  }

  static List<List<String>> _convertDataToArray(List<dynamic> data) {
    // TODO: Implement data conversion logic
    return [];
  }

  static List<String> _getHeaders(String type) {
    // TODO: Implement header retrieval logic
    return [];
  }

  static List<String> _convertToRow(dynamic item) {
    // TODO: Implement row conversion logic
    return [];
  }
}
