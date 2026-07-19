import 'package:flutter/material.dart';
import '../../../../core/presentation/submission_flow.dart';
import '../../../../core/services/dialog_service.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../../../core/services/token_service.dart';
import '../../data/models/body_tension_model.dart';
import '../../data/repositories/body_tension_repository.dart';

class BodyTensionViewModel extends ChangeNotifier with SubmissionFlow {
  final BodyTensionRepository _repository;

  BodyTensionViewModel(this._repository);

  bool _isLoading = false;
  String? _errorMessage;
  List<BodyTensionModel> _history = [];

  final Set<String> _selectedRegions = {};
  int _intensity = 5;
  String _notes = '';

  bool get isLoading => _isLoading;

  bool get isSaving => isSubmitting;
  String? get errorMessage => _errorMessage;
  List<BodyTensionModel> get history => _history;
  Set<String> get selectedRegions => _selectedRegions;
  int get intensity => _intensity;
  String get notes => _notes;

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

    final result = await _repository.listBodyTensions();

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

  void toggleRegion(String region) {
    if (_selectedRegions.contains(region)) {
      _selectedRegions.remove(region);
    } else {
      _selectedRegions.add(region);
    }
    notifyListeners();
  }

  void setIntensity(int value) {
    _intensity = value;
    notifyListeners();
  }

  void setNotes(String value) {
    _notes = value;
    notifyListeners();
  }

  void resetForm() {
    _selectedRegions.clear();
    _intensity = 5;
    _notes = '';
    notifyListeners();
  }

  String get severityColor {
    if (_intensity <= 3) return 'yellow';
    if (_intensity <= 6) return 'orange';
    return 'red';
  }

  Future<bool> saveBodyTension() async {
    if (_selectedRegions.isEmpty) {
      DialogService.showError(
        title: 'خطا',
        message: 'لطفاً حداقل یک ناحیه بدن را انتخاب کنید',
      );
      return false;
    }

    final bodyTension = BodyTensionModel(
      id: '',
      userId: '',
      mappingDate: DateTime.now(),
      bodyRegions: _selectedRegions.join(','),
      overallIntensity: _intensity,
      severityColor: severityColor,
      notes: _notes.isEmpty ? null : _notes,
      dayNumber: _currentDayNumber,
    );

    return submit<BodyTensionModel>(
      action: () => _repository.createBodyTension(bodyTension: bodyTension),
      onSuccess: (outcome) {
        final saved = outcome.data;
        _history = [saved, ..._history.where((e) => e.id != saved.id)];
        resetForm();
      },
      fallbackSuccessMessage: 'نقشه تنش بدنی ثبت شد',
    );
  }
}
