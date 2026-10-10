import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kins_fleet_drivers/core/imagekit/imagekit_client.dart';

class OnboardingDoc {
  const OnboardingDoc(this.key, this.label, {this.required = true});

  final String key;
  final String label;
  final bool required;
}

const onboardingDocs = <OnboardingDoc>[
  OnboardingDoc('aanmeldformulier', 'Aanmeldformulier'),
  OnboardingDoc('rijbewijsVoor', 'Rijbewijs voorzijde'),
  OnboardingDoc('rijbewijsAchter', 'Rijbewijs achterzijde'),
  OnboardingDoc('bankpas', 'Bankpas'),
  OnboardingDoc('paspoortVoor', 'Paspoort/ID voorzijde'),
  OnboardingDoc('paspoortAchter', 'Paspoort/ID achterzijde'),
  OnboardingDoc('chauffeursfoto', 'Foto chauffeur'),
  OnboardingDoc('bsn', 'BSN', required: false),
  OnboardingDoc('contract', 'Contract (later)', required: false),
];

const progressDocKeys = [
  'aanmeldformulier',
  'rijbewijsVoor',
  'rijbewijsAchter',
  'bankpas',
  'paspoortVoor',
  'paspoortAchter',
  'chauffeursfoto',
];

class OnboardingCandidate {
  const OnboardingCandidate({
    required this.id,
    required this.fullName,
    required this.data,
  });

  final String id;
  final String fullName;
  final Map<String, dynamic> data;

  String get location => data['location'] as String? ?? '';
  String get email => data['email'] as String? ?? '';

  Map<String, String> get documentUrls {
    final raw = data['documentUrls'];
    if (raw is! Map) return {};
    return raw.map((key, value) => MapEntry('$key', value is String ? value : ''));
  }

  int get uploadedRequired =>
      progressDocKeys.where((key) => (documentUrls[key] ?? '').isNotEmpty).length;

  factory OnboardingCandidate.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final name = (data['fullName'] as String? ?? '').trim().isNotEmpty
        ? data['fullName'] as String
        : '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
    return OnboardingCandidate(id: doc.id, fullName: name, data: data);
  }
}

