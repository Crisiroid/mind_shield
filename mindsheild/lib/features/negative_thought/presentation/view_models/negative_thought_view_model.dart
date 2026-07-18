import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/dialog_service.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../data/models/negative_thought_model.dart';
import '../../data/repositories/negative_thought_repository.dart';

/// Negative Thought ViewModel — manages thought registration, history,
/// and impact tracking.
///
/// Follows the Single Responsibility Principle: only handles negative
/// thought radar logic.
class NegativeThoughtViewModel extends ChangeNotifier {
  final NegativeThoughtRepository _repository;

  NegativeThoughtViewModel(this._repository);

  bool _isSaving = false;
  bool _isLoading = false;
  String? _errorMessage;
  List<NegativeThoughtModel> _thoughts = [];

  // Instant report form state
  String _situation = '';
  String _thoughtText = '';
  String? _selectedErrorType;
  int _impactLevel = 5;

  bool get isSaving => _isSaving;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<NegativeThoughtModel> get thoughts => _thoughts;
  String get situation => _situation;
  String get thoughtText => _thoughtText;
  String? get selectedErrorType => _selectedErrorType;
  int get impactLevel => _impactLevel;

  /// Get the current day number from registration date.
  int get _currentDayNumber {
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    return WeekCalculator.currentDayNumber(registrationDate);
  }

  /// All cognitive error types for dropdown selection.
  static final List<String> cognitiveErrorTypes = [
    AppStrings.allOrNothing,
    AppStrings.catastrophizing,
    AppStrings.mentalFilter,
    AppStrings.overgeneralization,
    AppStrings.personalization,
    AppStrings.blaming,
    AppStrings.shouldStatements,
    AppStrings.emotionalReasoning,
    AppStrings.labeling,
    AppStrings.fortuneTelling,
    AppStrings.mindReading,
    AppStrings.discountingPositives,
  ];

  /// Initialize by loading history.
  Future<void> init() async {
    await loadThoughts();
  }

  /// Load thoughts from API.
  Future<void> loadThoughts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.listNegativeThoughts();

    result.fold(
      (failure) {
        _thoughts = [];
      },
      (data) {
        _thoughts = data;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Update situation text.
  void setSituation(String value) {
    _situation = value;
    notifyListeners();
  }

  /// Update thought text.
  void setThoughtText(String value) {
    _thoughtText = value;
    notifyListeners();
  }

  /// Update selected error type.
  void setSelectedErrorType(String? value) {
    _selectedErrorType = value;
    notifyListeners();
  }

  /// Update impact level.
  void setImpactLevel(int value) {
    _impactLevel = value;
    notifyListeners();
  }

  /// Submit instant report (situation + thought + error type).
  Future<bool> submitInstantReport() async {
    if (_situation.trim().isEmpty) {
      DialogService.showError(
        title: AppStrings.error,
        message: AppStrings.enterSituation,
      );
      return false;
    }
    if (_thoughtText.trim().isEmpty) {
      DialogService.showError(
        title: AppStrings.error,
        message: AppStrings.enterThought,
      );
      return false;
    }

    _isSaving = true;
    notifyListeners();

    final thought = NegativeThoughtModel(
      id: '',
      userId: '',
      thoughtText: _thoughtText.trim(),
      situation: _situation.trim(),
      cognitiveErrorType: _selectedErrorType,
      dayNumber: _currentDayNumber,
    );

    final result = await _repository.createNegativeThought(thought: thought);

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
        _thoughts.insert(0, saved);
        _resetInstantReportForm();
        DialogService.showSuccess(
          title: AppStrings.success,
          message: AppStrings.thoughtRecorded,
        );
        success = true;
      },
    );

    _isSaving = false;
    notifyListeners();
    return success;
  }

  /// Submit thought impact assessment (thought + impact level).
  Future<bool> submitThoughtImpact() async {
    if (_thoughtText.trim().isEmpty) {
      DialogService.showError(
        title: AppStrings.error,
        message: AppStrings.enterThought,
      );
      return false;
    }

    _isSaving = true;
    notifyListeners();

    final thought = NegativeThoughtModel(
      id: '',
      userId: '',
      thoughtText: _thoughtText.trim(),
      impactLevel: _impactLevel,
      cognitiveErrorType: _selectedErrorType,
      dayNumber: _currentDayNumber,
    );

    final result = await _repository.createNegativeThought(thought: thought);

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
        _thoughts.insert(0, saved);
        _resetImpactForm();
        DialogService.showSuccess(
          title: AppStrings.success,
          message: AppStrings.impactSaved,
        );
        success = true;
      },
    );

    _isSaving = false;
    notifyListeners();
    return success;
  }

  /// Reset the instant report form.
  void _resetInstantReportForm() {
    _situation = '';
    _thoughtText = '';
    _selectedErrorType = null;
    notifyListeners();
  }

  /// Reset the impact assessment form.
  void _resetImpactForm() {
    _thoughtText = '';
    _impactLevel = 5;
    _selectedErrorType = null;
    notifyListeners();
  }
}
