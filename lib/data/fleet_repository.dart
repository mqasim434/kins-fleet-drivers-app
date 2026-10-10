import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kins_fleet_drivers/core/imagekit/imagekit_client.dart';
import 'package:kins_fleet_drivers/core/imagekit/imagekit_config.dart';
import 'package:kins_fleet_drivers/core/imagekit/imagekit_models.dart';
import 'package:kins_fleet_drivers/core/utils/dates.dart';
import 'package:kins_fleet_drivers/data/models.dart';
import 'package:kins_fleet_drivers/data/photo_quality.dart';

class PhotoPurpose {
  const PhotoPurpose(this.id, this.label);
  final String id;
  final String label;

  static const inspection = PhotoPurpose('inspection', 'Voertuigcontrole');
  static const condition = PhotoPurpose('condition', 'Staat van het voertuig');
  static const damage = PhotoPurpose('damage', 'Schade');
  static const other = PhotoPurpose('other', 'Overig');

  static const all = [inspection, condition, damage, other];

  static PhotoPurpose byId(String id) {
    return all.firstWhere((item) => item.id == id, orElse: () => other);
  }
}

class FleetRepository {
  FleetRepository({
    FirebaseFirestore? firestore,
    ImageKitClient? imageKit,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _imageKit = imageKit ?? ImageKitClient();

  final FirebaseFirestore _firestore;
  final ImageKitClient _imageKit;

  Future<List<ShiftAssignment>> fetchShifts(String driverId) async {
    final snapshot = await _firestore
        .collection('shiftAssignments')
        .where('driverId', isEqualTo: driverId)
        .get();

    final shifts = snapshot.docs
        .map((doc) => ShiftAssignment.fromFirestore(doc.id, doc.data()))
        .where((shift) => !shift.isCancelled && shift.date.isNotEmpty)
        .toList();
    shifts.sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      if (byDate != 0) return byDate;
      return a.startTime.compareTo(b.startTime);
    });
    return shifts;
  }

  Future<FleetBus?> fetchBus(String busId) async {
    if (busId.isEmpty) return null;
    final doc = await _firestore.collection('buses').doc(busId).get();
    if (!doc.exists || doc.data() == null) return null;
    final bus = FleetBus.fromFirestore(doc.id, doc.data()!);
    if (bus.status == 'inactive') return null;
    return bus;
  }

  Future<List<FleetBus>> fetchActiveBuses() async {
    final snapshot = await _firestore
        .collection('buses')
        .where('status', isNotEqualTo: 'inactive')
        .get();
    final buses = snapshot.docs
        .map((doc) => FleetBus.fromFirestore(doc.id, doc.data()))
        .toList();
    buses.sort(_compareBuses);
    return buses;
  }

  Stream<List<FleetBus>> watchActiveBuses() {
    return _firestore.collection('buses').where('status', isNotEqualTo: 'inactive').snapshots().map(
      (snapshot) {
        final buses = snapshot.docs
            .map((doc) => FleetBus.fromFirestore(doc.id, doc.data()))
            .where((bus) => bus.status != 'inactive')
            .toList();
        buses.sort(_compareBuses);
        return buses;
      },
    );
  }

