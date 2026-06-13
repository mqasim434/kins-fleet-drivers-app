import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:kins_fleet_drivers/core/config/app_config.dart';
import 'package:kins_fleet_drivers/core/imagekit/imagekit_auth.dart';
import 'package:kins_fleet_drivers/core/imagekit/imagekit_config.dart';
import 'package:kins_fleet_drivers/core/imagekit/imagekit_models.dart';
import 'package:mime/mime.dart';

class ImageKitClient {
  ImageKitClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  void validateFile(File file) {
    if (!ImageKitConfig.isUploadReady) {
      throw ImageKitException('ImageKit not configured');
    }

    final length = file.lengthSync();
    if (length > ImageKitConfig.maxFileSizeBytes) {
      throw ImageKitException('file_too_large');
    }

    final mimeType = lookupMimeType(file.path)?.toLowerCase();
    final extension = file.path.split('.').last.toLowerCase();
    final mimeAllowed =
        mimeType != null && ImageKitConfig.allowedMimeTypes.contains(mimeType);
    final extAllowed = ImageKitConfig.allowedExtensions.contains(extension);

    if (!mimeAllowed && !extAllowed) {
      throw ImageKitException('invalid_type');
    }
  }

  Future<ImageKitUploadResult> uploadFile({
    required File file,
    required String folder,
    String? fileName,
    void Function(int percent)? onProgress,
  }) async {
    validateFile(file);

    final auth = generateImageKitAuthParams(AppConfig.imageKitPrivateKey);
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ImageKitConfig.uploadUrl),
    );

    final resolvedName = fileName ?? file.uri.pathSegments.last;
    request.fields.addAll({
      'fileName': resolvedName,
      'publicKey': AppConfig.imageKitPublicKey,
      'signature': auth.signature,
      'expire': auth.expire.toString(),
      'token': auth.token,
      'folder': folder,
    });

    request.files.add(
      await http.MultipartFile.fromPath('file', file.path, filename: resolvedName),
    );

    onProgress?.call(10);

    final streamedResponse = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    onProgress?.call(90);

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw ImageKitException('invalid_response');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ImageKitException(
        body['message'] as String? ?? 'upload_failed',
      );
    }

    onProgress?.call(100);
    return ImageKitUploadResult.fromJson(body);
  }

  void dispose() {
    _httpClient.close();
  }
}
