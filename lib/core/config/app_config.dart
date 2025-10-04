class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://provokely.com',
  );

  static const bool enableFcm = bool.fromEnvironment(
    'ENABLE_FCM',
    defaultValue: false,
  );
}


