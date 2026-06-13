import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:kins_fleet_drivers/core/auth/auth_provider.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';
import 'package:kins_fleet_drivers/core/l10n/locale_provider.dart';
import 'package:kins_fleet_drivers/core/utils/date_utils.dart';
import 'package:kins_fleet_drivers/features/photos/models/bus_option.dart';
import 'package:kins_fleet_drivers/features/photos/models/bus_photo.dart';
import 'package:kins_fleet_drivers/features/photos/photos_provider.dart';
import 'package:kins_fleet_drivers/features/photos/widgets/photo_gallery_tile.dart';
import 'package:kins_fleet_drivers/l10n/app_localizations.dart';
import 'package:kins_fleet_drivers/widgets/empty_state.dart';
import 'package:kins_fleet_drivers/widgets/error_banner.dart';
import 'package:kins_fleet_drivers/widgets/loading_overlay.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({super.key});

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  final _notesController = TextEditingController();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final uid = auth.user?.uid ?? '';
    final driverId = auth.user?.driverId ?? '';
    if (uid.isEmpty) return;
    await context.read<PhotosProvider>().load(driverId: driverId, uid: uid);
  }

  Future<void> _refresh() async {
    final auth = context.read<AuthProvider>();
    await context.read<PhotosProvider>().refresh(
          driverId: auth.user?.driverId ?? '',
          uid: auth.user?.uid ?? '',
        );
  }

  String _errorMessage(AppLocalizations l10n, PhotoErrorKey? key) {
    return switch (key) {
      PhotoErrorKey.loadFailed => l10n.errorLoadPhotos,
      PhotoErrorKey.imageKitNotConfigured => l10n.errorImageKitNotConfigured,
      PhotoErrorKey.fileTooLarge => l10n.errorPhotoFileTooLarge,
      PhotoErrorKey.invalidType => l10n.errorPhotoInvalidType,
      PhotoErrorKey.uploadFailed => l10n.errorPhotoUploadFailed,
      PhotoErrorKey.saveFailed => l10n.errorPhotoSaveFailed,
      PhotoErrorKey.busRequired => l10n.errorPhotoBusRequired,
      null => '',
    };
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    final auth = context.read<AuthProvider>();
    final photos = context.read<PhotosProvider>();
    final l10n = AppLocalizations.of(context);

    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 4096,
      maxHeight: 4096,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    photos.updateNotes(_notesController.text);
    final success = await photos.uploadFromFile(
      file: File(picked.path),
      uploadedBy: auth.user!.uid,
      uploadedByName: auth.driverDisplayName,
    );

    if (!mounted) return;

    if (success) {
      _notesController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.photosUploadSuccess)),
      );
    } else if (photos.errorKey != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage(l10n, photos.errorKey)),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _pickDate(PhotosProvider photos, String localeTag) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: photos.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      locale: Locale(localeTag.split('_').first),
    );
    if (picked != null) {
      photos.selectDate(picked);
    }
  }

  void _openPhotoPreview(BusPhoto photo) {
    final imageUrl =
        photo.imageUrl.isNotEmpty ? photo.imageUrl : photo.thumbnailUrl;
    if (imageUrl.isEmpty) return;

    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: Image.network(imageUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeProvider = context.watch<LocaleProvider>();
    final photos = context.watch<PhotosProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.photosTitle),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.accent,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                _UploadSection(
                  l10n: l10n,
                  localeTag: localeProvider.dateLocaleTag,
                  photos: photos,
                  notesController: _notesController,
                  onPickDate: () => _pickDate(photos, localeProvider.dateLocaleTag),
                  onCamera: photos.isUploading
                      ? null
                      : () => _pickAndUpload(ImageSource.camera),
                  onGallery: photos.isUploading
                      ? null
                      : () => _pickAndUpload(ImageSource.gallery),
                ),
                const SizedBox(height: 28),
                Text(
                  l10n.photosMyUploads,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 12),
                if (photos.hasError) ...[
                  ErrorBanner(message: l10n.errorLoadPhotos),
                  const SizedBox(height: 16),
                ],
                if (!photos.isLoading &&
                    !photos.hasError &&
                    photos.photos.isEmpty)
                  EmptyState(
                    icon: Icons.photo_library_outlined,
                    title: l10n.photosEmpty,
                    subtitle: l10n.photosEmptySubtitle,
                  )
                else
                  _PhotoGrid(
                    photos: photos.photos,
                    onTap: _openPhotoPreview,
                  ),
              ],
            ),
          ),
          if (photos.isLoading && photos.photos.isEmpty)
            LoadingOverlay(message: l10n.photosLoading),
          if (photos.isUploading)
            LoadingOverlay(
              message: l10n.photosUploading(photos.uploadPercent),
            ),
        ],
      ),
    );
  }
}

class _UploadSection extends StatelessWidget {
  const _UploadSection({
    required this.l10n,
    required this.localeTag,
    required this.photos,
    required this.notesController,
    required this.onPickDate,
    required this.onCamera,
    required this.onGallery,
  });

  final AppLocalizations l10n;
  final String localeTag;
  final PhotosProvider photos;
  final TextEditingController notesController;
  final VoidCallback onPickDate;
  final VoidCallback? onCamera;
  final VoidCallback? onGallery;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.photosSelectBus,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            _BusDropdown(
              l10n: l10n,
              photos: photos,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.photosSelectDate),
              subtitle: Text(
                AppDateUtils.formatShortDate(photos.selectedDate, localeTag),
              ),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: onPickDate,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: l10n.photosNotes,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: photos.updateNotes,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCamera,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text(l10n.photosTakePhoto),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onGallery,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(l10n.photosChooseGallery),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BusDropdown extends StatelessWidget {
  const _BusDropdown({
    required this.l10n,
    required this.photos,
  });

  final AppLocalizations l10n;
  final PhotosProvider photos;

  @override
  Widget build(BuildContext context) {
    if (photos.isLoadingBuses) {
      return const LinearProgressIndicator();
    }

    if (photos.busOptions.isEmpty) {
      return Text(
        l10n.photosSelectBusHint,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
      );
    }

    return DropdownButtonFormField<BusOption>(
      value: photos.selectedBus,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: l10n.photosSelectBusHint,
      ),
      items: _buildItems(),
      onChanged: photos.selectBus,
    );
  }

  List<DropdownMenuItem<BusOption>> _buildItems() {
    final items = <DropdownMenuItem<BusOption>>[];
    final today = photos.todayShiftBuses;
    final others = photos.otherBuses;

    if (today.isNotEmpty) {
      items.add(
        DropdownMenuItem<BusOption>(
          enabled: false,
          value: null,
          child: Text(
            l10n.photosFromTodayShifts,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
      items.addAll(
        today.map(
          (bus) => DropdownMenuItem(value: bus, child: Text(bus.label)),
        ),
      );
    }

    if (others.isNotEmpty) {
      items.add(
        DropdownMenuItem<BusOption>(
          enabled: false,
          value: null,
          child: Text(
            l10n.photosAllActiveBuses,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
      items.addAll(
        others.map(
          (bus) => DropdownMenuItem(value: bus, child: Text(bus.label)),
        ),
      );
    }

    return items;
  }
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({
    required this.photos,
    required this.onTap,
  });

  final List<BusPhoto> photos;
  final void Function(BusPhoto photo) onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: photos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final photo = photos[index];
        return PhotoGalleryTile(
          photo: photo,
          onTap: () => onTap(photo),
        );
      },
    );
  }
}
