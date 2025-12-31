import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../utils/date_utils.dart';

class PdfService {
  static Future<File> generateBillPdf({
    required DateTime billStartDate,
    required DateTime billEndDate,

    // summary (already calculated)
    required double totalUnits,
    required double totalAmount,
    required double perUnitRate,
    required int totalPersons,
    required double waterUnitsPerPerson,

    // final results
    required Map<String, double> units,
    required Map<String, double> amounts,
    required Map<String, int> persons,

    // electricity breakup
    required double roomAElec,
    required double roomBElec,
    required double roomCElec,
  }) async {
    final pdf = pw.Document();

    final period = _formatPeriod(
      formatBillMonth(billStartDate, billEndDate),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'ELECTRICITY BILL SPLIT',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text('Billing Period: $period'),
            pw.Divider(),

            // ================= BILL SUMMARY =================
            _section('Bill Summary'),
            _row('Total Units', totalUnits),
            _row('Total Amount', totalAmount),
            _row('Per Unit Rate', perUnitRate),
            _row('Total Persons', totalPersons.toDouble()),
            _row('Water Units / Person', waterUnitsPerPerson),

            pw.SizedBox(height: 14),

            _section('Room-wise Calculation'),
            _roomBlock(
              name: 'Room A',
              persons: persons['A'] ?? 0,
              elec: roomAElec,
              total: units['A']!,
              amount: amounts['A']!,
            ),
            _roomBlock(
              name: 'Room B',
              persons: persons['B'] ?? 0,
              elec: roomBElec,
              total: units['B']!,
              amount: amounts['B']!,
            ),
            _roomBlock(
              name: 'Room C (Derived)',
              persons: persons['C'] ?? 0,
              elec: roomCElec,
              total: units['C']!,
              amount: amounts['C']!,
              derived: true,
            ),

            pw.SizedBox(height: 12),

            _section('Verification'),
            _row(
              'Units Check',
              units.values.fold(0.0, (s, v) => s + v),
            ),
            _row(
              'Amount Check',
              amounts.values.fold(0.0, (s, v) => s + v),
            ),

            pw.Spacer(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Generated on ${_today()}',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file =
    File('${dir.path}/Electricity_Bill_$period.pdf');

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ---------------- helpers ----------------

  static pw.Widget _section(String title) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Text(title,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  );

  static pw.Widget _row(
      String label,
      double value) {
    final text = value.toStringAsFixed(2);

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(text),
        ],
      ),
    );
  }

  static pw.Widget _roomBlock({
    required String name,
    required int persons,
    required double elec,
    required double total,
    required double amount,
    bool derived = false,
  }) {
    final water = total - elec;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '$name (Persons: $persons)',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),

          _row('Electricity Units', elec),
          _row('Water Units', water),
          pw.Divider(),

          _row('Total Units', total),
          _row('Amount', amount),

          if (derived)
            pw.Text(
              'Electricity derived from common meter:\n'
                  'Total - (Room A + Room B + Water)',
              style: pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey700,
              ),
            ),
        ],
      ),
    );
  }

  static String _formatPeriod(String period) {
    return period
        .replaceAll('–', ' to ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String _today() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.year}';
  }
}
