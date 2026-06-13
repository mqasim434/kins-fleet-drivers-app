class ShiftAssignment {
  const ShiftAssignment({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.departmentId,
    required this.departmentName,
    required this.shiftTypeId,
    required this.shiftName,
    required this.shiftColor,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.busId,
    required this.busNumber,
    required this.licensePlate,
    required this.status,
    required this.notes,
  });

  final String id;
  final String driverId;
  final String driverName;
  final String departmentId;
  final String departmentName;
  final String shiftTypeId;
  final String shiftName;
  final String shiftColor;
  final String date;
  final String startTime;
  final String endTime;
  final String busId;
  final String busNumber;
  final String licensePlate;
  final String status;
  final String notes;

  factory ShiftAssignment.fromFirestore(String id, Map<String, dynamic> data) {
    return ShiftAssignment(
      id: id,
      driverId: data['driverId'] as String? ?? '',
      driverName: data['driverName'] as String? ?? '',
      departmentId: data['departmentId'] as String? ?? '',
      departmentName: data['departmentName'] as String? ?? '',
      shiftTypeId: data['shiftTypeId'] as String? ?? '',
      shiftName: data['shiftName'] as String? ?? '',
      shiftColor: data['shiftColor'] as String? ?? '#2563EB',
      date: data['date'] as String? ?? '',
      startTime: data['startTime'] as String? ?? '',
      endTime: data['endTime'] as String? ?? '',
      busId: data['busId'] as String? ?? '',
      busNumber: data['busNumber'] as String? ?? '',
      licensePlate: data['licensePlate'] as String? ?? '',
      status: data['status'] as String? ?? 'scheduled',
      notes: data['notes'] as String? ?? '',
    );
  }
}
