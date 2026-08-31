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

class MindCourtViewModel extends ChangeNotifier with SubmissionFlow {
  final MindCourtRepository _repository;
  final NegativeThoughtRepository _negativeThoughtRepository;

  MindCourtViewModel(this._repository, this._negativeThoughtRepository);

  bool _isLoading = false;
  String? _errorMessage;
  List<NegativeThoughtModel> _thoughts = [];

  String? _selectedThoughtId;
  String _supportingEvidence = '';
  String _contradictingEvidence = '';
  bool _guideHelperUsed = false;
  String _alternativeThought = '';

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

  int get _currentDayNumber {
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    return WeekCalculator.currentDayNumber(registrationDate);
  }

  Future<void> init() async {
    await loadThoughts();
  }

  Future<void> loadThoughts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _negativeThoughtRepository.listNegativeThoughts();

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

  void setSelectedThoughtId(String? value) {
    _selectedThoughtId = value;
    notifyListeners();
  }

  void setSupportingEvidence(String value) {
    _supportingEvidence = value;
    notifyListeners();
  }

  void setContradictingEvidence(String value) {
    _contradictingEvidence = value;
    notifyListeners();
  }

  void markGuideHelperUsed() {
    if (_guideHelperUsed) return;
    _guideHelperUsed = true;
    notifyListeners();
  }

  void setAlternativeThought(String value) {
    _alternativeThought = value;
    notifyListeners();
  }

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

  void _resetForm() {
    _selectedThoughtId = null;
    _supportingEvidence = '';
    _contradictingEvidence = '';
    _guideHelperUsed = false;
    _alternativeThought = '';
    notifyListeners();
  }
}
