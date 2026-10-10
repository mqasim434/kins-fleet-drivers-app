import 'package:kins_fleet_drivers/data/photo_quality.dart';

class ShiftAssignment {
  const ShiftAssignment({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.shiftName,
    required this.status,
    required this.departmentName,
    required this.busId,
    required this.busNumber,
    required this.licensePlate,
    required this.routeCode,
    required this.locationCode,
    required this.notes,
  });

  final String id;
  final String date;
  final String startTime;
  final String endTime;
  final String shiftName;
  final String status;
  final String departmentName;
  final String busId;
  final String busNumber;
  final String licensePlate;
  final String routeCode;
  final String locationCode;
  final String notes;

  bool get isCancelled => status == 'cancelled';

  String get timeLabel {
    if (startTime.isEmpty && endTime.isEmpty) return '';
    if (endTime.isEmpty) return startTime;
    return '$startTime – $endTime';
  }

  String get vehicleLabel {
    final parts = [busNumber, licensePlate].where((part) => part.isNotEmpty);
    return parts.join(' · ');
  }

  factory ShiftAssignment.fromFirestore(String id, Map<String, dynamic> data) {
    return ShiftAssignment(
      id: id,
      date: data['date'] as String? ?? '',
      startTime: data['startTime'] as String? ?? '',
      endTime: data['endTime'] as String? ?? '',
      shiftName: data['shiftName'] as String? ?? '',
      status: data['status'] as String? ?? 'scheduled',
      departmentName: data['departmentName'] as String? ?? '',
      busId: data['busId'] as String? ?? '',
      busNumber: data['busNumber'] as String? ?? '',
      licensePlate: data['licensePlate'] as String? ?? '',
      routeCode: data['routeCode'] as String? ?? '',
      locationCode: data['locationCode'] as String? ?? '',
      notes: data['notes'] as String? ?? '',
    );
  }
}

class FleetBus {
  const FleetBus({
    required this.id,
    required this.busNumber,
    required this.licensePlate,
    required this.brand,
    required this.model,
    required this.status,
    this.departmentIds = const [],
    this.departmentNames = const [],
  });

  final String id;
  final String busNumber;
  final String licensePlate;
  final String brand;
  final String model;
  final String status;
  final List<String> departmentIds;
  final List<String> departmentNames;

  String get title {
    if (busNumber.isNotEmpty) return 'Bus $busNumber';
    if (licensePlate.isNotEmpty) return licensePlate;
    return 'Voertuig';
  }

  String get label {
    final parts = [busNumber, licensePlate].where((part) => part.isNotEmpty);
    if (parts.isEmpty) return title;
    return parts.join(' · ');
  }

  bool matchesDepartment(String departmentId) {
    if (departmentId.isEmpty || departmentId == 'all') return true;
    return departmentIds.contains(departmentId);
  }

  factory FleetBus.fromFirestore(String id, Map<String, dynamic> data) {
    final ids = data['departmentIds'];
    final names = data['departmentNames'];
    final departmentIds = ids is List
        ? ids.map((value) => '$value').where((value) => value.isNotEmpty).toList()
        : <String>[];
    final singleId = data['departmentId'] as String? ?? '';
    if (departmentIds.isEmpty && singleId.isNotEmpty) departmentIds.add(singleId);
    final departmentNames = names is List
        ? names.map((value) => '$value').where((value) => value.isNotEmpty).toList()
        : <String>[];
    final singleName = data['departmentName'] as String? ?? '';
    if (departmentNames.isEmpty && singleName.isNotEmpty) departmentNames.add(singleName);

    return FleetBus(
      id: id,
      busNumber: data['busNumber'] as String? ?? data['name'] as String? ?? '',
      licensePlate: data['licensePlate'] as String? ?? '',
      brand: data['brand'] as String? ?? '',
      model: data['model'] as String? ?? '',
      status: data['status'] as String? ?? '',
      departmentIds: departmentIds,
      departmentNames: departmentNames,
    );
  }

  factory FleetBus.fromShift(ShiftAssignment shift) {
    return FleetBus(
      id: shift.busId,
      busNumber: shift.busNumber,
      licensePlate: shift.licensePlate,
      brand: '',
      model: '',
      status: '',
    );
  }
}

