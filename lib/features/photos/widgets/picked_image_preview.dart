import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';

class PickedImagePreview extends StatelessWidget {
  const PickedImagePreview({
    super.key,
    required this.previewBytes,
    this.file,
    this.height = 220,
    this.onRetake,
  });

  final Uint8List previewBytes;
  final File? file;
  final double height;
  final VoidCallback? onRetake;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.memory(
            previewBytes,
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              if (file != null && file!.existsSync()) {
                return Image.file(
                  file!,
                  height: height,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallback(height),
                );
              }
              return _fallback(height);
            },
          ),
        ),
        if (onRetake != null)
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
              child: IconButton(
                onPressed: onRetake,
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: 'Andere foto',
              ),
            ),
          ),
      ],
    );
  }

  Widget _fallback(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: AppColors.line,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image_outlined, size: 48),
    );
  }
}
