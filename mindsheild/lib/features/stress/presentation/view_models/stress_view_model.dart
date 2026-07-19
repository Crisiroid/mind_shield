import 'package:flutter/material.dart';
import '../../../../core/presentation/submission_flow.dart';
import '../../../../core/services/dialog_service.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../../../core/services/token_service.dart';
import '../../data/models/stress_event_model.dart';
import '../../data/repositories/stress_repository.dart';

class StressViewModel extends ChangeNotifier with SubmissionFlow {
  final StressRepository _repository;

  StressViewModel(this._repository);

  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedSituation;
  int _intensityLevel = 5;
  String _description = '';
  List<StressEventModel> _history = [];

  bool get isSaving => isSubmitting;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedSituation => _selectedSituation;
  int get intensityLevel => _intensityLevel;
  String get description => _description;
  List<StressEventModel> get history => _history;

  int get _currentDayNumber {
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    return WeekCalculator.currentDayNumber(registrationDate);
  }

  Future<void> init() async {
    await loadHistory();
  }

  Future<void> loadHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.listStressEvents();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (data) {
        _history = data;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  void selectSituation(String situation) {
    _selectedSituation = situation;
    notifyListeners();
  }

  void setIntensityLevel(int value) {
    _intensityLevel = value;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void resetForm() {
    _selectedSituation = null;
    _intensityLevel = 5;
    _description = '';
    notifyListeners();
  }

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
        _history = [saved, ..._history.where((e) => e.id != saved.id)];
        resetForm();
      },
      fallbackSuccessMessage: 'رویداد استرس ثبت شد',
    );
  }
}
