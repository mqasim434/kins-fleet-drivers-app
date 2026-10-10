import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kins_fleet_drivers/core/auth/auth_controller.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';
import 'package:kins_fleet_drivers/core/utils/dates.dart';
import 'package:kins_fleet_drivers/core/utils/picked_image.dart';
import 'package:kins_fleet_drivers/data/fleet_repository.dart';
import 'package:kins_fleet_drivers/data/models.dart';
import 'package:kins_fleet_drivers/features/photos/widgets/picked_image_preview.dart';
import 'package:provider/provider.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key, this.initialPurpose});

  final String? initialPurpose;

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final _fleet = FleetRepository();
  final _picker = ImagePicker();
  final _notes = TextEditingController();
  final _damageDescription = TextEditingController();

  List<FleetBus> _buses = [];
  String? _busId;
  late PhotoPurpose _purpose = PhotoPurpose.byId(widget.initialPurpose ?? PhotoPurpose.inspection.id);
  String _damageType = 'other';
  String _severity = 'low';
  File? _file;
  Uint8List? _previewBytes;
  bool _loadingBuses = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _recoverLostImage();
    _loadBuses();
  }

  Future<void> _recoverLostImage() async {
    final handle = await recoverLostPick(_picker);
    if (handle == null || !mounted) return;
    setState(() {
      _file = handle.file;
      _previewBytes = handle.previewBytes;
    });
  }

  @override
  void dispose() {
    _notes.dispose();
    _damageDescription.dispose();
    super.dispose();
  }

  Future<void> _loadBuses() async {
    final session = context.read<AuthController>().session!;
    try {
      final shifts = await _fleet.fetchShifts(session.driverRecord.id);
      final today = todayIso();
      final preferred = shifts
          .where((shift) => shift.date == today && shift.busId.isNotEmpty)
          .map(FleetBus.fromShift)
          .toList();
      List<FleetBus> buses;
      try {
        buses = await _fleet.fetchActiveBuses();
      } catch (_) {
        buses = preferred;
      }
      final byId = {for (final bus in buses) bus.id: bus};
      for (final bus in preferred) {
        byId.putIfAbsent(bus.id, () => bus);
      }
      final merged = byId.values.toList()
        ..sort((a, b) => a.busNumber.compareTo(b.busNumber));
      if (!mounted) return;
      setState(() {
        _buses = merged;
        _busId = preferred.isNotEmpty ? preferred.first.id : (merged.isNotEmpty ? merged.first.id : null);
        _loadingBuses = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingBuses = false;
        _error = 'Voertuigen laden is mislukt.';
      });
    }
  }

  Future<void> _pick(ImageSource source) async {
    final handle = await pickAndPersistImage(
      _picker,
      source: source,
      imageQuality: 85,
      maxWidth: 2000.0,
    );
    if (handle == null || !mounted) return;
    setState(() {
      _file = handle.file;
      _previewBytes = handle.previewBytes;
      _error = null;
    });
  }

  void _clearPick() {
    setState(() {
      _file = null;
      _previewBytes = null;
    });
  }

  Future<void> _save() async {
    final session = context.read<AuthController>().session!;
    final file = _file;
    final bus = _buses.where((item) => item.id == _busId).firstOrNull;
    if (file == null) {
      setState(() => _error = 'Maak of kies eerst een foto.');
      return;
    }
    if (bus == null) {
      setState(() => _error = 'Kies een voertuig.');
      return;
    }
    if (_purpose.id == PhotoPurpose.damage.id && _damageDescription.text.trim().isEmpty) {
      setState(() => _error = 'Beschrijf de schade.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final photo = await _fleet.uploadPhoto(
        bus: bus,
        dateIso: todayIso(),
        purpose: _purpose,
        notes: _notes.text,
        uploadedBy: session.user.uid,
        uploadedByName: session.driverRecord.displayName,
        driverId: session.user.driverId,
        file: file,
      );
      if (_purpose.id == PhotoPurpose.damage.id) {
        await _fleet.createDamageReport(
          bus: bus,
          dateIso: todayIso(),
          driverId: session.user.driverId,
          driverName: session.driverRecord.displayName,
          departmentId: session.driverRecord.departmentId,
          reportedBy: session.user.name.isNotEmpty ? session.user.name : session.driverRecord.displayName,
          reportedByUid: session.user.uid,
          description: _damageDescription.text.trim(),
          damageType: _damageType,
          severity: _severity,
          photoId: photo.id,
          imageUrl: photo.imageUrl,
        );
      }
      if (!mounted) return;
      context.pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = FleetException.from(error).message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Foto uploaden')),
      body: _loadingBuses
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_previewBytes == null)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _saving ? null : () => _pick(ImageSource.camera),
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: const Text('Camera'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _saving ? null : () => _pick(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Galerij'),
                        ),
                      ),
                    ],
                  )
                else
                  PickedImagePreview(
                    previewBytes: _previewBytes!,
                    file: _file,
                    onRetake: _saving ? null : _clearPick,
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _buses.any((bus) => bus.id == _busId) ? _busId : null,
                  decoration: const InputDecoration(labelText: 'Voertuig'),
                  items: [
                    for (final bus in _buses)
                      DropdownMenuItem(
                        value: bus.id,
                        child: Text(
                          [bus.busNumber, bus.licensePlate].where((part) => part.isNotEmpty).join(' · '),
                        ),
                      ),
                  ],
                  onChanged: _saving ? null : (value) => setState(() => _busId = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _purpose.id,
                  decoration: const InputDecoration(labelText: 'Doel'),
                  items: [
                    for (final purpose in PhotoPurpose.all)
                      DropdownMenuItem(value: purpose.id, child: Text(purpose.label)),
                  ],
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _purpose = PhotoPurpose.byId(value ?? 'other')),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notes,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Opmerking'),
                ),
                if (_purpose.id == PhotoPurpose.damage.id) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _damageDescription,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Schadebeschrijving'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _damageType,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: const [
                      DropdownMenuItem(value: 'dent', child: Text('Deuk')),
                      DropdownMenuItem(value: 'scratch', child: Text('Kras')),
                      DropdownMenuItem(value: 'paint_damage', child: Text('Lakschade')),
                      DropdownMenuItem(value: 'bumper_damage', child: Text('Bumper')),
                      DropdownMenuItem(value: 'broken_mirror', child: Text('Spiegel')),
                      DropdownMenuItem(value: 'other', child: Text('Overig')),
                    ],
                    onChanged: _saving ? null : (value) => setState(() => _damageType = value ?? 'other'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _severity,
                    decoration: const InputDecoration(labelText: 'Ernst'),
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('Laag')),
                      DropdownMenuItem(value: 'medium', child: Text('Middel')),
                      DropdownMenuItem(value: 'high', child: Text('Hoog')),
                    ],
                    onChanged: _saving ? null : (value) => setState(() => _severity = value ?? 'low'),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppColors.bordeaux)),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'Uploaden…' : 'Opslaan'),
                ),
              ],
            ),
    );
  }
}
