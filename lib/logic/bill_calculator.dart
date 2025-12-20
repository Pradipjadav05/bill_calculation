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

    final dailyUnits = bill.totalUnits / billDays;

    final totalPersons =
        roomA.persons + roomB.persons + roomCPersons;

    // -------- Extra days --------
    final aExtraDays =
    roomA.readingDate.difference(bill.currentDate).inDays.clamp(0, 365);
    final bExtraDays =
    roomB.readingDate.difference(bill.currentDate).inDays.clamp(0, 365);

    // -------- Extra units --------
    final aExtraUnits =
        dailyUnits * aExtraDays * (roomA.persons / totalPersons);
    final bExtraUnits =
        dailyUnits * bExtraDays * (roomB.persons / totalPersons);

    // -------- Electricity --------
    final aElec = roomA.units - aExtraUnits;
    final bElec = roomB.units - bExtraUnits;

    final waterUnits = water.units;

    final cElec =
        bill.totalUnits - (aElec + bElec + waterUnits);

    // -------- Water split --------
    final waterPerPerson = waterUnits / totalPersons;

    return {
      'A': aElec + roomA.persons * waterPerPerson,
      'B': bElec + roomB.persons * waterPerPerson,
      'C': cElec + roomCPersons * waterPerPerson,
    };
  }

  static Map<String, double> calculateAmount(
      Map<String, double> units, BillInfo bill) {
    final rate = bill.totalAmount / bill.totalUnits;
    return units.map((k, v) => MapEntry(k, v * rate));
  }
}
