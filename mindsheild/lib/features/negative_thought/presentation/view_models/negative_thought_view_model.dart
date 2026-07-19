import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/presentation/submission_flow.dart';
import '../../../../core/services/dialog_service.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../data/models/negative_thought_model.dart';
import '../../data/repositories/negative_thought_repository.dart';

class NegativeThoughtViewModel extends ChangeNotifier with SubmissionFlow {
  final NegativeThoughtRepository _repository;

  NegativeThoughtViewModel(this._repository);

  bool _isLoading = false;
  String? _errorMessage;
  List<NegativeThoughtModel> _thoughts = [];

  String _situation = '';
  String _thoughtText = '';
  String? _selectedErrorType;
  int _impactLevel = 5;

  bool get isSaving => isSubmitting;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<NegativeThoughtModel> get thoughts => _thoughts;
  String get situation => _situation;
  String get thoughtText => _thoughtText;
  String? get selectedErrorType => _selectedErrorType;
  int get impactLevel => _impactLevel;

  int get _currentDayNumber {
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    return WeekCalculator.currentDayNumber(registrationDate);
  }

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

  Future<void> init() async {
    await loadThoughts();
  }

  Future<void> loadThoughts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.listNegativeThoughts();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (data) {
        _thoughts = data;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  void setSituation(String value) {
    _situation = value;
    notifyListeners();
  }

  void setThoughtText(String value) {
    _thoughtText = value;
    notifyListeners();
  }

  void setSelectedErrorType(String? value) {
    _selectedErrorType = value;
    notifyListeners();
  }

  void setImpactLevel(int value) {
    _impactLevel = value;
    notifyListeners();
  }

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

    final thought = NegativeThoughtModel(
      id: '',
      userId: '',
      thoughtText: _thoughtText.trim(),
      situation: _situation.trim(),
      cognitiveErrorType: _selectedErrorType,
      dayNumber: _currentDayNumber,
    );

    return submit<NegativeThoughtModel>(
      action: () => _repository.createNegativeThought(thought: thought),
      onSuccess: (outcome) {
        final saved = outcome.data;
        _thoughts = [saved, ..._thoughts.where((t) => t.id != saved.id)];
        _resetInstantReportForm();
      },
      fallbackSuccessMessage: AppStrings.thoughtRecorded,
    );
  }

  Future<bool> submitThoughtImpact() async {
    if (_thoughtText.trim().isEmpty) {
      DialogService.showError(
        title: AppStrings.error,
        message: AppStrings.enterThought,
      );
      return false;
    }

    final thought = NegativeThoughtModel(
      id: '',
      userId: '',
      thoughtText: _thoughtText.trim(),
      impactLevel: _impactLevel,
      cognitiveErrorType: _selectedErrorType,
      dayNumber: _currentDayNumber,
    );

    return submit<NegativeThoughtModel>(
      action: () => _repository.createNegativeThought(thought: thought),
      onSuccess: (outcome) {
        final saved = outcome.data;
        _thoughts = [saved, ..._thoughts.where((t) => t.id != saved.id)];
        _resetImpactForm();
      },
      fallbackSuccessMessage: AppStrings.impactSaved,
    );
  }

  void _resetInstantReportForm() {
    _situation = '';
    _thoughtText = '';
    _selectedErrorType = null;
    notifyListeners();
  }

  void _resetImpactForm() {
    _thoughtText = '';
    _impactLevel = 5;
    _selectedErrorType = null;
    notifyListeners();
  }
}
