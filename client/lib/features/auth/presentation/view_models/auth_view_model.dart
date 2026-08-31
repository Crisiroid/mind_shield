import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/services/token_service.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/repositories/auth_repository.dart';

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

  void checkAuthStatus() {
    _isAuthenticated = TokenService.isLoggedIn();
    notifyListeners();
  }

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

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authRepository.logout();
    await TokenService.clearTokens();

    _isAuthenticated = false;
    _currentUser = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

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

  Future<void> _saveTokens(AuthTokenData tokenData) async {
    await TokenService.saveTokens(
      accessToken: tokenData.accessToken,
      refreshToken: tokenData.refreshToken,
      userId: tokenData.user.id,
    );

    if (tokenData.user.lastLogin != null) {
      await TokenService.setLastLogin(
        tokenData.user.lastLogin!.toIso8601String(),
      );
    }

    // Agreement acceptance is permanent: never downgrade a locally-accepted
    // agreement back to false just because the server default is false. If the
    // user already accepted locally but the server has not recorded it yet,
    // persist it to the backend so it survives reinstalls and other devices.
    final accepted =
        tokenData.user.agreementAccepted || TokenService.isAgreementAccepted();
    await TokenService.setAgreementAccepted(accepted);
    if (accepted && !tokenData.user.agreementAccepted) {
      try {
        await _authRepository.acceptAgreement();
      } catch (_) {}
    }

    if (tokenData.user.registrationDate != null) {
      await TokenService.setRegistrationDate(
        tokenData.user.registrationDate!.toIso8601String(),
      );
    }

    await TokenService.setNeedsInitialSync(true);

    _sendDeviceInfo();
  }

  void _sendDeviceInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final androidVersion = Platform.operatingSystemVersion;
      final appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

      await _authRepository.updateLoginInfo(
        androidVersion: androidVersion,
        appVersion: appVersion,
      );
    } catch (_) {}
  }
}
