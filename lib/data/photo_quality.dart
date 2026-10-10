import 'dart:io';
import 'dart:ui' as ui;

/// A bus is done for the day once this many usable photos exist.
const int minFleetPhotos = 5;

/// Longest side, in pixels, before a photo counts as good enough.
const int minGoodPhotoEdge = 1000;

class EncodedPhotoSize {
  const EncodedPhotoSize({required this.width, required this.height});

  final int width;
  final int height;

  int get longestEdge => width > height ? width : height;
}

Future<EncodedPhotoSize?> readEncodedPhotoSize(File file) async {
  try {
    final bytes = await file.readAsBytes();
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    final size = EncodedPhotoSize(
      width: descriptor.width,
      height: descriptor.height,
    );
    descriptor.dispose();
    buffer.dispose();
    return size;
  } catch (_) {
    return null;
  }
}

/// Whether this file is likely to count toward the daily fleet photo goal.
Future<bool> photoMeetsFleetMinimumResolution(File file) async {
  final size = await readEncodedPhotoSize(file);
  if (size != null) {
    return size.longestEdge >= minGoodPhotoEdge;
  }
  return file.lengthSync() >= 100 * 1024;
}

bool photoCountsAsGood({
  required bool qualityOk,
  required int width,
  required int height,
  required int fileSize,
}) {
  if (qualityOk) return true;
  final longest = width > height ? width : height;
  if (longest >= minGoodPhotoEdge) return true;
  if (width == 0 && height == 0 && fileSize >= 100000) return true;
  return false;
}
