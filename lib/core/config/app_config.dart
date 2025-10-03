class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://b7952588dcff.ngrok-free.app',
  );

  static const bool enableFcm = bool.fromEnvironment(
    'ENABLE_FCM',
    defaultValue: false,
  );
}


