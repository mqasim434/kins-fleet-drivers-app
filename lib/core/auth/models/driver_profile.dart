class DriverProfile {
  const DriverProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.departmentId,
    required this.departmentName,
    required this.status,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String phone;
  final String email;
  final String departmentId;
  final String departmentName;
  final String status;

  factory DriverProfile.fromFirestore(String id, Map<String, dynamic> data) {
    final firstName = data['firstName'] as String? ?? '';
    final lastName = data['lastName'] as String? ?? '';
    return DriverProfile(
      id: id,
      firstName: firstName,
      lastName: lastName,
      fullName: data['fullName'] as String? ?? '$firstName $lastName'.trim(),
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String? ?? '',
      departmentId: data['departmentId'] as String? ?? '',
      departmentName: data['departmentName'] as String? ?? '',
      status: data['status'] as String? ?? 'active',
    );
  }

  String get displayName => fullName.isNotEmpty ? fullName : email;
}