  Stream<List<FleetDepartment>> watchDepartments() {
    return _firestore.collection('departments').snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((doc) => FleetDepartment.fromFirestore(doc.id, doc.data()))
          .where((item) => item.status != 'inactive')
          .toList();
      items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return items;
    });
  }

  Stream<List<BusPhotoRecord>> watchPhotosForDate(String dateIso) {
    return _firestore.collection('busPhotos').where('date', isEqualTo: dateIso).snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => BusPhotoRecord.fromFirestore(doc.id, doc.data()))
          .toList(),
    );
  }

  /// Narrower listener than [watchPhotosForDate] — fewer reads when many buses
  /// have photos on the same day (Spark quota).
  Stream<List<BusPhotoRecord>> watchPhotosForBusAndDate({
    required String busId,
    required String dateIso,
  }) {
    return _firestore
        .collection('busPhotos')
        .where('date', isEqualTo: dateIso)
        .where('busId', isEqualTo: busId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BusPhotoRecord.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Live buses, today's photos, and departments. Each upload from any
  /// fleet manager is its own document, so the counts stay combined.
  Stream<FleetPhotoRound> watchFleetRound(String dateIso) {
    final controller = StreamController<FleetPhotoRound>.broadcast();
    List<FleetBus>? buses;
    List<BusPhotoRecord>? photos;
    List<FleetDepartment>? departments;

    void emit() {
      if (buses == null || photos == null || controller.isClosed) return;
      controller.add(
        FleetPhotoRound(
          buses: buses!,
          photos: photos!,
          departments: departments ?? const [],
        ),
      );
    }

    final subscriptions = <StreamSubscription<dynamic>>[
      watchActiveBuses().listen((value) {
        buses = value;
        emit();
      }, onError: controller.addError),
      watchPhotosForDate(dateIso).listen((value) {
        photos = value;
        emit();
      }, onError: controller.addError),
      watchDepartments().listen((value) {
        departments = value;
        emit();
      }, onError: (_) {
        departments = const [];
        emit();
      }),
    ];

    controller.onCancel = () async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    };
    return controller.stream;
  }

  Future<List<ConcessionRecord>> fetchMyConcessions({
    required String transporterId,
    required String driverName,
    IsoWeek? week,
  }) async {
    final target = week ?? currentIsoWeek();
    final byId = <String, ConcessionRecord>{};

    Future<void> collect(Query<Map<String, dynamic>> query) async {
      final snapshot = await query.get();
      for (final doc in snapshot.docs) {
        byId[doc.id] = ConcessionRecord.fromFirestore(doc.id, doc.data());
      }
    }

    final trimmedTransporter = transporterId.trim();
    final trimmedName = driverName.trim();
    if (trimmedTransporter.isNotEmpty) {
      await collect(
        _firestore.collection('dnrConcessions').where('transporterId', isEqualTo: trimmedTransporter),
      );
    }
    if (trimmedName.isNotEmpty) {
      await collect(
        _firestore.collection('dnrConcessions').where('driverName', isEqualTo: trimmedName),
      );
    }

    final items = byId.values.where((item) {
      return item.weekYear == target.year && item.weekNumber == target.week;
    }).toList();
    items.sort((a, b) => a.trackingId.compareTo(b.trackingId));
    return items;
  }

  Future<List<BusPhotoRecord>> fetchMyPhotos(String uid) async {
    final snapshot = await _firestore
        .collection('busPhotos')
        .where('uploadedBy', isEqualTo: uid)
        .get();
    final photos = snapshot.docs
        .map((doc) => BusPhotoRecord.fromFirestore(doc.id, doc.data()))
        .toList();
    photos.sort((a, b) => b.date.compareTo(a.date));
    return photos;
  }

  Future<BusPhotoRecord> uploadPhoto({
    required FleetBus bus,
    required String dateIso,
    required PhotoPurpose purpose,
    required String notes,
    required String uploadedBy,
    required String uploadedByName,
    required String driverId,
    required File file,
    void Function(String phase)? onProgress,
  }) async {
    onProgress?.call('imagekit');
    final upload = await _imageKit.uploadFile(
      file: file,
      folder: ImageKitConfig.folderForBus(bus.id, dateIso),
    );
    onProgress?.call('firestore');
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    if (authUid == null || authUid.isEmpty) {
      throw FleetException('Je bent niet ingelogd. Log opnieuw in en probeer het opnieuw.');
    }
    if (uploadedBy != authUid) {
      throw FleetException('Sessie komt niet overeen met Firebase Auth. Log opnieuw in.');
    }
    if (driverId.isEmpty) {
      throw FleetException('Chauffeursprofiel ontbreekt. Neem contact op met KINS support.');
    }
    final noteText = _photoNote(purpose, notes);
    final payload = {
      'busId': bus.id,
      'busNumber': bus.busNumber,
      'licensePlate': bus.licensePlate,
      'date': dateIso,
      'uploadTime': DateTime.now().toUtc().toIso8601String(),
      'uploadedBy': authUid,
      'uploadedByName': uploadedByName,
      'driverId': driverId,
      'purpose': purpose.id,
      'imagekitFileId': upload.fileId,
      'imageUrl': upload.url,
      'thumbnailUrl': upload.thumbnailUrl.isNotEmpty ? upload.thumbnailUrl : upload.url,
      'fileName': upload.fileName,
      'filePath': upload.filePath,
      'fileSize': upload.fileSize,
      'width': upload.width,
      'height': upload.height,
      'notes': noteText,
      'qualityOk': photoCountsAsGood(
        qualityOk: false,
        width: upload.width,
        height: upload.height,
        fileSize: upload.fileSize,
      ),
      'createdAt': FieldValue.serverTimestamp(),
    };
    DocumentReference<Map<String, dynamic>> ref;
    try {
      ref = await _firestore
          .collection('busPhotos')
          .add(payload)
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () => throw TimeoutException('firestore_save'),
          );
    } on FirebaseException catch (error) {
      throw FleetException(_firestoreWriteMessage(error.code));
    }
    final qualityOk = photoCountsAsGood(
      qualityOk: false,
      width: upload.width,
      height: upload.height,
      fileSize: upload.fileSize,
    );
    return BusPhotoRecord(
      id: ref.id,
      busId: bus.id,
      busNumber: bus.busNumber,
      licensePlate: bus.licensePlate,
      date: dateIso,
      purpose: purpose.id,
      notes: noteText,
      imageUrl: upload.url,
      thumbnailUrl: upload.thumbnailUrl.isNotEmpty ? upload.thumbnailUrl : upload.url,
      uploadedByName: uploadedByName,
      width: upload.width,
      height: upload.height,
      fileSize: upload.fileSize,
      qualityOk: qualityOk,
    );
  }

  Future<void> createDamageReport({
    required FleetBus bus,
    required String dateIso,
    required String driverId,
    required String driverName,
    required String departmentId,
    required String reportedBy,
    required String reportedByUid,
    required String description,
    required String damageType,
    required String severity,
    required String photoId,
    required String imageUrl,
  }) async {
    final now = FieldValue.serverTimestamp();
    await _firestore.collection('damageReports').add({
      'source': 'manual',
      'busId': bus.id,
      'busNumber': bus.busNumber,
      'licensePlate': bus.licensePlate,
      'driverId': driverId,
      'driverName': driverName,
      'departmentId': departmentId,
      'date': dateIso,
      'photoId': photoId,
      'imageUrl': imageUrl,
      'description': description,
      'damageType': damageType,
      'severity': severity,
      'status': 'reported',
      'reportedBy': reportedBy,
      'reportedByUid': reportedByUid,
      'reviewedBy': '',
      'reviewedAt': null,
      'createdAt': now,
      'updatedAt': now,
    }).timeout(
      const Duration(seconds: 20),
      onTimeout: () => throw TimeoutException('firestore_save'),
    );
  }

  Future<List<DamageReport>> fetchMyDamage(String uid) async {
    final snapshot = await _firestore
        .collection('damageReports')
        .where('reportedByUid', isEqualTo: uid)
        .get();
    final items = snapshot.docs
        .map((doc) => DamageReport.fromFirestore(doc.id, doc.data()))
        .toList();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  String _firestoreWriteMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return 'Geen rechten om busfoto\'s op te slaan. Controleer of je users/{uid} '
            'role driver, status active en driverId heeft (project kins-logistics).';
      case 'resource-exhausted':
        return 'Firestore-limiet bereikt op kins-logistics (Spark/daglimiet). '
            'Wacht tot morgen, verminder test-verkeer, of schakel Blaze billing in.';
      case 'unavailable':
        return 'Firestore is tijdelijk niet bereikbaar. Probeer het over een minuut opnieuw.';
      default:
        return 'Opslaan in het dossier mislukt ($code). Probeer het opnieuw.';
    }
  }

  String _photoNote(PhotoPurpose purpose, String notes) {
    final trimmed = notes.trim();
    if (trimmed.isEmpty) return purpose.label;
    return '${purpose.label} — $trimmed';
  }

  int _compareBuses(FleetBus a, FleetBus b) {
    final byNumber = a.busNumber.toLowerCase().compareTo(b.busNumber.toLowerCase());
    if (byNumber != 0) return byNumber;
    return a.licensePlate.toLowerCase().compareTo(b.licensePlate.toLowerCase());
  }
}

