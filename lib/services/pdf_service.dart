import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../utils/date_utils.dart';

class PdfService {
  static Future<File> generateBillPdf({
    required DateTime billStartDate,
    required DateTime billEndDate,
    required double totalUnits,
    required double totalAmount,
    required Map<String, double> units,
    required Map<String, double> amounts,
    required Map<String, int> persons,
    required double waterUnits,
    required double roomAElec,
    required double roomBElec,
    required double roomCElec,
  }) async {
    final pdf = pw.Document();

    final period = _formatPeriod(
      formatBillMonth(billStartDate, billEndDate),
    );

    final rate = totalAmount / totalUnits;
    final totalPersons =
    persons.values.fold<int>(0, (s, v) => s + v);

    final double waterPerPerson =
    totalPersons == 0 ? 0.0 : waterUnits / totalPersons;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (_) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              pw.Text(
                'ELECTRICITY BILL SPLIT',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                'Billing Period: $period',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Container(height: 1, color: PdfColors.grey400),

              pw.SizedBox(height: 14),

              // ================= BILL SUMMARY =================
              _section('Bill Summary'),
              _row('Total Units', totalUnits),
              _row('Total Amount', totalAmount),
              _row('Per Unit Rate', rate),
              _row('Total Persons', totalPersons.toDouble()),
              _row(
                'Water Units / Person',
                waterPerPerson,
              ),

              pw.SizedBox(height: 16),

              // ================= ROOM A =================
              _roomSection(
                name: 'Room A',
                persons: persons['A'] ?? 0,
                elec: roomAElec,
                waterPerPerson: waterPerPerson,
                total: units['A']!,
                amount: amounts['A']!,
              ),

              // ================= ROOM B =================
              _roomSection(
                name: 'Room B',
                persons: persons['B'] ?? 0,
                elec: roomBElec,
                waterPerPerson: waterPerPerson,
                total: units['B']!,
                amount: amounts['B']!,
              ),

              // ================= ROOM C =================
              _roomSection(
                name: 'Room C (Derived)',
                persons: persons['C'] ?? 0,
                elec: roomCElec,
                waterPerPerson: waterPerPerson,
                total: units['C']!,
                amount: amounts['C']!,
                derived: true,
              ),

              pw.SizedBox(height: 12),

              // ================= TOTAL CHECK =================
              _section('Final Verification'),
              _row(
                'Units Check',
                units.values.fold(0.0, (s, v) => s + v),
              ),
              _row(
                'Amount Check',
                amounts.values.fold(0.0, (s, v) => s + v),
              ),

              pw.Spacer(),

              // ================= FOOTER =================
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
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final safePeriod = period.replaceAll(' ', '_');
    final file =
    File('${dir.path}/Electricity_Bill_$safePeriod.pdf');

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ================= HELPERS =================

  static pw.Widget _section(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _row(String label, double value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(value.toStringAsFixed(2)),
        ],
      ),
    );
  }

  static pw.Widget _roomSection({
    required String name,
    required int persons,
    required double elec,
    required double waterPerPerson,
    required double total,
    required double amount,
    bool derived = false,
  }) {
    final water = persons * waterPerPerson;

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
            '$name  (Persons: $persons)',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),

          _row('Electricity Units', elec),
          _row(
            'Water Units',
            water,
          ),
          pw.Text(
            '(${waterPerPerson.toStringAsFixed(2)} × $persons)',
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey700,
            ),
          ),

          pw.Divider(),

          _row('Total Units', total),
          _row('Amount', amount),

          if (derived)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4),
              child: pw.Text(
                'Electricity derived from common meter:\n'
                    'Total - (Room A + Room B + Water)',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey700,
                ),
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
