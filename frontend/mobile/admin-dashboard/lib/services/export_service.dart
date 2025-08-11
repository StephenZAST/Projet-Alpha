import 'dart:typed_data';
import 'dart:convert';
import 'dart:html' as html;
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:csv/csv.dart';
import '../models/user.dart';

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

  static void exportUsersToCsv(List<User> users, {String? prefix}) {
    try {
      final List<List<dynamic>> rows = [];

      // En-têtes
      rows.add([
        'ID',
        'Nom complet',
        'Email',
        'Téléphone',
        'Rôle',
        'Statut',
        'Points de fidélité',
        'Balance d\'affiliation',
        'Date création',
        'Dernière mise à jour'
      ]);

      // Données
      for (var user in users) {
        rows.add([
          user.id,
          user.fullName,
          user.email,
          user.phone ?? '',
          user.role.label,
          user.isActive ? 'Actif' : 'Inactif',
          user.loyaltyPoints,
          user.affiliateBalance ?? 0,
          _formatDate(user.createdAt),
          _formatDate(user.updatedAt),
        ]);
      }

      final fileName =
          '${prefix ?? 'users'}_${DateTime.now().toIso8601String()}.csv';
      _downloadCsv(rows, fileName);
    } catch (e) {
      print('[ExportService] Error exporting users: $e');
      throw 'Erreur lors de l\'export des données';
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  static void _downloadCsv(List<List<dynamic>> rows, String fileName) {
    final csv = const ListToCsvConverter().convert(rows);
    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.Url.revokeObjectUrl(url);
  }
}
