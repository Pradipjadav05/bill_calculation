class BillInfo {
  final DateTime previousDate;
  final DateTime currentDate;
  final double totalUnits;
  final double totalAmount;

  BillInfo({
    required this.previousDate,
    required this.currentDate,
    required this.totalUnits,
    required this.totalAmount,
  });
}
