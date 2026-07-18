import 'package:shared_preferences/shared_preferences.dart';

/// Secure token storage service using SharedPreferences.
///
/// Manages access/refresh tokens and user session persistence.
/// Follows the Single Responsibility Principle — only handles
/// token read/write/clear operations.
class TokenService {
  TokenService._();

  static SharedPreferences? _prefs;

  // ─── Storage Keys ────────────────────────────────────────────
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyAgreementAccepted = 'agreement_accepted';
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyLastLogin = 'last_login';
  static const String _keyRegistrationDate = 'registration_date';
  static const String _keyNeedsInitialSync = 'needs_initial_sync';

  /// Initialize SharedPreferences. Call once at app startup.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save authentication tokens after successful login/register.
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    await _prefs?.setString(_keyAccessToken, accessToken);
    await _prefs?.setString(_keyRefreshToken, refreshToken);
    await _prefs?.setString(_keyUserId, userId);
  }

  /// Retrieve the stored access token.
  static String? getAccessToken() => _prefs?.getString(_keyAccessToken);

  /// Retrieve the stored refresh token.
  static String? getRefreshToken() => _prefs?.getString(_keyRefreshToken);

  /// Retrieve the stored user ID.
  static String? getUserId() => _prefs?.getString(_keyUserId);

  /// Check if user has a valid session (access token exists).
  static bool isLoggedIn() {
    final token = _prefs?.getString(_keyAccessToken);
    return token != null && token.isNotEmpty;
  }

  /// Clear all stored tokens — called on logout.
  static Future<void> clearTokens() async {
    await _prefs?.remove(_keyAccessToken);
    await _prefs?.remove(_keyRefreshToken);
    await _prefs?.remove(_keyUserId);
    // Force a fresh server→client pull on the next login (possibly a new
    // device/account), so the local mirror is rebuilt from the server.
    await _prefs?.setBool(_keyNeedsInitialSync, true);
  }

  /// Update only the access token (e.g., after refresh).
  static Future<void> updateAccessToken(String newAccessToken) async {
    await _prefs?.setString(_keyAccessToken, newAccessToken);
  }

  /// Update both tokens (e.g., after token refresh).
  static Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _prefs?.setString(_keyAccessToken, accessToken);
    await _prefs?.setString(_keyRefreshToken, refreshToken);
  }

  // ─── Onboarding State ──────────────────────────────────────────

  /// Check if the user has accepted the digital therapy agreement.
  static bool isAgreementAccepted() =>
      _prefs?.getBool(_keyAgreementAccepted) ?? false;

  /// Persist agreement acceptance state.
  static Future<void> setAgreementAccepted(bool value) async {
    await _prefs?.setBool(_keyAgreementAccepted, value);
  }

  /// Check if the 56-day onboarding roadmap has been completed.
  static bool isOnboardingComplete() =>
      _prefs?.getBool(_keyOnboardingComplete) ?? false;

  /// Persist onboarding completion state.
  static Future<void> setOnboardingComplete(bool value) async {
    await _prefs?.setBool(_keyOnboardingComplete, value);
  }

  /// Retrieve the last login timestamp (Persian calendar string).
  static String? getLastLogin() => _prefs?.getString(_keyLastLogin);

  /// Store the last login timestamp.
  static Future<void> setLastLogin(String value) async {
    await _prefs?.setString(_keyLastLogin, value);
  }

  // ─── Week Tracking ─────────────────────────────────────────────

  /// Retrieve the stored registration date (ISO-8601 string).
  static String? getRegistrationDate() =>
      _prefs?.getString(_keyRegistrationDate);

  /// Store the registration date for offline week calculation.
  static Future<void> setRegistrationDate(String value) async {
    await _prefs?.setString(_keyRegistrationDate, value);
  }

  // ─── Initial Sync State ────────────────────────────────────────

  /// Whether a full server→client pull is required before showing home.
  ///
  /// Set to `true` on login/register (and on logout) and back to `false`
  /// once a complete pull has populated the local mirror. This is what makes
  /// a fresh install / different device rebuild its data on first login.
  static bool needsInitialSync() =>
      _prefs?.getBool(_keyNeedsInitialSync) ?? false;

  /// Persist the initial-sync requirement flag.
  static Future<void> setNeedsInitialSync(bool value) async {
    await _prefs?.setBool(_keyNeedsInitialSync, value);
  }
}
