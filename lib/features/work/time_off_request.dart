import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kins_fleet_drivers/core/auth/auth_controller.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';
import 'package:provider/provider.dart';

class TimeOffRequest {
  const TimeOffRequest({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.note,
  });

  final String id;
  final String startDate;
  final String endDate;
  final String status;
  final String note;

  factory TimeOffRequest.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return TimeOffRequest(
      id: doc.id,
      startDate: data['startDate'] as String? ?? '',
      endDate: data['endDate'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      note: data['note'] as String? ?? '',
    );
  }
}

String formatIso(String iso) {
  final parts = iso.split('-');
  if (parts.length != 3) return iso;
  return '${parts[2]}-${parts[1]}-${parts[0]}';
}

String _iso(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

bool _overlaps(String start, String end, TimeOffRequest other) {
  return start.compareTo(other.endDate) <= 0 && other.startDate.compareTo(end) <= 0;
}

Future<int> loadTimeOffMinWeeks() async {
  final snap = await FirebaseFirestore.instance.collection('settings').doc('timeOff').get();
  final weeks = snap.data()?['minWeeks'];
  if (weeks is num && weeks >= 1 && weeks <= 52) return weeks.round();
  return 4;
}

Future<List<TimeOffRequest>> loadMyTimeOff(String driverId) async {
  final snap = await FirebaseFirestore.instance
      .collection('timeOffRequests')
      .where('driverId', isEqualTo: driverId)
      .get();
  final items = snap.docs.map(TimeOffRequest.fromDoc).toList();
  items.sort((a, b) => b.startDate.compareTo(a.startDate));
  return items;
}

Future<bool> showTimeOffRequest(BuildContext context) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _TimeOffSheet(),
  );
  return saved == true;
}

class _TimeOffSheet extends StatefulWidget {
  const _TimeOffSheet();

  @override
  State<_TimeOffSheet> createState() => _TimeOffSheetState();
}

class _TimeOffSheetState extends State<_TimeOffSheet> {
  DateTime? _start;
  DateTime? _end;
  final _note = TextEditingController();
  int _minWeeks = 4;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    loadTimeOffMinWeeks().then((weeks) {
      if (!mounted) return;
      setState(() {
        _minWeeks = weeks;
        _loading = false;
      });
    }).catchError((_) {
      if (!mounted) return;
      setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  DateTime get _earliest => _dateOnly(DateTime.now()).add(Duration(days: _minWeeks * 7));

  Future<void> _pick(bool start) async {
    final initial = start ? (_start ?? _earliest) : (_end ?? _start ?? _earliest);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(_earliest) ? _earliest : initial,
      firstDate: _earliest,
      lastDate: _earliest.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _start = _dateOnly(picked);
        if (_end != null && _end!.isBefore(_start!)) _end = _start;
      } else {
        _end = _dateOnly(picked);
      }
      _error = null;
    });
  }

  Future<void> _submit() async {
    final session = context.read<AuthController>().session;
    if (session == null || _saving) return;
    if (_start == null || _end == null) {
      setState(() => _error = 'Kies een start- en einddatum.');
      return;
    }
    if (_start!.isBefore(_earliest)) {
      setState(() => _error = 'Verlof moet minstens $_minWeeks weken van tevoren beginnen.');
      return;
    }
    final start = _iso(_start!);
    final end = _iso(_end!);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final existing = await loadMyTimeOff(session.driverRecord.id);
      final clash = existing.any(
        (item) =>
            (item.status == 'pending' || item.status == 'approved') && _overlaps(start, end, item),
      );
      if (clash) {
        setState(() => _error = 'Er is al een aanvraag in deze periode.');
        return;
      }
      await FirebaseFirestore.instance.collection('timeOffRequests').add({
        'driverId': session.driverRecord.id,
        'driverName': session.driverRecord.displayName,
        'userId': session.user.uid,
        'startDate': start,
        'endDate': end,
        'status': 'pending',
        'note': _note.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'reviewedBy': '',
        'reviewedAt': null,
      });
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Aanvraag versturen is mislukt. Probeer het opnieuw.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Verlof aanvragen', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            _loading
                ? 'Instelling laden…'
                : 'Het verlof moet minstens $_minWeeks weken van tevoren beginnen.',
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _loading || _saving ? null : () => _pick(true),
            child: Text(_start == null ? 'Startdatum' : 'Start ${formatIso(_iso(_start!))}'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _loading || _saving ? null : () => _pick(false),
            child: Text(_end == null ? 'Einddatum' : 'Einde ${formatIso(_iso(_end!))}'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _note,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Toelichting (optioneel)'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppColors.bordeaux)),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading || _saving ? null : _submit,
            child: Text(_saving ? 'Versturen…' : 'Aanvraag versturen'),
          ),
        ],
      ),
    );
  }
}

class TimeOffRequestBanner extends StatelessWidget {
  const TimeOffRequestBanner({super.key, required this.requests});

  final List<TimeOffRequest> requests;

  @override
  Widget build(BuildContext context) {
    final visible = requests.where((item) => item.status != 'rejected').toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          for (final request in visible)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${_statusLabel(request.status)} · ${formatIso(request.startDate)} – ${formatIso(request.endDate)}',
              ),
            ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Goedgekeurd';
      case 'rejected':
        return 'Afgewezen';
      default:
        return 'In afwachting';
    }
  }
}
