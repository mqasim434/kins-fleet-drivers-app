import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

class ImageKitAuthParams {
  const ImageKitAuthParams({
    required this.token,
    required this.expire,
    required this.signature,
  });

  final String token;
  final int expire;
  final String signature;
}

ImageKitAuthParams generateImageKitAuthParams(String privateKey) {
  const uuid = Uuid();
  final token = uuid.v4();
  final expire = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 60 * 30;
  final message = '$token$expire';
  final hmac = Hmac(sha1, utf8.encode(privateKey));
  final signature = hmac.convert(utf8.encode(message)).toString();
  return ImageKitAuthParams(token: token, expire: expire, signature: signature);
}
