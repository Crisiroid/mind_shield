import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/presentation/submission_flow.dart';
import '../../../../core/services/dialog_service.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../data/models/mental_must_model.dart';
import '../../data/repositories/mental_must_repository.dart';

class MentalMustViewModel extends ChangeNotifier with SubmissionFlow {
  final MentalMustRepository _repository;

  MentalMustViewModel(this._repository);

  bool _isLoading = false;
  String? _errorMessage;
  String _mustText = '';
  List<MentalMustModel> _musts = [];

  bool get isSaving => isSubmitting;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get mustText => _mustText;
  List<MentalMustModel> get musts => _musts;

  List<MentalMustModel> get activeMusts =>
      _musts.where((m) => !m.isReleased).toList();

  List<MentalMustModel> get releasedMusts =>
      _musts.where((m) => m.isReleased).toList();

  int get _currentDayNumber {
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    return WeekCalculator.currentDayNumber(registrationDate);
  }

  Future<void> init() async {
    await loadMusts();
  }

  Future<void> loadMusts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.listMentalMusts();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (data) {
        _musts = data;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  void setMustText(String value) {
    _mustText = value;
    notifyListeners();
  }

  Future<bool> submitMust() async {
    if (_mustText.trim().isEmpty) {
      DialogService.showError(
        title: AppStrings.error,
        message: AppStrings.enterMustText,
      );
      return false;
    }

    final must = MentalMustModel(
      id: '',
      userId: '',
      mustText: _mustText.trim(),
      createdDate: DateTime.now().toIso8601String(),
      dayNumber: _currentDayNumber,
    );

    return submit<MentalMustModel>(
      action: () => _repository.createMentalMust(must: must),
      onSuccess: (outcome) {
        final saved = outcome.data;
        _musts = [saved, ..._musts.where((m) => m.id != saved.id)];
        _mustText = '';
      },
      fallbackSuccessMessage: AppStrings.mustAdded,
    );
  }

  Future<bool> releaseMust(String id) async {
    return submit<MentalMustModel>(
      action: () =>
          _repository.updateMentalMust(id: id, data: {'is_released': true}),
      onSuccess: (outcome) {
        final updated = outcome.data;
        final index = _musts.indexWhere((m) => m.id == id);
        if (index != -1) {
          _musts[index] = updated;
        }
      },
      fallbackSuccessMessage: AppStrings.mustReleased,
    );
  }
}
