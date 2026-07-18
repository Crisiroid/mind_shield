import 'package:flutter/material.dart';
import '../../../../core/presentation/submission_flow.dart';
import '../../../../core/services/dialog_service.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../../../core/services/token_service.dart';
import '../../data/models/stress_event_model.dart';
import '../../data/repositories/stress_repository.dart';

/// Stress Registration ViewModel — manages stress registration screen state.
///
/// Follows the Single Responsibility Principle: only handles stress
/// event registration logic.
class StressViewModel extends ChangeNotifier with SubmissionFlow {
  final StressRepository _repository;

  StressViewModel(this._repository);

  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedSituation;
  int _intensityLevel = 5;
  String _description = '';
  List<StressEventModel> _history = [];

  /// Backwards-compatible alias so screens can keep binding to `isSaving`.
  bool get isSaving => isSubmitting;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedSituation => _selectedSituation;
  int get intensityLevel => _intensityLevel;
  String get description => _description;
  List<StressEventModel> get history => _history;

  /// Get the current day number from registration date.
  int get _currentDayNumber {
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    return WeekCalculator.currentDayNumber(registrationDate);
  }

  /// Initialize by loading history.
  Future<void> init() async {
    await loadHistory();
  }

  /// Load stress event history from API.
  Future<void> loadHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.listStressEvents();

    result.fold(
      (failure) {
        // Keep any previously loaded history so a failed refresh never blanks
        // the list; only surface the error message.
        _errorMessage = failure.message;
      },
      (data) {
        _history = data;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Select a stress situation type.
  void selectSituation(String situation) {
    _selectedSituation = situation;
    notifyListeners();
  }

  /// Update intensity level.
  void setIntensityLevel(int value) {
    _intensityLevel = value;
    notifyListeners();
  }

  /// Update description.
  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  /// Reset form to defaults.
  void resetForm() {
    _selectedSituation = null;
    _intensityLevel = 5;
    _description = '';
    notifyListeners();
  }

  /// Submit the stress event to API.
  Future<bool> submitStress() async {
    if (_selectedSituation == null) {
      DialogService.showError(
        title: 'خطا',
        message: 'لطفاً یک موقعیت را انتخاب کنید',
      );
      return false;
    }

    final stressEvent = StressEventModel(
      id: '',
      userId: '',
      eventTimestamp: DateTime.now(),
      situationType: _selectedSituation!,
      situationDescription: _description.isEmpty ? null : _description,
      intensityLevel: _intensityLevel,
      dayNumber: _currentDayNumber,
    );

    return submit<StressEventModel>(
      action: () => _repository.createStressEvent(stressEvent: stressEvent),
      onSuccess: (outcome) {
        final saved = outcome.data;
        // Show the confirmed record immediately (dedupe by id) and clear form.
        _history = [saved, ..._history.where((e) => e.id != saved.id)];
        resetForm();
      },
      fallbackSuccessMessage: 'رویداد استرس ثبت شد',
    );
  }
}
