class Bus {
  const Bus({
    required this.id,
    required this.busNumber,
    required this.licensePlate,
    required this.brand,
    required this.model,
    required this.year,
    required this.status,
    required this.notes,
  });

  final String id;
  final String busNumber;
  final String licensePlate;
  final String brand;
  final String model;
  final String year;
  final String status;
  final String notes;

  factory Bus.fromFirestore(String id, Map<String, dynamic> data) {
    return Bus(
      id: id,
      busNumber: data['busNumber'] as String? ?? '',
      licensePlate: data['licensePlate'] as String? ?? '',
      brand: data['brand'] as String? ?? '',
      model: data['model'] as String? ?? '',
      year: data['year']?.toString() ?? '',
      status: data['status'] as String? ?? 'available',
      notes: data['notes'] as String? ?? '',
    );
  }

  String get displayName {
    final parts = <String>[];
    if (brand.isNotEmpty) parts.add(brand);
    if (model.isNotEmpty) parts.add(model);
    return parts.isEmpty ? 'Bus $busNumber' : parts.join(' ');
  }
}
