import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  TokenService._();

  static SharedPreferences? _prefs;

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyAgreementAccepted = 'agreement_accepted';
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyLastLogin = 'last_login';
  static const String _keyRegistrationDate = 'registration_date';
  static const String _keyNeedsInitialSync = 'needs_initial_sync';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    await _prefs?.setString(_keyAccessToken, accessToken);
    await _prefs?.setString(_keyRefreshToken, refreshToken);
    await _prefs?.setString(_keyUserId, userId);
  }

  static String? getAccessToken() => _prefs?.getString(_keyAccessToken);

  static String? getRefreshToken() => _prefs?.getString(_keyRefreshToken);

  static String? getUserId() => _prefs?.getString(_keyUserId);

  static bool isLoggedIn() {
    final token = _prefs?.getString(_keyAccessToken);
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearTokens() async {
    await _prefs?.remove(_keyAccessToken);
    await _prefs?.remove(_keyRefreshToken);
    await _prefs?.remove(_keyUserId);
    await _prefs?.setBool(_keyNeedsInitialSync, true);
  }

  static Future<void> updateAccessToken(String newAccessToken) async {
    await _prefs?.setString(_keyAccessToken, newAccessToken);
  }

  static Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _prefs?.setString(_keyAccessToken, accessToken);
    await _prefs?.setString(_keyRefreshToken, refreshToken);
  }

  static bool isAgreementAccepted() =>
      _prefs?.getBool(_keyAgreementAccepted) ?? false;

  static Future<void> setAgreementAccepted(bool value) async {
    await _prefs?.setBool(_keyAgreementAccepted, value);
  }

  static bool isOnboardingComplete() =>
      _prefs?.getBool(_keyOnboardingComplete) ?? false;

  static Future<void> setOnboardingComplete(bool value) async {
    await _prefs?.setBool(_keyOnboardingComplete, value);
  }

  static String? getLastLogin() => _prefs?.getString(_keyLastLogin);

  static Future<void> setLastLogin(String value) async {
    await _prefs?.setString(_keyLastLogin, value);
  }

  static String? getRegistrationDate() =>
      _prefs?.getString(_keyRegistrationDate);

  static Future<void> setRegistrationDate(String value) async {
    await _prefs?.setString(_keyRegistrationDate, value);
  }

  static bool needsInitialSync() =>
      _prefs?.getBool(_keyNeedsInitialSync) ?? false;

  static Future<void> setNeedsInitialSync(bool value) async {
    await _prefs?.setBool(_keyNeedsInitialSync, value);
  }
}
