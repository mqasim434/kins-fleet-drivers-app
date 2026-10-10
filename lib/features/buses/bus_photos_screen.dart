import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kins_fleet_drivers/core/auth/auth_controller.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';
import 'package:kins_fleet_drivers/core/utils/dates.dart';
import 'package:kins_fleet_drivers/core/utils/picked_image.dart';
import 'package:kins_fleet_drivers/data/fleet_repository.dart';
import 'package:kins_fleet_drivers/data/models.dart';
import 'package:kins_fleet_drivers/data/photo_quality.dart';
import 'package:kins_fleet_drivers/features/photos/widgets/picked_image_preview.dart';
import 'package:provider/provider.dart';

class BusPhotosScreen extends StatefulWidget {
  const BusPhotosScreen({super.key, required this.busId});

  final String busId;

  @override
  State<BusPhotosScreen> createState() => _BusPhotosScreenState();
}

class _BusPhotosScreenState extends State<BusPhotosScreen> {
  final _fleet = FleetRepository();
  final _picker = ImagePicker();
  late final Stream<List<BusPhotoRecord>> _photoStream =
      _fleet.watchPhotosForBusAndDate(busId: widget.busId, dateIso: todayIso());
  bool _saving = false;
  String _uploadStatus = '';
  String? _error;
  String? _qualityHint;
  String _busTitle = 'Bus';
  File? _pendingFile;
  Uint8List? _pendingPreview;
  bool _pendingCountsForGoal = true;

  @override
  void initState() {
    super.initState();
    _recoverLostImage();
    _loadBusTitle();
  }

  Future<void> _loadBusTitle() async {
    final bus = await _fleet.fetchBus(widget.busId);
    if (bus != null && mounted) {
      setState(() => _busTitle = bus.label);
    }
  }

  Future<void> _recoverLostImage() async {
    final handle = await recoverLostPick(_picker);
    if (handle == null || !mounted) return;
    await _applyPendingImage(handle.file, handle.previewBytes);
  }

  Future<void> _applyPendingImage(File file, Uint8List previewBytes) async {
    final counts = await photoMeetsFleetMinimumResolution(file);
    if (!mounted) return;
    setState(() {
      _pendingFile = file;
      _pendingPreview = previewBytes;
      _pendingCountsForGoal = counts;
      _error = null;
      _qualityHint = counts
          ? null
          : 'Deze foto is kleiner dan $minGoodPhotoEdge px en telt niet mee voor de 5 dagfoto\'s. '
              'Je kunt hem wel uploaden; maak desnoods een foto dichterbij.';
    });
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final handle = await pickAndPersistImage(
        _picker,
        source: source,
        imageQuality: 85,
        maxWidth: 2000.0,
      );
      if (handle == null || !mounted) return;
      await _applyPendingImage(handle.file, handle.previewBytes);
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.code == 'no_available_camera'
            ? 'Geen camera beschikbaar. Kies een foto uit de galerij.'
            : 'Foto kiezen mislukt. Probeer het opnieuw.';
      });
    }
  }

  void _clearPending() {
    setState(() {
      _pendingFile = null;
      _pendingPreview = null;
      _qualityHint = null;
      _pendingCountsForGoal = true;
    });
  }

  Future<void> _uploadPending() async {
    final file = _pendingFile;
    if (file == null) {
      setState(() => _error = 'Maak of kies eerst een foto.');
      return;
    }

    final session = context.read<AuthController>().session!;
    final bus = await _fleet.fetchBus(widget.busId);
    if (!mounted) return;
    if (bus == null) {
      setState(() => _error = 'Deze bus is niet gevonden.');
      return;
    }

    setState(() {
      _saving = true;
      _uploadStatus = 'Foto uploaden…';
      _error = null;
    });
    try {
      await _fleet.uploadPhoto(
        bus: bus,
        dateIso: todayIso(),
        purpose: PhotoPurpose.inspection,
        notes: 'Wagenparkfoto',
        uploadedBy: session.user.uid,
        uploadedByName: session.driverRecord.displayName,
        driverId: session.user.driverId,
        file: file,
        onProgress: (phase) {
          if (!mounted) return;
          setState(() {
            _uploadStatus = phase == 'firestore'
                ? 'Opslaan in dossier…'
                : 'Foto uploaden…';
          });
        },
      );
      if (!mounted) return;
      setState(() {
        _pendingFile = null;
        _pendingPreview = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _pendingCountsForGoal
                ? 'Foto opgeslagen.'
                : 'Foto opgeslagen. Telt niet mee voor de 5 dagfoto\'s (te klein).',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = FleetException.from(error).message);
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
          _uploadStatus = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Busfoto\'s')),
      body: StreamBuilder<List<BusPhotoRecord>>(
        stream: _photoStream,
        builder: (context, snapshot) {
          final photos = snapshot.data ?? [];
          final good = photos.where((photo) => photo.countsAsGood).length;
          final done = good >= minFleetPhotos;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(_busTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                done ? '$good foto\'s — voltooid' : '$good van $minFleetPhotos foto\'s vandaag',
                style: TextStyle(
                  color: done ? const Color(0xFF166534) : AppColors.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'De foto\'s komen ook in Foto\'s in het beheerdashboard.',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              if (_pendingPreview != null) ...[
                PickedImagePreview(
                  previewBytes: _pendingPreview!,
                  file: _pendingFile,
                  onRetake: _saving ? null : _clearPending,
                ),
                const SizedBox(height: 12),
                if (_qualityHint != null) ...[
                  Text(
                    _qualityHint!,
                    style: const TextStyle(color: Color(0xFF92400E), fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                ],
                FilledButton(
                  onPressed: _saving ? null : _uploadPending,
                  child: Text(_saving ? 'Uploaden…' : 'Foto uploaden'),
                ),
                const SizedBox(height: 16),
              ],
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
              ),
              if (_saving) ...[
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      if (_uploadStatus.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(_uploadStatus, style: const TextStyle(color: AppColors.muted)),
                      ],
                    ],
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppColors.bordeaux)),
              ],
              const SizedBox(height: 16),
              if (photos.isEmpty)
                const Text('Nog geen foto\'s van vandaag voor deze bus.')
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Image.network(
                              photo.thumbnailUrl.isNotEmpty ? photo.thumbnailUrl : photo.imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Center(child: Icon(Icons.broken_image_outlined)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              photo.countsAsGood
                                  ? (photo.uploadedByName.isEmpty ? 'Foto' : photo.uploadedByName)
                                  : 'Te klein',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: photo.countsAsGood ? AppColors.ink : AppColors.bordeaux,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
