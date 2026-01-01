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
    // ---------- ROOM A ----------
    final aRaw = roomA.units;
    final aMeterDays =
        roomA.readingDate.difference(bill.previousDate).inDays;
    final aDaily = aRaw / aMeterDays;
    final aExtraDays =
        roomA.readingDate.difference(bill.currentDate).inDays;
    final aCorrected = aRaw - (aDaily * aExtraDays);

    // ---------- ROOM B ----------
    final bRaw = roomB.units;
    final bMeterDays =
        roomB.readingDate.difference(bill.previousDate).inDays;
    final bDaily = bRaw / bMeterDays;
    final bExtraDays =
        roomB.readingDate.difference(bill.currentDate).inDays;
    final bCorrected = bRaw - (bDaily * bExtraDays);

    // ---------- WATER ----------
    final wRaw = water.units;
    final wMeterDays =
        water.readingDate.difference(bill.previousDate).inDays;
    final wDaily = wRaw / wMeterDays;
    final wExtraDays =
        water.readingDate.difference(bill.currentDate).inDays;
    final wCorrected = wRaw - (wDaily * wExtraDays);

    // ---------- ROOM C ----------
    final cCorrected =
        bill.totalUnits - (aCorrected + bCorrected + wCorrected);

    final totalPersons =
        roomA.persons + roomB.persons + roomCPersons;
    final waterPerPerson =
        wCorrected / totalPersons;

    return {
      // FINAL totals
      'A': aCorrected + roomA.persons * waterPerPerson,
      'B': bCorrected + roomB.persons * waterPerPerson,
      'C': cCorrected + roomCPersons * waterPerPerson,

      // electricity breakup (IMPORTANT)
      'A_E': aCorrected,
      'B_E': bCorrected,
      'C_E': cCorrected,

      // water
      'W_PP': waterPerPerson,
    };
  }


  static Map<String, double> calculateAmount(
      Map<String, double> units,
      BillInfo bill,
      ) {
    return units.map(
          (k, v) => MapEntry(
        k,
        (v / bill.totalUnits) * bill.totalAmount,
      ),
    );
  }
}
