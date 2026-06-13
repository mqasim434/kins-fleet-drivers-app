import 'package:flutter/material.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';
import 'package:kins_fleet_drivers/features/photos/models/bus_photo.dart';

class PhotoGalleryTile extends StatelessWidget {
  const PhotoGalleryTile({
    super.key,
    required this.photo,
    this.onTap,
  });

  final BusPhoto photo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        photo.thumbnailUrl.isNotEmpty ? photo.thumbnailUrl : photo.imageUrl;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            else
              _placeholder(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.72),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  '${photo.busNumber} · ${photo.date}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return ColoredBox(
      color: AppColors.border,
      child: const Icon(Icons.broken_image_outlined, color: AppColors.textSecondary),
    );
  }
}
