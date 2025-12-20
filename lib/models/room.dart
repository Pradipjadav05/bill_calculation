class Room {
  final String name;
  final int persons;
  final double previousReading;
  final double currentReading;
  final DateTime readingDate;

  Room({
    required this.name,
    required this.persons,
    required this.previousReading,
    required this.currentReading,
    required this.readingDate,
  });

  double get units => currentReading - previousReading;
}
