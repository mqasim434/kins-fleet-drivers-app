class BusOption {
  const BusOption({
    required this.id,
    required this.busNumber,
    required this.licensePlate,
    this.fromTodayShift = false,
  });

  final String id;
  final String busNumber;
  final String licensePlate;
  final bool fromTodayShift;

  String get label => '$busNumber · $licensePlate';

  @override
  bool operator ==(Object other) =>
      other is BusOption && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
