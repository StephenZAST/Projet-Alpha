import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';

class ExportService {
  static Future<Uint8List> generatePDF(
      List<Map<String, dynamic>> data, String type) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('$type Report'),
          ),
          pw.Table.fromTextArray(
            headers: data.first.keys.toList(),
            data: data
                .map((item) => item.values.map((e) => e.toString()).toList())
                .toList(),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateExcel(
      List<Map<String, dynamic>> data, String type) async {
    final excel = Excel.createExcel();
    final sheet = excel[type];

    // Headers
    final headers = data.first.keys.toList();
    sheet.appendRow(headers.map((header) => TextCellValue(header)).toList());

    // Data
    for (var i = 0; i < data.length; i++) {
      final row = data[i]
          .values
          .map((value) => TextCellValue(value.toString()))
          .toList();
      sheet.appendRow(row);
    }

    return Uint8List.fromList(excel.encode()!);
  }
}
