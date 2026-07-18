import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/presentation/submission_flow.dart';
import '../../../../core/services/dialog_service.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../../negative_thought/data/models/negative_thought_model.dart';
import '../../../negative_thought/data/repositories/negative_thought_repository.dart';
import '../../data/models/mind_court_model.dart';
import '../../data/repositories/mind_court_repository.dart';

/// Mind Court ViewModel — manages the "trial" of a negative thought:
/// picking a thought, weighing supporting vs. contradicting evidence,
/// and producing a rational alternative thought.
///
/// Follows the Single Responsibility Principle: only handles Mind Court
/// logic. Reuses [NegativeThoughtRepository] to source the thoughts that
/// can be put on trial (Dependency Inversion — depends on the abstraction).
class MindCourtViewModel extends ChangeNotifier with SubmissionFlow {
  final MindCourtRepository _repository;
  final NegativeThoughtRepository _negativeThoughtRepository;

  MindCourtViewModel(this._repository, this._negativeThoughtRepository);

  bool _isLoading = false;
  String? _errorMessage;
  List<NegativeThoughtModel> _thoughts = [];

  // Trial form state
  String? _selectedThoughtId;
  String _supportingEvidence = '';
  String _contradictingEvidence = '';
  bool _guideHelperUsed = false;
  String _alternativeThought = '';

  /// Backwards-compatible alias so screens can keep binding to `isSaving`.
  bool get isSaving => isSubmitting;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<NegativeThoughtModel> get thoughts => _thoughts;
  bool get hasThoughts => _thoughts.isNotEmpty;
  String? get selectedThoughtId => _selectedThoughtId;
  String get supportingEvidence => _supportingEvidence;
  String get contradictingEvidence => _contradictingEvidence;
  bool get guideHelperUsed => _guideHelperUsed;
  String get alternativeThought => _alternativeThought;

  /// Get the current day number from registration date.
  int get _currentDayNumber {
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    return WeekCalculator.currentDayNumber(registrationDate);
  }

  /// Initialize by loading the user's negative thoughts to put on trial.
  Future<void> init() async {
    await loadThoughts();
  }

  /// Load negative thoughts from the Week 4 radar feature.
  Future<void> loadThoughts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _negativeThoughtRepository.listNegativeThoughts();

    result.fold(
      (failure) {
        // Keep any previously loaded thoughts on a failed refresh.
        _errorMessage = failure.message;
      },
      (data) {
        _thoughts = data;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Select which negative thought to put on trial.
  void setSelectedThoughtId(String? value) {
    _selectedThoughtId = value;
    notifyListeners();
  }

  /// Update supporting evidence text.
  void setSupportingEvidence(String value) {
    _supportingEvidence = value;
    notifyListeners();
  }

  /// Update contradicting evidence text.
  void setContradictingEvidence(String value) {
    _contradictingEvidence = value;
    notifyListeners();
  }

  /// Mark that the guide helper was opened.
  void markGuideHelperUsed() {
    if (_guideHelperUsed) return;
    _guideHelperUsed = true;
    notifyListeners();
  }

  /// Update the rational alternative thought.
  void setAlternativeThought(String value) {
    _alternativeThought = value;
    notifyListeners();
  }

  /// Submit the verdict: create one Mind Court evidence record.
  Future<bool> submitVerdict() async {
    if (_selectedThoughtId == null || _selectedThoughtId!.isEmpty) {
      DialogService.showError(
        title: AppStrings.error,
        message: AppStrings.selectThoughtFirst,
      );
      return false;
    }
    if (_alternativeThought.trim().isEmpty) {
      DialogService.showError(
        title: AppStrings.error,
        message: AppStrings.enterAlternativeThought,
      );
      return false;
    }

    final evidence = MindCourtModel(
      id: '',
      userId: '',
      negativeThoughtId: _selectedThoughtId!,
      supportingEvidence: _supportingEvidence.trim().isEmpty
          ? null
          : _supportingEvidence.trim(),
      contradictingEvidence: _contradictingEvidence.trim().isEmpty
          ? null
          : _contradictingEvidence.trim(),
      guideHelperUsed: _guideHelperUsed,
      alternativeThought: _alternativeThought.trim(),
      dayNumber: _currentDayNumber,
    );

    return submit<MindCourtModel>(
      action: () => _repository.createMindCourt(evidence: evidence),
      onSuccess: (outcome) {
        _resetForm();
      },
      fallbackSuccessMessage: AppStrings.mindCourtSaved,
    );
  }

  /// Reset the trial form after a successful submission.
  void _resetForm() {
    _selectedThoughtId = null;
    _supportingEvidence = '';
    _contradictingEvidence = '';
    _guideHelperUsed = false;
    _alternativeThought = '';
    notifyListeners();
  }
}