class BusPhotoRecord {
  const BusPhotoRecord({
    required this.id,
    required this.busId,
    required this.busNumber,
    required this.licensePlate,
    required this.date,
    required this.purpose,
    required this.notes,
    required this.imageUrl,
    required this.thumbnailUrl,
    this.uploadedByName = '',
    this.width = 0,
    this.height = 0,
    this.fileSize = 0,
    this.qualityOk = false,
  });

  final String id;
  final String busId;
  final String busNumber;
  final String licensePlate;
  final String date;
  final String purpose;
  final String notes;
  final String imageUrl;
  final String thumbnailUrl;
  final String uploadedByName;
  final int width;
  final int height;
  final int fileSize;
  final bool qualityOk;

  bool get countsAsGood => photoCountsAsGood(
        qualityOk: qualityOk,
        width: width,
        height: height,
        fileSize: fileSize,
      );

  factory BusPhotoRecord.fromFirestore(String id, Map<String, dynamic> data) {
    return BusPhotoRecord(
      id: id,
      busId: data['busId'] as String? ?? '',
      busNumber: data['busNumber'] as String? ?? '',
      licensePlate: data['licensePlate'] as String? ?? '',
      date: data['date'] as String? ?? '',
      purpose: data['purpose'] as String? ?? '',
      notes: data['notes'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      thumbnailUrl: data['thumbnailUrl'] as String? ?? data['imageUrl'] as String? ?? '',
      uploadedByName: data['uploadedByName'] as String? ?? '',
      width: (data['width'] as num?)?.toInt() ?? 0,
      height: (data['height'] as num?)?.toInt() ?? 0,
      fileSize: (data['fileSize'] as num?)?.toInt() ?? 0,
      qualityOk: data['qualityOk'] == true,
    );
  }
}

class ConcessionRecord {
  const ConcessionRecord({
    required this.id,
    required this.trackingId,
    required this.driverName,
    required this.transporterId,
    required this.deliveryDate,
    required this.comment,
    required this.weekYear,
    required this.weekNumber,
  });

  final String id;
  final String trackingId;
  final String driverName;
  final String transporterId;
  final String deliveryDate;
  final String comment;
  final int? weekYear;
  final int? weekNumber;

  factory ConcessionRecord.fromFirestore(String id, Map<String, dynamic> data) {
    return ConcessionRecord(
      id: id,
      trackingId: data['trackingId'] as String? ?? id,
      driverName: data['driverName'] as String? ?? '',
      transporterId: data['transporterId'] as String? ?? '',
      deliveryDate: data['deliveryDate'] as String? ?? '',
      comment: data['comment'] as String? ?? '',
      weekYear: (data['weekYear'] as num?)?.toInt(),
      weekNumber: (data['weekNumber'] as num?)?.toInt(),
    );
  }
}

class FleetDepartment {
  const FleetDepartment({required this.id, required this.name, required this.status});

  final String id;
  final String name;
  final String status;

  factory FleetDepartment.fromFirestore(String id, Map<String, dynamic> data) {
    return FleetDepartment(
      id: id,
      name: data['name'] as String? ?? data['code'] as String? ?? 'Afdeling',
      status: data['status'] as String? ?? 'active',
    );
  }
}

class DamageReport {
  const DamageReport({
    required this.id,
    required this.busNumber,
    required this.licensePlate,
    required this.date,
    required this.description,
    required this.damageType,
    required this.severity,
    required this.status,
    required this.imageUrl,
  });

  final String id;
  final String busNumber;
  final String licensePlate;
  final String date;
  final String description;
  final String damageType;
  final String severity;
  final String status;
  final String imageUrl;

  factory DamageReport.fromFirestore(String id, Map<String, dynamic> data) {
    return DamageReport(
      id: id,
      busNumber: data['busNumber'] as String? ?? '',
      licensePlate: data['licensePlate'] as String? ?? '',
      date: data['date'] as String? ?? '',
      description: data['description'] as String? ?? '',
      damageType: data['damageType'] as String? ?? 'other',
      severity: data['severity'] as String? ?? 'low',
      status: data['status'] as String? ?? 'reported',
      imageUrl: data['imageUrl'] as String? ?? '',
    );
  }
}
