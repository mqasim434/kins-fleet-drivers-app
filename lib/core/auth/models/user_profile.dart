class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.driverId,
  });

  final String uid;
  final String name;
  final String email;
  final String role;
  final String status;
  final String driverId;

  factory UserProfile.fromFirestore(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? '',
      status: data['status'] as String? ?? '',
      driverId: data['driverId'] as String? ?? '',
    );
  }

  bool get isDriver => role == 'driver';
  bool get isActive => status == 'active';
}
