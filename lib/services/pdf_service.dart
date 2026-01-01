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

    final totalPersons =
    persons.values.fold<int>(0, (s, v) => s + v);
    final waterPerPerson =
    totalPersons == 0 ? 0.0 : waterUnits / totalPersons;
    final rate = totalAmount / totalUnits;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // ================= HEADER =================
            pw.Text(
              'ELECTRICITY BILL SPLIT',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Billing Period: ${formatBillMonth(billStartDate, billEndDate)}',
              style: pw.TextStyle(color: PdfColors.grey700),
            ),
            pw.Divider(),

            // ================= BILL SUMMARY =================
            _section('Bill Summary'),
            _summaryRow('Total Units', totalUnits),
            _summaryRow('Total Amount', totalAmount),
            _summaryRow('Per Unit Rate', rate),
            _summaryRow('Total Persons', totalPersons.toDouble()),
            _summaryRow('Water Units / Person', waterPerPerson),

            pw.SizedBox(height: 16),

            // ================= ROOM CARDS =================
            _roomCard(
              name: 'Room A',
              persons: persons['A']!,
              elec: roomAElec,
              waterPerPerson: waterPerPerson,
              total: units['A']!,
              amount: amounts['A']!,
            ),

            _roomCard(
              name: 'Room B',
              persons: persons['B']!,
              elec: roomBElec,
              waterPerPerson: waterPerPerson,
              total: units['B']!,
              amount: amounts['B']!,
            ),

            _roomCard(
              name: 'Room C (Derived)',
              persons: persons['C']!,
              elec: roomCElec,
              waterPerPerson: waterPerPerson,
              total: units['C']!,
              amount: amounts['C']!,
              derived: true,
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
    File('${dir.path}/Electricity_Bill_${billEndDate.year}.pdf');

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ================= UI HELPERS =================

  static pw.Widget _section(String title) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Text(
      title,
      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
    ),
  );

  static pw.Widget _summaryRow(
      String label,
      double value) {
    final text = value.toStringAsFixed(2);

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(
            text,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static pw.Widget _roomCard({
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
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: derived ? PdfColors.orange : PdfColors.grey400,
          width: derived ? 1.5 : 1,
        ),
        borderRadius: pw.BorderRadius.circular(6),
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
          _row('Amount', amount,),

          if (derived)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 6),
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

  static String _today() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.year}';
  }
}
