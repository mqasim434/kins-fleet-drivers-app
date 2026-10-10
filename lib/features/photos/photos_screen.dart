import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kins_fleet_drivers/core/auth/auth_controller.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';
import 'package:kins_fleet_drivers/core/utils/dates.dart';
import 'package:kins_fleet_drivers/data/fleet_repository.dart';
import 'package:kins_fleet_drivers/data/models.dart';
import 'package:provider/provider.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({super.key});

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  final _fleet = FleetRepository();
  late Future<List<BusPhotoRecord>> _photos;

  @override
  void initState() {
    super.initState();
    _photos = _load();
  }

  Future<List<BusPhotoRecord>> _load() {
    final uid = context.read<AuthController>().session!.user.uid;
    return _fleet.fetchMyPhotos(uid);
  }

  Future<void> _reload() async {
    setState(() => _photos = _load());
    await _photos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Foto's")),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.bordeaux,
        foregroundColor: Colors.white,
        onPressed: () async {
          final saved = await context.push<bool>('/photos/new');
          if (saved == true) _reload();
        },
        icon: const Icon(Icons.photo_camera_outlined),
        label: const Text('Nieuwe foto'),
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<BusPhotoRecord>>(
          future: _photos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final photos = snapshot.data ?? [];
            if (photos.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  Text("Nog geen foto's. Maak een controle-, schade- of staatfoto. De wagenparkbeheerder ziet die bij het voertuig."),
                ],
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.78,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final photo = photos[index];
                final purpose = photo.purpose.isEmpty
                    ? ''
                    : PhotoPurpose.byId(photo.purpose).label;
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
                          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              [photo.busNumber, photo.licensePlate].where((part) => part.isNotEmpty).join(' · '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              [purpose, formatIsoDate(photo.date)].where((part) => part.isNotEmpty).join(' · '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.muted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