class FleetPhotoRound {
  const FleetPhotoRound({
    required this.buses,
    required this.photos,
    required this.departments,
  });

  final List<FleetBus> buses;
  final List<BusPhotoRecord> photos;
  final List<FleetDepartment> departments;

  Map<String, int> goodCounts() {
    final counts = <String, int>{};
    for (final photo in photos) {
      if (!photo.countsAsGood || photo.busId.isEmpty) continue;
      counts[photo.busId] = (counts[photo.busId] ?? 0) + 1;
    }
    return counts;
  }
}

class FleetException implements Exception {
  FleetException(this.message);
  final String message;

  factory FleetException.from(Object error) {
    if (error is FleetException) return error;
    if (error is ImageKitException) {
      switch (error.message) {
        case 'ImageKit not configured':
          return FleetException(
            'Foto-upload is niet geconfigureerd in deze app-build. '
            'Installeer opnieuw via een build met ImageKit-instellingen, '
            'of neem contact op met KINS support.',
          );
        case 'file_too_large':
          return FleetException('De foto is te groot. Maximum is 10 MB.');
        case 'invalid_type':
          return FleetException('Alleen JPG, PNG, WEBP en HEIC zijn toegestaan.');
        case 'upload_timeout':
          return FleetException(
            'De upload naar ImageKit duurde te lang. Controleer internet en probeer opnieuw.',
          );
        default:
          final message = error.message.toLowerCase();
          if (message.contains('cannot be authenticated') ||
              message.contains('authentication')) {
            return FleetException(
              'ImageKit-weigert de upload. Controleer IMAGEKIT_PRIVATE_KEY '
              'in .env.json (Developer → API keys) en start opnieuw met '
              'flutter run --dart-define-from-file=.env.json',
            );
          }
          return FleetException(error.message);
      }
    }
    final text = error.toString();
    if (text.contains('firestore_save') || error is TimeoutException) {
      return FleetException(
        'De foto staat in ImageKit maar Firestore (kins-logistics) reageerde niet '
        'binnen 20 seconden. Vaak: daglimiet bereikt (Spark), geen internet, of '
        'regels nog niet actief — controleer Firebase Console → Usage.',
      );
    }
    if (text.contains('resource-exhausted') || text.contains('Quota exceeded')) {
      return FleetException(
        'Firestore-limiet bereikt op kins-logistics. Foto staat wel in ImageKit.',
      );
    }
    if (text.contains('permission-denied')) {
      return FleetException('Geen rechten om dit op te slaan.');
    }
    return FleetException('Opslaan is mislukt. Probeer het opnieuw.');
  }
}