class OnboardingRepository {
  OnboardingRepository({
    FirebaseFirestore? firestore,
    ImageKitClient? imageKit,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _imageKit = imageKit ?? ImageKitClient();

  final FirebaseFirestore _firestore;
  final ImageKitClient _imageKit;

  Future<List<OnboardingCandidate>> fetchOpen() async {
    final snap = await _firestore.collection('onboardingCandidates').get();
    final items = snap.docs
        .map(OnboardingCandidate.fromDoc)
        .where((item) {
          final status = item.data['status'] as String? ?? 'pending';
          return status != 'active' && status != 'deleted';
        })
        .toList();
    items.sort((a, b) => a.fullName.compareTo(b.fullName));
    return items;
  }

  Future<OnboardingCandidate?> fetchOne(String id) async {
    final snap = await _firestore.collection('onboardingCandidates').doc(id).get();
    if (!snap.exists) return null;
    return OnboardingCandidate.fromDoc(snap);
  }

  Future<String> suggestEmployeeNumber() async {
    final numbers = <String>[];
    for (final name in ['personnelRecords', 'drivers', 'onboardingCandidates']) {
      final snap = await _firestore.collection(name).get();
      for (final doc in snap.docs) {
        final data = doc.data();
        final value = '${data['employeeNumber'] ?? data['employeeId'] ?? ''}'.trim();
        if (value.isNotEmpty) numbers.add(value);
      }
    }
    return _nextEmployeeNumber(numbers);
  }

  Future<List<String>> departmentIdsFor(String location) async {
    final code = location.toUpperCase();
    if (code != 'ONL3' && code != 'DNL1') return const [];
    final snap = await _firestore.collection('departments').get();
    final ids = <String>[];
    for (final doc in snap.docs) {
      final data = doc.data();
      if (data['status'] == 'inactive') continue;
      final hay = '${data['code'] ?? ''} ${data['name'] ?? ''}'.toUpperCase();
      if (hay.contains(code)) ids.add(doc.id);
    }
    return ids;
  }

  Future<String> saveCandidate({
    String? existingId,
    required Map<String, String> fields,
    required Map<String, File> newPhotos,
    required Map<String, String> existingUrls,
    required String createdByUid,
    required String createdByName,
  }) async {
    final email = _workEmail(fields['workEmailLocal'] ?? '');
    final id = (existingId != null && existingId.isNotEmpty)
        ? existingId
        : email.toLowerCase().replaceAll(RegExp(r'[^a-z0-9@._+-]'), '');
    if (id.isEmpty) {
      throw Exception('Werk-e-mail is verplicht.');
    }

    final location = (fields['location'] ?? '').toUpperCase();
    final months = int.tryParse(fields['contractMonths'] ?? '');
    final startDate = fields['startDate'] ?? '';
    final urls = Map<String, String>.from(existingUrls);

    final ref = _firestore.collection('onboardingCandidates').doc(id);
    final firstName = (fields['firstName'] ?? '').trim();
    final lastName = (fields['lastName'] ?? '').trim();
    final fullName = '$firstName $lastName'.trim();
    final record = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'name': fullName,
      'employeeNumber': (fields['employeeNumber'] ?? '').trim(),
      'privateEmail': (fields['privateEmail'] ?? '').trim().toLowerCase(),
      'email': email,
      'phone': (fields['phone'] ?? '').trim(),
      'location': location,
      'address': (fields['address'] ?? '').trim(),
      'postcode': (fields['postcode'] ?? '').trim(),
      'city': (fields['city'] ?? '').trim(),
      'bankAccount': (fields['bankAccount'] ?? '').trim(),
      'bsn': (fields['bsn'] ?? '').trim(),
      'passportExpiry': fields['passportExpiry'] ?? '',
      'language': (fields['language'] ?? 'nl').trim(),
      'startDate': startDate,
      'contractMonths': months,
      'contractExpiry': _contractExpiry(startDate, months),
      'transporterId': (fields['transporterId'] ?? '').trim(),
      'departmentIds': await departmentIdsFor(location),
      'createdByUid': createdByUid,
      'createdByName': createdByName,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    final existing = await ref.get();
    if (!existing.exists) {
      record.addAll({
        'status': 'pending',
        'trainingCompleted': false,
        'backgroundCheckCompleted': false,
        'contractSent': false,
        'contractSigned': false,
        'accountsCreated': false,
        'hrApproved': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await ref.set(record, SetOptions(merge: true));

    for (final entry in newPhotos.entries) {
      final upload = await _imageKit.uploadFile(
        file: entry.value,
        folder: '/kins-fleet/onboarding/$id',
        fileName: '${entry.key}.jpg',
      );
      urls[entry.key] = upload.url;
    }

    final documents = <String, bool>{
      for (final doc in onboardingDocs) doc.key: (urls[doc.key] ?? '').isNotEmpty,
    };
    final completed = progressDocKeys.where((key) => (urls[key] ?? '').isNotEmpty).length;
    await ref.set({
      'documentUrls': urls,
      'documents': documents,
      'progressCompleted': completed,
      'progressTotal': progressDocKeys.length + 1,
      'progressRequired': progressDocKeys.length,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return id;
  }

  String _workEmail(String localPart) {
    var local = localPart.trim().toLowerCase().replaceAll(RegExp(r'@.*$'), '');
    local = local.replaceAll(RegExp(r'[^a-z0-9._+-]'), '');
    if (local.isEmpty) return '';
    return '$local@kinsdriver.nl';
  }

  String _contractExpiry(String startDate, int? months) {
    if (startDate.length < 10 || months == null || months <= 0) return '';
    final start = DateTime.tryParse('${startDate.substring(0, 10)}T12:00:00');
    if (start == null) return '';
    final expiry = DateTime(start.year, start.month + months, start.day);
    final month = expiry.month.toString().padLeft(2, '0');
    final day = expiry.day.toString().padLeft(2, '0');
    return '${expiry.year}-$month-$day';
  }

  String _nextEmployeeNumber(List<String> raw) {
    final taken = raw.map((value) => value.toLowerCase()).toSet();
    String? prefix;
    var width = 0;
    var best = -1;
    for (final value in raw) {
      final match = RegExp(r'^(.*?)(\d+)$').firstMatch(value);
      if (match == null) continue;
      final n = int.tryParse(match.group(2)!);
      if (n == null || n <= best) continue;
      best = n;
      prefix = match.group(1)!;
      width = match.group(2)!.length;
    }
    if (best < 0 || prefix == null) return '1';
    var n = best + 1;
    var value = '$prefix${n.toString().padLeft(width, '0')}';
    while (taken.contains(value.toLowerCase())) {
      n += 1;
      value = '$prefix${n.toString().padLeft(width, '0')}';
    }
    return value;
  }
}
