import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/dialog_service.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../data/models/mental_must_model.dart';
import '../../data/repositories/mental_must_repository.dart';

/// Mental Must ViewModel — manages backpack state, creation, and release.
///
/// Follows the Single Responsibility Principle: only handles mental
/// musts backpack logic.
class MentalMustViewModel extends ChangeNotifier {
  final MentalMustRepository _repository;

  MentalMustViewModel(this._repository);

  bool _isSaving = false;
  bool _isLoading = false;
  String? _errorMessage;
  String _mustText = '';
  List<MentalMustModel> _musts = [];

  bool get isSaving => _isSaving;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get mustText => _mustText;
  List<MentalMustModel> get musts => _musts;

  /// Get active (non-released) musts.
  List<MentalMustModel> get activeMusts =>
      _musts.where((m) => !m.isReleased).toList();

  /// Get released musts.
  List<MentalMustModel> get releasedMusts =>
      _musts.where((m) => m.isReleased).toList();

  /// Get the current day number from registration date.
  int get _currentDayNumber {
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    return WeekCalculator.currentDayNumber(registrationDate);
  }

  /// Initialize by loading musts.
  Future<void> init() async {
    await loadMusts();
  }

  /// Load musts from API.
  Future<void> loadMusts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.listMentalMusts();

    result.fold(
      (failure) {
        _musts = [];
      },
      (data) {
        _musts = data;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Update the must text input.
  void setMustText(String value) {
    _mustText = value;
    notifyListeners();
  }

  /// Submit a new mental must.
  Future<bool> submitMust() async {
    if (_mustText.trim().isEmpty) {
      DialogService.showError(
        title: AppStrings.error,
        message: AppStrings.enterMustText,
      );
      return false;
    }

    _isSaving = true;
    notifyListeners();

    final must = MentalMustModel(
      id: '',
      userId: '',
      mustText: _mustText.trim(),
      createdDate: DateTime.now().toIso8601String(),
      dayNumber: _currentDayNumber,
    );

    final result = await _repository.createMentalMust(must: must);

    bool success = false;

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        DialogService.showError(
          title: AppStrings.error,
          message: failure.message,
        );
      },
      (saved) {
        _musts.insert(0, saved);
        _mustText = '';
        DialogService.showSuccess(
          title: AppStrings.success,
          message: AppStrings.mustAdded,
        );
        success = true;
      },
    );

    _isSaving = false;
    notifyListeners();
    return success;
  }

  /// Release a mental must (let it go).
  Future<bool> releaseMust(String id) async {
    final result = await _repository.updateMentalMust(
      id: id,
      data: {'is_released': true},
    );

    bool success = false;

    result.fold(
      (failure) {
        DialogService.showError(
          title: AppStrings.error,
          message: failure.message,
        );
      },
      (updated) {
        final index = _musts.indexWhere((m) => m.id == id);
        if (index != -1) {
          _musts[index] = updated;
        }
        DialogService.showSuccess(
          title: AppStrings.success,
          message: AppStrings.mustReleased,
        );
        success = true;
      },
    );

    notifyListeners();
    return success;
  }
}
