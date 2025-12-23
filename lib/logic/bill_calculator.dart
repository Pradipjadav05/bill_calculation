import '../models/bill_info.dart';
import '../models/room.dart';
import '../models/water_meter.dart';

class BillCalculator {
  static Map<String, double> calculateUnits({
    required BillInfo bill,
    required Room roomA,
    required Room roomB,
    required int roomCPersons,
    required WaterMeter water,
  }) {
    final billDays =
        bill.currentDate.difference(bill.previousDate).inDays;

    // -------- Room A --------
    final aMeterDays =
        roomA.readingDate.difference(bill.previousDate).inDays;
    final aDaily =
        roomA.units / aMeterDays;
    final aCorrected =
        roomA.units - (aDaily * (aMeterDays - billDays));

    // -------- Room B --------
    final bMeterDays =
        roomB.readingDate.difference(bill.previousDate).inDays;
    final bDaily =
        roomB.units / bMeterDays;
    final bCorrected =
        roomB.units - (bDaily * (bMeterDays - billDays));

    // -------- Water --------
    final wMeterDays =
        water.readingDate.difference(bill.previousDate).inDays;
    final wDaily =
        water.units / wMeterDays;
    final wCorrected =
        water.units - (wDaily * (wMeterDays - billDays));

    // -------- Room C (Derived) --------
    final cCorrected =
        bill.totalUnits - (aCorrected + bCorrected + wCorrected);

    // -------- Water distribution --------
    final totalPersons =
        roomA.persons + roomB.persons + roomCPersons;
    final waterPerPerson =
    totalPersons == 0 ? 0.0 : wCorrected / totalPersons;

    return {
      'A': aCorrected + roomA.persons * waterPerPerson,
      'B': bCorrected + roomB.persons * waterPerPerson,
      'C': cCorrected + roomCPersons * waterPerPerson,
    };
  }

  static Map<String, double> calculateAmount(
      Map<String, double> units,
      BillInfo bill,
      ) {
    final rate = bill.totalAmount / bill.totalUnits;
    return units.map((k, v) => MapEntry(k, v * rate));
  }
}
