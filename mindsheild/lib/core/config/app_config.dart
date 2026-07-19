class AppConfig {
  AppConfig._();

  static const bool isDebug = true;

  static const int syncRetryDelaySeconds = 30;
  static const int maxSyncRetries = 3;

  static const int cacheExpiryHours = 24;
}
