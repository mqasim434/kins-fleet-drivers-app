import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kins_fleet_drivers/core/imagekit/imagekit_client.dart';
import 'package:kins_fleet_drivers/core/imagekit/imagekit_config.dart';
import 'package:kins_fleet_drivers/core/imagekit/imagekit_models.dart';
import 'package:kins_fleet_drivers/features/photos/models/bus_option.dart';
import 'package:kins_fleet_drivers/features/photos/models/bus_photo.dart';
import 'package:kins_fleet_drivers/features/shifts/shifts_repository.dart';

class PhotosRepository {
  PhotosRepository({
    FirebaseFirestore? firestore,
    ShiftsRepository? shiftsRepository,
    ImageKitClient? imageKitClient,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _shiftsRepository = shiftsRepository ?? ShiftsRepository(),
        _imageKitClient = imageKitClient ?? ImageKitClient();

  final FirebaseFirestore _firestore;
  final ShiftsRepository _shiftsRepository;
  final ImageKitClient _imageKitClient;

  Future<List<BusOption>> fetchBusOptions(String driverId) async {
    final todayShifts = await _shiftsRepository.fetchTodayShifts(driverId);
    final fromShifts = <String, BusOption>{};

    for (final shift in todayShifts) {
      if (shift.busId.isEmpty) continue;
      fromShifts.putIfAbsent(
        shift.busId,
        () => BusOption(
          id: shift.busId,
          busNumber: shift.busNumber,
          licensePlate: shift.licensePlate,
          fromTodayShift: true,
        ),
      );
    }

    final busesSnapshot = await _firestore
        .collection('buses')
        .where('status', isNotEqualTo: 'inactive')
        .get();

    final allBuses = busesSnapshot.docs
        .map((doc) {
          final data = doc.data();
          return BusOption(
            id: doc.id,
            busNumber: data['busNumber'] as String? ?? '',
            licensePlate: data['licensePlate'] as String? ?? '',
            fromTodayShift: fromShifts.containsKey(doc.id),
          );
        })
        .toList()
      ..sort((a, b) => a.busNumber.compareTo(b.busNumber));

    if (fromShifts.isNotEmpty) {
      final shiftFirst = fromShifts.values.toList()
        ..sort((a, b) => a.busNumber.compareTo(b.busNumber));
      final others = allBuses.where((bus) => !fromShifts.containsKey(bus.id));
      return [...shiftFirst, ...others];
    }

    return allBuses;
  }

  Future<List<BusPhoto>> fetchMyPhotos(String uid) async {
    final snapshot = await _firestore
        .collection('busPhotos')
        .where('uploadedBy', isEqualTo: uid)
        .get();

    final photos = snapshot.docs
        .map((doc) => BusPhoto.fromFirestore(doc.id, doc.data()))
        .toList();

    photos.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      if (byDate != 0) return byDate;
      final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
      final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
      return bTime.compareTo(aTime);
    });

    return photos;
  }

  Future<BusPhoto> uploadPhoto({
    required BusOption bus,
    required String dateIso,
    required String notes,
    required String uploadedBy,
    required String uploadedByName,
    required File file,
    void Function(int percent)? onProgress,
  }) async {
    final folder = ImageKitConfig.folderForBus(bus.id, dateIso);

    final upload = await _imageKitClient.uploadFile(
      file: file,
      folder: folder,
      onProgress: onProgress,
    );

    return savePhotoMetadata(
      bus: bus,
      dateIso: dateIso,
      notes: notes,
      uploadedBy: uploadedBy,
      uploadedByName: uploadedByName,
      upload: upload,
    );
  }

  Future<BusPhoto> savePhotoMetadata({
    required BusOption bus,
    required String dateIso,
    required String notes,
    required String uploadedBy,
    required String uploadedByName,
    required ImageKitUploadResult upload,
  }) async {
    final uploadTime = DateTime.now().toUtc().toIso8601String();
    final payload = {
      'busId': bus.id,
      'busNumber': bus.busNumber,
      'licensePlate': bus.licensePlate,
      'date': dateIso,
      'uploadTime': uploadTime,
      'uploadedBy': uploadedBy,
      'uploadedByName': uploadedByName,
      'imagekitFileId': upload.fileId,
      'imageUrl': upload.url,
      'thumbnailUrl':
          upload.thumbnailUrl.isNotEmpty ? upload.thumbnailUrl : upload.url,
      'fileName': upload.fileName,
      'filePath': upload.filePath,
      'fileSize': upload.fileSize,
      'width': upload.width,
      'height': upload.height,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final ref = await _firestore.collection('busPhotos').add(payload);
    return BusPhoto(
      id: ref.id,
      busId: bus.id,
      busNumber: bus.busNumber,
      licensePlate: bus.licensePlate,
      date: dateIso,
      uploadTime: uploadTime,
      uploadedBy: uploadedBy,
      uploadedByName: uploadedByName,
      imagekitFileId: upload.fileId,
      imageUrl: upload.url,
      thumbnailUrl:
          upload.thumbnailUrl.isNotEmpty ? upload.thumbnailUrl : upload.url,
      fileName: upload.fileName,
      filePath: upload.filePath,
      fileSize: upload.fileSize,
      width: upload.width,
      height: upload.height,
      notes: notes,
      createdAt: DateTime.now(),
    );
  }
}
