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

    return Scaffold(
      appBar: AppBar(title: const Text('Bill Result')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('Bill Summary'),
          _row('Total Units', totalUnits),
          _row('Total Amount', totalAmount, currency: true),
          _row('Per Unit Rate', rate, currency: true),
          _row('Total Persons', _totalPersons().toDouble()),
          _row('Water Units / Person', _waterPerPerson()),

          _section('Room-wise Calculation'),

          _roomCard(
            name: 'Room A',
            persons: persons['A']!,
            elec: roomAElec,
            total: units['A']!,
            amount: amounts['A']!,
          ),

          _roomCard(
            name: 'Room B',
            persons: persons['B']!,
            elec: roomBElec,
            total: units['B']!,
            amount: amounts['B']!,
          ),

          _roomCard(
            name: 'Room C (Derived)',
            persons: persons['C']!,
            elec: roomCElec,
            total: units['C']!,
            amount: amounts['C']!,
            derived: true,
          ),

          _section('Verification'),
          _row(
            'Units Check',
            units.values.fold(0.0, (s, v) => s + v),
            ok: true,
          ),
          _row(
            'Amount Check',
            amounts.values.fold(0.0, (s, v) => s + v),
            currency: true,
            ok: true,
          ),

          const SizedBox(height: 24),

          ElevatedButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Export PDF & Share'),
            onPressed: () async {
              final file = await PdfService.generateBillPdf(
                billStartDate: billPreviousDate,
                billEndDate: billCurrentDate,
                totalUnits: totalUnits,
                totalAmount: totalAmount,
                units: units,
                amounts: amounts,
                persons: persons,
              );


              await Share.shareXFiles(
                [XFile(file.path)],
                text:
                'Electricity Bill (${formatBillMonth(billPreviousDate, billCurrentDate)})',
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------- helpers ----------

  int _totalPersons() =>
      persons.values.fold<int>(0, (s, v) => s + v);

  double _waterPerPerson() =>
      _totalPersons() == 0 ? 0 : waterUnits / _totalPersons();

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Text(title,
        style:
        const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  );

  Widget _row(
      String label,
      double value, {
        bool currency = false,
        bool ok = false,
      }) {
    final text = currency
        ? '₹${value.toStringAsFixed(2)}'
        : value.toStringAsFixed(2);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ok ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _roomCard({
    required String name,
    required int persons,
    required double elec,
    required double total,
    required double amount,
    bool derived = false,
  }) {
    final water = total - elec;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: derived
          ? RoundedRectangleBorder(
        side: const BorderSide(color: Colors.orange),
        borderRadius: BorderRadius.circular(12),
      )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$name (Persons: $persons)',
                style:
                const TextStyle(fontWeight: FontWeight.bold)),

            _row('Electricity Units', elec),
            _row('Water Units', water),
            const Divider(),
            _row('Total Units', total),
            _row('Amount', amount, currency: true),

            if (derived)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Electricity derived from common meter:\n'
                      'Total − (Room A + Room B + Water)',
                  style:
                  TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
