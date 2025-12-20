import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../services/pdf_service.dart';
import '../utils/date_utils.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, double> units;
  final Map<String, double> amounts;

  final double totalUnits;
  final double totalAmount;

  final double roomAElec;
  final double roomBElec;
  final double roomCElec;

  final double waterUnits;
  final Map<String, int> persons;

  final DateTime billPreviousDate;
  final DateTime billCurrentDate;

  const ResultScreen({
    super.key,
    required this.units,
    required this.amounts,
    required this.totalUnits,
    required this.totalAmount,
    required this.roomAElec,
    required this.roomBElec,
    required this.roomCElec,
    required this.waterUnits,
    required this.persons,
    required this.billPreviousDate,
    required this.billCurrentDate,
  });

  @override
  Widget build(BuildContext context) {
    final rate = totalAmount / totalUnits;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bill Result'),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.receipt_long),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section(context, 'Bill Summary', Icons.summarize),
            _summaryCard(rate),
      
            _section(context, 'Room-wise Calculation', Icons.home_work),
      
            _roomCard(
              name: 'Room A',
              persons: persons['A'] ?? 0,
              elec: roomAElec,
              total: units['A'] ?? 0,
              amount: amounts['A'] ?? 0,
            ),
      
            _roomCard(
              name: 'Room B',
              persons: persons['B'] ?? 0,
              elec: roomBElec,
              total: units['B'] ?? 0,
              amount: amounts['B'] ?? 0,
            ),
      
            _roomCard(
              name: 'Room C (Derived)',
              persons: persons['C'] ?? 0,
              elec: roomCElec,
              total: units['C'] ?? 0,
              amount: amounts['C'] ?? 0,
              derived: true,
            ),
      
            _section(context, 'Verification', Icons.verified),
      
            _row(
              'Units Check',
              units.values.fold(0.0, (s, v) => s + v).toStringAsFixed(2),
              ok: true,
            ),
            _row(
              'Amount Check',
              '₹${amounts.values.fold(0.0, (s, v) => s + v).toStringAsFixed(2)}',
              ok: true,
            ),
      
            const SizedBox(height: 24),
      
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA000),
                foregroundColor: Colors.black,
              ),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Export PDF & Share'),
              onPressed: () async {
                final pdfFile = await PdfService.generateBillPdf(
                  billStartDate: billPreviousDate,
                  billEndDate: billCurrentDate,
                  totalUnits: totalUnits,
                  totalAmount: totalAmount,
                  units: units,
                  amounts: amounts,
                  persons: persons,
                  waterUnits: waterUnits,
                  roomAElec: roomAElec,
                  roomBElec: roomBElec,
                  roomCElec: roomCElec,
                );
      
                await SharePlus.instance.share(
                  ShareParams(
                    files: [XFile(pdfFile.path)],
                    text:
                        'Electricity Bill (${formatBillMonth(billPreviousDate, billCurrentDate)})',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= SUMMARY CARD =================

  Widget _summaryCard(double rate) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _row('Total Units', totalUnits.toStringAsFixed(2)),
            _row('Total Amount', '₹${totalAmount.toStringAsFixed(2)}'),
            _row('Per Unit Rate', '₹${rate.toStringAsFixed(3)}'),
            _row('Total Persons', _totalPersons().toString()),
            _row('Water Units / Person', _waterPerPerson().toStringAsFixed(2)),
          ],
        ),
      ),
    );
  }

  // ================= CALCULATIONS =================

  int _totalPersons() => persons.values.fold<int>(0, (s, v) => s + v);

  double _waterPerPerson() {
    final total = _totalPersons();
    return total == 0 ? 0 : waterUnits / total;
  }

  double _round2(double v) => double.parse(v.toStringAsFixed(2));

  // ================= UI HELPERS =================

  Widget _section(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool ok = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: ok ? Colors.green : Colors.black,
          ),
        ),
      ],
    ),
  );

  Widget _roomCard({
    required String name,
    required int persons,
    required double elec,
    required double total,
    required double amount,
    bool derived = false,
  }) {
    final water = persons * _waterPerPerson();

    return Card(
      shape: derived
          ? RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xFFFFA000), width: 1.2),
              borderRadius: BorderRadius.circular(14),
            )
          : null,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$name  (Persons: $persons)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            _row('Electricity Units', _round2(elec).toStringAsFixed(2)),

            _row(
              'Water Units',
              '${_round2(water).toStringAsFixed(2)} '
                  '(${_waterPerPerson().toStringAsFixed(2)} × $persons)',
            ),

            const Divider(),

            _row('Total Units', _round2(total).toStringAsFixed(2)),
            _row('Amount', '₹${_round2(amount).toStringAsFixed(2)}'),

            if (derived) ...[
              const Divider(),
              Text(
                'Electricity derived from common meter:\n'
                'Total − (Room A + Room B + Water)',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
