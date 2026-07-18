import 'package:flutter/material.dart';
import '../../../../core/presentation/submission_flow.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../data/models/role_value_model.dart';
import '../../data/repositories/role_value_repository.dart';

/// Role Balance ViewModel (Week 8) — manages organizational roles and
/// personal values, and visualizes the tension between them.
///
/// Follows the Single Responsibility Principle: only handles role/value
/// logic. UI observes this provider and reacts to state changes.
class RoleBalanceViewModel extends ChangeNotifier with SubmissionFlow {
  final RoleValueRepository _repository;

  RoleBalanceViewModel(this._repository);

  final List<RoleValueModel> _roles = [];
  final List<RoleValueModel> _values = [];
  bool _isLoading = false;

  List<RoleValueModel> get roles => List.unmodifiable(_roles);
  List<RoleValueModel> get values => List.unmodifiable(_values);
  bool get isLoading => _isLoading;

  /// Backwards-compatible alias so screens can keep binding to `isSaving`.
  bool get isSaving => isSubmitting;

  /// Overlap/tension intensity (0.0 - 1.0) derived from how balanced the
  /// counts of roles and values are. The more entries on both sides, the
  /// larger the overlap between the two identity circles.
  double get overlapIntensity {
    final total = _roles.length + _values.length;
    if (total == 0) return 0.0;
    final balance = 1.0 - (_roles.length - _values.length).abs() / total;
    final volume = (total / 6).clamp(0.0, 1.0);
    return (balance * volume).clamp(0.0, 1.0);
  }

  /// Whether there is any tension to visualize (entries on both sides).
  bool get hasTension => _roles.isNotEmpty && _values.isNotEmpty;

  /// Get the current day number from the stored registration date.
  int get _currentDayNumber {
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    return WeekCalculator.currentDayNumber(registrationDate);
  }

  /// Load existing role/value entries and split them into the two groups.
  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.listRolesValues(pageSize: 100);
    result.fold((failure) {}, (entries) {
      _roles
        ..clear()
        ..addAll(entries.where((e) => e.isRole));
      _values
        ..clear()
        ..addAll(entries.where((e) => e.isValue));
    });

    _isLoading = false;
    notifyListeners();
  }

  /// Add a new role or value entry and persist it.
  ///
  /// Shows the server's confirmation and adds the saved entry locally.
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

    await submit<RoleValueModel>(
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
  }
}
