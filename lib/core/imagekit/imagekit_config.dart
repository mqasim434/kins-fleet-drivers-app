import 'package:kins_fleet_drivers/core/config/app_config.dart';

abstract final class ImageKitConfig {
  static const uploadUrl = 'https://upload.imagekit.io/api/v1/files/upload';
  static const maxFileSizeBytes = 10 * 1024 * 1024;

  static const allowedMimeTypes = {
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/webp',
    'image/heic',
    'image/heif',
  };

  static const allowedExtensions = {
    'jpg',
    'jpeg',
    'png',
    'webp',
    'heic',
    'heif',
  };

  static bool get isUploadReady =>
      AppConfig.imageKitPublicKey.isNotEmpty &&
      AppConfig.imageKitPrivateKey.isNotEmpty;

  static String folderForBus(String busId, String dateIso) =>
      '/kins-fleet/buses/$busId/$dateIso';
}
