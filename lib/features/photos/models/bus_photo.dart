import 'package:cloud_firestore/cloud_firestore.dart';

class BusPhoto {
  const BusPhoto({
    required this.id,
    required this.busId,
    required this.busNumber,
    required this.licensePlate,
    required this.date,
    required this.uploadTime,
    required this.uploadedBy,
    required this.uploadedByName,
    required this.imagekitFileId,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.width,
    required this.height,
    required this.notes,
    required this.createdAt,
  });

  final String id;
  final String busId;
  final String busNumber;
  final String licensePlate;
  final String date;
  final String uploadTime;
  final String uploadedBy;
  final String uploadedByName;
  final String imagekitFileId;
  final String imageUrl;
  final String thumbnailUrl;
  final String fileName;
  final String filePath;
  final int fileSize;
  final int width;
  final int height;
  final String notes;
  final DateTime? createdAt;

  factory BusPhoto.fromFirestore(String id, Map<String, dynamic> data) {
    return BusPhoto(
      id: id,
      busId: data['busId'] as String? ?? '',
      busNumber: data['busNumber'] as String? ?? '',
      licensePlate: data['licensePlate'] as String? ?? '',
      date: data['date'] as String? ?? '',
      uploadTime: data['uploadTime'] as String? ?? '',
      uploadedBy: data['uploadedBy'] as String? ?? '',
      uploadedByName: data['uploadedByName'] as String? ?? '',
      imagekitFileId: data['imagekitFileId'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      thumbnailUrl: data['thumbnailUrl'] as String? ?? '',
      fileName: data['fileName'] as String? ?? '',
      filePath: data['filePath'] as String? ?? '',
      fileSize: (data['fileSize'] as num?)?.toInt() ?? 0,
      width: (data['width'] as num?)?.toInt() ?? 0,
      height: (data['height'] as num?)?.toInt() ?? 0,
      notes: data['notes'] as String? ?? '',
      createdAt: _toDateTime(data['createdAt']),
    );
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
