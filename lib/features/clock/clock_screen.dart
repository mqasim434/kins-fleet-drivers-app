import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kins_fleet_drivers/core/auth/auth_controller.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';
import 'package:kins_fleet_drivers/core/utils/dates.dart';
import 'package:provider/provider.dart';

class _Place {
  const _Place({required this.name, required this.latitude, required this.longitude, required this.radiusMeters});

  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeters;
}

class _ClockRules {
  const _ClockRules({required this.geofenceEnabled, required this.locations, required this.closedMonths});

  final bool geofenceEnabled;
  final List<_Place> locations;
  final List<String> closedMonths;
}

class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  final _firestore = FirebaseFirestore.instance;
  bool _busy = false;
  String? _message;

  String _today() => todayIso();

  String _entryId(String uid) => '${uid}_${_today()}';

  Future<_ClockRules> _rules() async {
    final settingsSnap = await _firestore.collection('clockSettings').doc('config').get();
    final monthsSnap = await _firestore.collection('clockMonths').doc('status').get();
    final data = settingsSnap.data() ?? {};
    final rawPlaces = data['locations'];
    final places = <_Place>[];
    if (rawPlaces is List) {
      for (final item in rawPlaces) {
        if (item is! Map) continue;
        final latitude = (item['latitude'] as num?)?.toDouble();
        final longitude = (item['longitude'] as num?)?.toDouble();
        if (latitude == null || longitude == null) continue;
        places.add(
          _Place(
            name: item['name'] as String? ?? 'Locatie',
            latitude: latitude,
            longitude: longitude,
            radiusMeters: (item['radiusMeters'] as num?)?.toDouble() ?? 200,
          ),
        );
      }
    }
    final months = monthsSnap.data()?['closedMonths'];
    return _ClockRules(
      geofenceEnabled: data['geofenceEnabled'] == true,
      locations: places,
      closedMonths: months is List ? months.map((item) => '$item').toList() : const [],
    );
  }

  Future<Position> _requirePosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception('Zet locatie aan om in of uit te klokken.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      throw Exception('Inklokken kan alleen als je je locatie deelt.');
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  bool _insideFence(Position position, List<_Place> places) {
    for (final place in places) {
      final meters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        place.latitude,
        place.longitude,
      );
      if (meters <= place.radiusMeters) return true;
    }
    return false;
  }

  Future<void> _clock(bool clockingIn) async {
    final session = context.read<AuthController>().session;
    if (session == null || _busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final rules = await _rules();
      final month = _today().substring(0, 7);
      if (rules.closedMonths.contains(month)) {
        throw Exception('Deze maand is afgesloten.');
      }
      final position = await _requirePosition();
      if (rules.geofenceEnabled) {
        if (rules.locations.isEmpty) {
          throw Exception('Er is nog geen inkloklocatie ingesteld.');
        }
        if (!_insideFence(position, rules.locations)) {
          throw Exception('Je bent niet op een toegestane locatie.');
        }
      }
      final ref = _firestore.collection('clockEntries').doc(_entryId(session.user.uid));
      final now = DateTime.now().millisecondsSinceEpoch;
      if (clockingIn) {
        await ref.set({
          'userId': session.user.uid,
          'userName': session.user.name,
          'driverId': session.driverRecord.id,
          'driverName': session.driverRecord.fullName,
          'date': _today(),
          'clockInAt': now,
          'clockOutAt': null,
          'clockInLat': position.latitude,
          'clockInLng': position.longitude,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await ref.set({
          'clockOutAt': now,
          'clockOutLat': position.latitude,
          'clockOutLng': position.longitude,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      if (mounted) {
        setState(() => _message = clockingIn ? 'Je bent ingeklokt.' : 'Je bent uitgeklokt.');
      }
    } catch (error) {
      if (mounted) {
        final text = '$error'.replaceFirst('Exception: ', '');
        setState(() => _message = text);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _timeLabel(dynamic value) {
    if (value is! num) return '—';
    final time = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthController>().session;
    if (session == null) return const SizedBox.shrink();
    final ref = _firestore.collection('clockEntries').doc(_entryId(session.user.uid));

    return Scaffold(
      appBar: AppBar(title: const Text('Clock In')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: ref.snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data();
          final clockedIn = data?['clockInAt'] != null && data?['clockOutAt'] == null;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                session.driverRecord.displayName,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(formatIsoDate(_today()), style: const TextStyle(color: AppColors.muted)),
              const SizedBox(height: 20),
              Text('In: ${_timeLabel(data?['clockInAt'])}'),
              const SizedBox(height: 6),
              Text('Uit: ${_timeLabel(data?['clockOutAt'])}'),
              const SizedBox(height: 20),
              const Text(
                'Je kunt alleen inklokken als je je locatie deelt.',
                style: TextStyle(color: AppColors.muted),
              ),
              if (_message != null) ...[
                const SizedBox(height: 12),
                Text(_message!, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.bordeaux,
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: _busy ? null : () => _clock(!clockedIn),
                child: _busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(clockedIn ? 'Uitklokken' : 'Inklokken'),
              ),
            ],
          );
        },
      ),
    );
  }
}
