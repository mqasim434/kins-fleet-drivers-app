import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class PickedImageHandle {
  const PickedImageHandle({
    required this.file,
    required this.previewBytes,
  });

  final File file;
  final Uint8List previewBytes;
}

Future<PickedImageHandle?> pickAndPersistImage(
  ImagePicker picker, {
  required ImageSource source,
  int imageQuality = 85,
  double? maxWidth,
}) async {
  final shot = await picker.pickImage(
    source: source,
    imageQuality: imageQuality,
    maxWidth: maxWidth,
    requestFullMetadata: false,
  );
  if (shot != null) {
    return persistXFile(shot);
  }
  return recoverLostPick(picker);
}

Future<PickedImageHandle?> persistXFile(XFile shot) async {
  final bytes = await shot.readAsBytes();
  if (bytes.isEmpty) return null;

  final extension = _safeExtension(shot.path, shot.mimeType);
  final dir = await getTemporaryDirectory();
  final file = File(
    '${dir.path}/kins_pick_${DateTime.now().millisecondsSinceEpoch}.$extension',
  );
  await file.writeAsBytes(bytes, flush: true);
  return PickedImageHandle(file: file, previewBytes: bytes);
}

Future<PickedImageHandle?> recoverLostPick(ImagePicker picker) async {
  final response = await picker.retrieveLostData();
  if (response.isEmpty || response.file == null) return null;
  if (response.type != RetrieveType.image) return null;
  return persistXFile(response.file!);
}

String _safeExtension(String path, String? mimeType) {
  final fromPath = path.split('.').last.toLowerCase();
  if (fromPath.length <= 5 &&
      {'jpg', 'jpeg', 'png', 'webp', 'heic', 'heif'}.contains(fromPath)) {
    return fromPath == 'jpeg' ? 'jpg' : fromPath;
  }
  return switch (mimeType) {
    'image/png' => 'png',
    'image/webp' => 'webp',
    'image/heic' || 'image/heif' => 'heic',
    _ => 'jpg',
  };
}
