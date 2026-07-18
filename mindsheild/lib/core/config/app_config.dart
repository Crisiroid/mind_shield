/// Application-wide configuration constants.
///
/// Centralizes environment-specific settings so the rest of the app
/// doesn't scatter conditional logic.
class AppConfig {
  AppConfig._();

  // ─── Environment ────────────────────────────────────────────
  static const bool isDebug = true; // Set to false for production

  // ─── Sync ───────────────────────────────────────────────────
  static const int syncRetryDelaySeconds = 30;
  static const int maxSyncRetries = 3;

  // ─── Cache ──────────────────────────────────────────────────
  static const int cacheExpiryHours = 24;
}
