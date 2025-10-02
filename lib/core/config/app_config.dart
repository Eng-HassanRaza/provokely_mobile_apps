class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static const bool enableFcm = bool.fromEnvironment(
    'ENABLE_FCM',
    defaultValue: false,
  );
}


