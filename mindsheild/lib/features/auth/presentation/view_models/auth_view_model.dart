import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/services/token_service.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/repositories/auth_repository.dart';

/// Auth ViewModel — manages authentication state and operations.
///
/// Follows the Single Responsibility Principle: only handles auth logic.
/// UI observes this provider and reacts to state changes.
/// Uses dependency injection for the repository (DIP).
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository);

  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  UserModel? get currentUser => _currentUser;

  /// Check if user is already logged in (from stored tokens).
  void checkAuthStatus() {
    _isAuthenticated = TokenService.isLoggedIn();
    notifyListeners();
  }

  /// Login with phone number and password.
  Future<void> login({
    required String phoneNumber,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.login(
      phoneNumber: phoneNumber,
      password: password,
    );

    await result.fold(
      (failure) async {
        _errorMessage = failure.message;
        _isAuthenticated = false;
      },
      (tokenData) async {
        _isAuthenticated = true;
        _currentUser = tokenData.user;
        await _saveTokens(tokenData);
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Register a new user with phone number and password.
  Future<void> register({
    required String phoneNumber,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.register(
      phoneNumber: phoneNumber,
      password: password,
    );

    await result.fold(
      (failure) async {
        _errorMessage = failure.message;
        _isAuthenticated = false;
      },
      (tokenData) async {
        _isAuthenticated = true;
        _currentUser = tokenData.user;
        await _saveTokens(tokenData);
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Logout the current user and clear stored tokens.
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    // Attempt server logout (best-effort, ignore errors)
    await _authRepository.logout();
    await TokenService.clearTokens();

    _isAuthenticated = false;
    _currentUser = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Accept the digital therapy agreement on the server.
  Future<bool> acceptAgreement() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.acceptAgreement();
    bool success = false;

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        success = false;
      },
      (_) {
        success = true;
      },
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }

  /// Persist tokens after successful auth.
  Future<void> _saveTokens(AuthTokenData tokenData) async {
    await TokenService.saveTokens(
      accessToken: tokenData.accessToken,
      refreshToken: tokenData.refreshToken,
      userId: tokenData.user.id,
    );

    // Store last login timestamp (raw ISO-8601) for splash screen display.
    // The presentation layer converts it to Shamsi at render time.
    if (tokenData.user.lastLogin != null) {
      await TokenService.setLastLogin(
        tokenData.user.lastLogin!.toIso8601String(),
      );
    }

    // Store agreement status
    await TokenService.setAgreementAccepted(tokenData.user.agreementAccepted);

    // Store registration date for offline week/day calculation
    if (tokenData.user.registrationDate != null) {
      await TokenService.setRegistrationDate(
        tokenData.user.registrationDate!.toIso8601String(),
      );
    }

    // A fresh authentication (possibly on a new device) should rebuild the
    // local mirror from the server on first entry — flag the initial sync.
    await TokenService.setNeedsInitialSync(true);

    // Send device/app version info to the server (best-effort, fire-and-forget)
    _sendDeviceInfo();
  }

  /// Send Android version and app version to the backend so the profile
  /// can display them. Errors are silently ignored.
  void _sendDeviceInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final androidVersion = Platform.operatingSystemVersion;
      final appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

      // Best-effort: ignore the result
      await _authRepository.updateLoginInfo(
        androidVersion: androidVersion,
        appVersion: appVersion,
      );
    } catch (_) {
      // Silently ignore — device info is non-critical
    }
  }
}
