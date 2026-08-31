import 'package:flutter/material.dart';
import '../../../../core/presentation/submission_flow.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../data/models/role_value_model.dart';
import '../../data/repositories/role_value_repository.dart';

class RoleBalanceViewModel extends ChangeNotifier with SubmissionFlow {
  final RoleValueRepository _repository;

  RoleBalanceViewModel(this._repository);

  final List<RoleValueModel> _roles = [];
  final List<RoleValueModel> _values = [];
  bool _isLoading = false;

  List<RoleValueModel> get roles => List.unmodifiable(_roles);
  List<RoleValueModel> get values => List.unmodifiable(_values);
  bool get isLoading => _isLoading;

  bool get isSaving => isSubmitting;

  double get overlapIntensity {
    final total = _roles.length + _values.length;
    if (total == 0) return 0.0;
    final balance = 1.0 - (_roles.length - _values.length).abs() / total;
    final volume = (total / 6).clamp(0.0, 1.0);
    return (balance * volume).clamp(0.0, 1.0);
  }

  bool get hasTension => _roles.isNotEmpty && _values.isNotEmpty;

  int get _currentDayNumber {
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    return WeekCalculator.currentDayNumber(registrationDate);
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    await _fetchAndSplit();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _reloadSilently() async {
    await _fetchAndSplit();
    notifyListeners();
  }

  Future<void> _fetchAndSplit() async {
    final result = await _repository.listRolesValues(pageSize: 100);
    result.fold((failure) {}, (entries) {
      _roles
        ..clear()
        ..addAll(entries.where((e) => e.isRole));
      _values
        ..clear()
        ..addAll(entries.where((e) => e.isValue));
    });
  }

  Future<void> addEntry({
    required String entryType,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final entry = RoleValueModel(
      id: '',
      userId: '',
      entryType: entryType,
      entryText: trimmed,
      dayNumber: _currentDayNumber,
    );

    final saved = await submit<RoleValueModel>(
      action: () => _repository.createRoleValue(entry: entry),
      onSuccess: (outcome) {
        final saved = outcome.data;
        if (saved.isRole) {
          _roles
            ..removeWhere((e) => e.id.isNotEmpty && e.id == saved.id)
            ..add(saved);
        } else if (saved.isValue) {
          _values
            ..removeWhere((e) => e.id.isNotEmpty && e.id == saved.id)
            ..add(saved);
        }
      },
      fallbackSuccessMessage: 'مورد جدید اضافه شد',
    );

    if (saved) await _reloadSilently();
  }
}
