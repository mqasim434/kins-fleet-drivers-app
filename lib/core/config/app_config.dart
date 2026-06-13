/// Runtime config from `--dart-define-from-file=.env.json`.
abstract final class AppConfig {
  static const imageKitPublicKey = String.fromEnvironment('IMAGEKIT_PUBLIC_KEY');
  static const imageKitUrlEndpoint = String.fromEnvironment(
    'IMAGEKIT_URL_ENDPOINT',
    defaultValue: 'https://ik.imagekit.io/your_id',
  );
  static const imageKitPrivateKey = String.fromEnvironment(
    'IMAGEKIT_PRIVATE_KEY',
  );
}
