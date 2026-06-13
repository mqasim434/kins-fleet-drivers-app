class ImageKitUploadResult {
  const ImageKitUploadResult({
    required this.fileId,
    required this.url,
    required this.thumbnailUrl,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.width,
    required this.height,
  });

  final String fileId;
  final String url;
  final String thumbnailUrl;
  final String fileName;
  final String filePath;
  final int fileSize;
  final int width;
  final int height;

  factory ImageKitUploadResult.fromJson(Map<String, dynamic> json) {
    return ImageKitUploadResult(
      fileId: json['fileId'] as String? ?? '',
      url: json['url'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ??
          json['url'] as String? ??
          '',
      fileName: json['name'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
      fileSize: (json['size'] as num?)?.toInt() ?? 0,
      width: (json['width'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num?)?.toInt() ?? 0,
    );
  }
}

class ImageKitException implements Exception {
  ImageKitException(this.message);

  final String message;

  @override
  String toString() => message;
}
