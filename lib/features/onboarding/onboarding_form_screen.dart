import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kins_fleet_drivers/core/auth/auth_controller.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';
import 'package:kins_fleet_drivers/features/onboarding/onboarding_repository.dart';
import 'package:provider/provider.dart';

class OnboardingFormScreen extends StatefulWidget {
  const OnboardingFormScreen({super.key, this.candidateId});

  final String? candidateId;

  @override
  State<OnboardingFormScreen> createState() => _OnboardingFormScreenState();
}

class _OnboardingFormScreenState extends State<OnboardingFormScreen> {
  final _repo = OnboardingRepository();
  final _picker = ImagePicker();
  final _fields = <String, TextEditingController>{};
  String _location = 'ONL3';
  String _language = 'nl';
  String _startDate = '';
  String _passportExpiry = '';
  final _photos = <String, File>{};
  final _urls = <String, String>{};
  bool _loading = true;
  bool _saving = false;
  String? _error;

  bool get _editing => widget.candidateId != null;

  @override
  void initState() {
    super.initState();
    for (final key in [
      'firstName',
      'lastName',
      'employeeNumber',
      'privateEmail',
      'workEmailLocal',
      'phone',
      'address',
      'postcode',
      'city',
      'bankAccount',
      'bsn',
      'contractMonths',
      'transporterId',
    ]) {
      _fields[key] = TextEditingController();
    }
    _load();
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      if (_editing) {
        final candidate = await _repo.fetchOne(widget.candidateId!);
        if (candidate == null) throw Exception('Kandidaat niet gevonden.');
        final data = candidate.data;
        _set('firstName', data['firstName']);
        _set('lastName', data['lastName']);
        _set('employeeNumber', data['employeeNumber']);
        _set('privateEmail', data['privateEmail']);
        _set('workEmailLocal', _localPart('${data['email'] ?? ''}'));
        _set('phone', data['phone']);
        _set('address', data['address']);
        _set('postcode', data['postcode']);
        _set('city', data['city']);
        _set('bankAccount', data['bankAccount']);
        _set('bsn', data['bsn']);
        _set('contractMonths', data['contractMonths']);
        _set('transporterId', data['transporterId']);
        final location = '${data['location'] ?? ''}'.toUpperCase();
        _location = location.contains('DNL1') && !location.contains('ONL3') ? 'DNL1' : 'ONL3';
        final language = '${data['language'] ?? 'nl'}';
        _language = language == 'en' ? 'en' : 'nl';
        _startDate = '${data['startDate'] ?? ''}';
        _passportExpiry = '${data['passportExpiry'] ?? ''}';
        _urls.addAll(candidate.documentUrls);
      } else {
        final number = await _repo.suggestEmployeeNumber();
        _fields['employeeNumber']!.text = number;
      }
    } catch (error) {
      _error = '$error'.replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _set(String key, Object? value) {
    _fields[key]!.text = value == null ? '' : '$value';
  }

  String _localPart(String email) {
    final lower = email.toLowerCase();
    const domain = '@kinsdriver.nl';
    if (lower.endsWith(domain)) return email.substring(0, email.length - domain.length);
    final at = email.indexOf('@');
    return at >= 0 ? email.substring(0, at) : email;
  }

  Future<void> _pickDate(bool passport) async {
    final current = passport ? _passportExpiry : _startDate;
    final initial = DateTime.tryParse('${current}T12:00:00') ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    final month = picked.month.toString().padLeft(2, '0');
    final day = picked.day.toString().padLeft(2, '0');
    setState(() {
      final iso = '${picked.year}-$month-$day';
      if (passport) {
        _passportExpiry = iso;
      } else {
        _startDate = iso;
      }
    });
  }

  Future<void> _capture(String key) async {
    final shot = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (shot == null) return;
    setState(() => _photos[key] = File(shot.path));
  }

  String? _validate() {
    const required = {
      'firstName': 'Voornaam',
      'lastName': 'Achternaam',
      'employeeNumber': 'Personeelsnummer',
      'privateEmail': 'Privé e-mail',
      'workEmailLocal': 'Werk-e-mail',
      'phone': 'Telefoonnummer',
      'address': 'Adres',
      'postcode': 'Postcode',
      'city': 'Plaats',
      'bankAccount': 'Bankrekening / IBAN',
      'bsn': 'BSN-nummer',
      'contractMonths': 'Contractduur',
      'transporterId': 'Transporter ID',
    };
    for (final entry in required.entries) {
      if (_fields[entry.key]!.text.trim().isEmpty) return '${entry.value} is verplicht.';
    }
    final email = _fields['privateEmail']!.text.trim();
    if (!email.contains('@') || !email.contains('.')) return 'Voer een geldig privé e-mailadres in.';
    if (_fields['workEmailLocal']!.text.contains('@')) return 'Vul alleen het deel vóór @ in.';
    final months = int.tryParse(_fields['contractMonths']!.text.trim());
    if (months == null || months <= 0) return 'Contractduur moet een aantal maanden zijn.';
    if (_startDate.isEmpty) return 'Startdatum is verplicht.';
    if (_passportExpiry.isEmpty) return 'Paspoort vervaldatum is verplicht.';
    for (final doc in onboardingDocs.where((item) => item.required)) {
      final hasUrl = (_urls[doc.key] ?? '').isNotEmpty;
      if (!hasUrl && !_photos.containsKey(doc.key)) return 'Foto ontbreekt: ${doc.label}.';
    }
    return null;
  }

  Future<void> _save() async {
    final problem = _validate();
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    final session = context.read<AuthController>().session;
    if (session == null || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final fields = {for (final entry in _fields.entries) entry.key: entry.value.text.trim()};
      fields['location'] = _location;
      fields['language'] = _language;
      fields['startDate'] = _startDate;
      fields['passportExpiry'] = _passportExpiry;
      await _repo.saveCandidate(
        existingId: widget.candidateId,
        fields: fields,
        newPhotos: _photos,
        existingUrls: _urls,
        createdByUid: session.user.uid,
        createdByName: session.user.name,
      );
      if (mounted) context.pop(true);
    } catch (error) {
      if (mounted) {
        setState(() => _error = '$error'.replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Onboarding aanvullen' : 'Nieuwe chauffeur')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _text('firstName', 'Voornaam'),
                _text('lastName', 'Achternaam'),
                _text('employeeNumber', 'Personeelsnummer'),
                _text('privateEmail', 'Privé e-mail', keyboard: TextInputType.emailAddress),
                _text('workEmailLocal', 'Werk-e-mail', suffix: '@kinsdriver.nl'),
                _text('phone', 'Telefoonnummer', keyboard: TextInputType.phone),
                DropdownButtonFormField<String>(
                  value: _location,
                  decoration: const InputDecoration(labelText: 'Locatie'),
                  items: const [
                    DropdownMenuItem(value: 'ONL3', child: Text('ONL3')),
                    DropdownMenuItem(value: 'DNL1', child: Text('DNL1')),
                  ],
                  onChanged: _saving ? null : (value) => setState(() => _location = value ?? 'ONL3'),
                ),
                _text('address', 'Adres'),
                _text('postcode', 'Postcode'),
                _text('city', 'Plaats'),
                _text('bankAccount', 'Bankrekening / IBAN'),
                _text('bsn', 'BSN-nummer'),
                _dateButton('Paspoort vervaldatum', _passportExpiry, () => _pickDate(true)),
                DropdownButtonFormField<String>(
                  value: _language,
                  decoration: const InputDecoration(labelText: 'Taal'),
                  items: const [
                    DropdownMenuItem(value: 'nl', child: Text('Nederlands')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: _saving ? null : (value) => setState(() => _language = value ?? 'nl'),
                ),
                _dateButton('Startdatum', _startDate, () => _pickDate(false)),
                _text('contractMonths', 'Contractduur (maanden)', keyboard: TextInputType.number),
                _text('transporterId', 'Transporter ID'),
                const SizedBox(height: 16),
                Text('Documenten', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final doc in onboardingDocs) _photoRow(doc),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppColors.bordeaux)),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'Opslaan…' : 'Opslaan in onboarding'),
                ),
              ],
            ),
    );
  }

  Widget _text(String key, String label, {TextInputType? keyboard, String? suffix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: _fields[key],
        keyboardType: keyboard,
        enabled: !_saving,
        decoration: InputDecoration(labelText: label, suffixText: suffix),
      ),
    );
  }

  Widget _dateButton(String label, String value, VoidCallback onPick) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: OutlinedButton(
        onPressed: _saving ? null : onPick,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(value.isEmpty ? label : '$label: $value'),
        ),
      ),
    );
  }

  Widget _photoRow(OnboardingDoc doc) {
    final hasFile = _photos.containsKey(doc.key);
    final hasUrl = (_urls[doc.key] ?? '').isNotEmpty;
    final done = hasFile || hasUrl;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(doc.label),
      subtitle: Text(done ? (hasFile ? 'Nieuwe foto klaar' : 'Al geüpload') : 'Nog geen foto'),
      trailing: IconButton(
        onPressed: _saving ? null : () => _capture(doc.key),
        icon: Icon(done ? Icons.check_circle : Icons.photo_camera_outlined),
        color: done ? AppColors.bordeaux : AppColors.muted,
      ),
    );
  }
}
