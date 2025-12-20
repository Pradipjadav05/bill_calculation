class WaterMeter {
  final double previousReading;
  final double currentReading;
  final DateTime readingDate;

  WaterMeter({
    required this.previousReading,
    required this.currentReading,
    required this.readingDate,
  });

  double get units => currentReading - previousReading;
}
