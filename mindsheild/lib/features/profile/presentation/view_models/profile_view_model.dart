import 'package:flutter/material.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../../data/repositories/profile_repository.dart';

/// ViewModel for the profile screen.
///
/// Manages profile loading, update, and password change flows.
/// Follows the same ChangeNotifier pattern as all other view models.
class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileViewModel(this._repository);

  // ─── State ────────────────────────────────────────────────────
  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _error;
  String? get error => _error;

  // ─── Load Profile ─────────────────────────────────────────────

  /// Fetch the current user's profile from the server.
  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.getProfile();
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (user) {
        _user = user;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ─── Update Profile ───────────────────────────────────────────

  /// Update profile settings (cloud sync, DND, etc.).
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    bool success = false;
    final result = await _repository.updateProfile(data);
    result.fold(
      (failure) {
        _error = failure.message;
        success = false;
      },
      (user) {
        _user = user;
        success = true;
      },
    );

    _isSaving = false;
    notifyListeners();
    return success;
  }

  // ─── Change Password ──────────────────────────────────────────

  /// Change the user's password.
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    bool success = false;
    final result = await _repository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
    result.fold(
      (failure) {
        _error = failure.message;
        success = false;
      },
      (_) {
        success = true;
      },
    );

    _isSaving = false;
    notifyListeners();
    return success;
  }

  /// Clear any displayed error.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
