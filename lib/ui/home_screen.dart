import 'package:flutter/material.dart';

import '../logic/bill_calculator.dart';
import '../models/bill_info.dart';
import '../models/room.dart';
import '../models/water_meter.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();

  // ---------------- Bill ----------------
  final billUnitsCtrl = TextEditingController();
  final billAmountCtrl = TextEditingController();
  DateTime? prevBillDate;
  DateTime? currBillDate;

  // ---------------- Room A ----------------
  final aPrev = TextEditingController();
  final aCurr = TextEditingController();
  int personsA = 1;
  DateTime? aDate;

  // ---------------- Room B ----------------
  final bPrev = TextEditingController();
  final bCurr = TextEditingController();
  int personsB = 1;
  DateTime? bDate;

  // ---------------- Room C ----------------
  int personsC = 1;

  // ---------------- Water ----------------
  final wPrev = TextEditingController();
  final wCurr = TextEditingController();
  DateTime? wDate;

  // ---------------- Helpers ----------------
  Future<void> pickDate(
    DateTime? current,
    ValueChanged<DateTime> onPicked,
  ) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: current ?? DateTime.now(),
    );
    if (picked != null) onPicked(picked);
  }

  // ---------------- Validation ----------------
  bool get isValid =>
      _formKey.currentState?.validate() == true &&
      prevBillDate != null &&
      currBillDate != null &&
      aDate != null &&
      bDate != null &&
      wDate != null;

  // ---------------- Calculate ----------------
  void calculate() {
    if (!isValid) return;

    final bill = BillInfo(
      previousDate: prevBillDate!,
      currentDate: currBillDate!,
      totalUnits: double.parse(billUnitsCtrl.text),
      totalAmount: double.parse(billAmountCtrl.text),
    );

    final roomA = Room(
      name: 'A',
      persons: personsA,
      previousReading: double.parse(aPrev.text),
      currentReading: double.parse(aCurr.text),
      readingDate: aDate!,
    );

    final roomB = Room(
      name: 'B',
      persons: personsB,
      previousReading: double.parse(bPrev.text),
      currentReading: double.parse(bCurr.text),
      readingDate: bDate!,
    );

    final water = WaterMeter(
      previousReading: double.parse(wPrev.text),
      currentReading: double.parse(wCurr.text),
      readingDate: wDate!,
    );

    final units = BillCalculator.calculateUnits(
      bill: bill,
      roomA: roomA,
      roomB: roomB,
      roomCPersons: personsC,
      water: water,
    );

    final amounts = BillCalculator.calculateAmount(units, bill);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          units: units,
          amounts: amounts,
          totalUnits: bill.totalUnits,
          totalAmount: bill.totalAmount,
          roomAElec: roomA.units,
          roomBElec: roomB.units,
          roomCElec:
              bill.totalUnits - (roomA.units + roomB.units + water.units),
          waterUnits: water.units,
          persons: {'A': personsA, 'B': personsB, 'C': personsC},
          billPreviousDate: prevBillDate!,
          billCurrentDate: currBillDate!,
        ),
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Electricity Bill Split'),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.bolt),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _section('Bill Details', Icons.receipt_long),
              _num(billUnitsCtrl, 'Total Units'),
              _num(billAmountCtrl, 'Total Amount'),
              _dateRow(
                'Previous Bill Date',
                prevBillDate,
                (d) => setState(() => prevBillDate = d),
              ),
              _dateRow(
                'Current Bill Date',
                currBillDate,
                (d) => setState(() => currBillDate = d),
              ),
      
              _section('Room A (Has Meter)', Icons.home),
              _personsPicker(personsA, (v) => setState(() => personsA = v)),
              _num(aPrev, 'Previous Reading'),
              _num(aCurr, 'Current Reading', validateGreaterThan: aPrev),
              _dateRow('Reading Date', aDate, (d) => setState(() => aDate = d)),
      
              _section('Room B (Has Meter)', Icons.home_work),
              _personsPicker(personsB, (v) => setState(() => personsB = v)),
              _num(bPrev, 'Previous Reading'),
              _num(bCurr, 'Current Reading', validateGreaterThan: bPrev),
              _dateRow('Reading Date', bDate, (d) => setState(() => bDate = d)),
      
              _section('Room C (No Meter)', Icons.groups),
              _personsPicker(personsC, (v) => setState(() => personsC = v)),
      
              _section('Water Meter', Icons.water_drop),
              _num(wPrev, 'Previous Reading'),
              _num(wCurr, 'Current Reading', validateGreaterThan: wPrev),
              _dateRow('Reading Date', wDate, (d) => setState(() => wDate = d)),
      
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: isValid ? calculate : null,
                icon: const Icon(Icons.calculate),
                label: const Text('Calculate Bill'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- UI Helpers ----------------
  Widget _section(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }


  Widget _num(
    TextEditingController c,
    String label, {
    TextEditingController? validateGreaterThan,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: c,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Required';
          final n = double.tryParse(v);
          if (n == null || n < 0) return 'Invalid number';
          if (validateGreaterThan != null) {
            final prev = double.tryParse(validateGreaterThan.text) ?? 0;
            if (n <= prev) return 'Must be greater than previous';
          }
          return null;
        },
      ),
    );
  }

  Widget _dateRow(String label, DateTime? date, ValueChanged<DateTime> onPick) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: () => pickDate(date, onPick),
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date == null
                ? label
                : '$label: ${date.toIso8601String().substring(0, 10)}',
          ),
          const Icon(Icons.calendar_month),
        ],
      ),
    ),
    );
  }

  Widget _personsPicker(int value, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Text(
            'Persons',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          IconButton(
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => onChanged(value + 1),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }

}
