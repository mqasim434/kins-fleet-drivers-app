class UserAccount {
  const UserAccount({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.driverId,
    required this.fleetManager,
  });

  final String uid;
  final String name;
  final String email;
  final String role;
  final String status;
  final String driverId;

  final bool fleetManager;

  bool get isDriver => role == 'driver';
  bool get isActive => status == 'active';
  bool get isFleetManager => isDriver && fleetManager;

  /// Same people who onboard on the website: admin, dispatcher, and employee.
  bool get canOnboard =>
      isActive && (role == 'admin' || role == 'dispatcher' || role == 'employee');

  factory UserAccount.fromFirestore(String uid, Map<String, dynamic> data) {
    return UserAccount(
      uid: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? '',
      status: data['status'] as String? ?? '',
      driverId: data['driverId'] as String? ?? '',
      fleetManager: data['fleetManager'] == true,
    );
  }
}

class DriverRecord {
  const DriverRecord({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.employeeId,
    required this.transporterId,
    required this.departmentId,
    required this.departmentName,
    required this.status,
    required this.allowAppClock,
  });

  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String employeeId;
  final String transporterId;
  final String departmentId;
  final String departmentName;
  final String status;
  final bool allowAppClock;

  String get displayName => fullName.isNotEmpty ? fullName : email;

  factory DriverRecord.fromFirestore(String id, Map<String, dynamic> data) {
    final first = data['firstName'] as String? ?? '';
    final last = data['lastName'] as String? ?? '';
    final names = data['departmentNames'];
    final ids = data['departmentIds'];
    final department = names is List && names.isNotEmpty
        ? names.map((value) => '$value').join(', ')
        : data['departmentName'] as String? ?? '';
    final departmentId = ids is List && ids.isNotEmpty
        ? '${ids.first}'
        : data['departmentId'] as String? ?? '';

    return DriverRecord(
      id: id,
      fullName: data['fullName'] as String? ?? '$first $last'.trim(),
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String? ?? '',
      employeeId: data['employeeId'] as String? ?? '',
      transporterId: data['transporterId'] as String? ?? '',
      departmentId: departmentId,
      departmentName: department,
      status: data['status'] as String? ?? 'active',
      allowAppClock: data['allowAppClock'] == true,
    );
  }
}

class AuthSession {
  const AuthSession({required this.user, this.driver});

  final UserAccount user;
  final DriverRecord? driver;

  DriverRecord get driverRecord {
    final record = driver;
    if (record == null) {
      throw StateError('Deze sessie hoort bij een dispatcher, niet bij een chauffeur.');
    }
    return record;
  }
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
