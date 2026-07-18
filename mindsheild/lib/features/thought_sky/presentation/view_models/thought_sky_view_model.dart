import 'package:flutter/material.dart';
import '../../../../core/presentation/submission_flow.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../data/models/sky_thought_model.dart';
import '../../data/repositories/sky_thought_repository.dart';

/// Thought Sky ViewModel (Week 8) — turns typed negative thoughts into
/// drifting clouds, persists them, and lets the user "swipe them away" to
/// watch them pass across the sky.
///
/// Follows the Single Responsibility Principle: only handles sky-thought
/// logic. UI observes this provider and reacts to state changes.
class ThoughtSkyViewModel extends ChangeNotifier with SubmissionFlow {
  final SkyThoughtRepository _repository;

  ThoughtSkyViewModel(this._repository);

  final List<SkyThoughtModel> _clouds = [];
  bool _isLoading = false;

  /// The active (not-yet-swiped) clouds currently drifting in the sky.
  List<SkyThoughtModel> get clouds => List.unmodifiable(_clouds);
  bool get isLoading => _isLoading;

  /// Backwards-compatible alias so screens can keep binding to `isSaving`.
  bool get isSaving => isSubmitting;

  /// Get the current day number from the stored registration date.
  int get _currentDayNumber {
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    return WeekCalculator.currentDayNumber(registrationDate);
  }

  /// Load existing, not-yet-swiped thoughts as active clouds.
  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.listSkyThoughts(pageSize: 50);
    result.fold((failure) {}, (thoughts) {
      _clouds
        ..clear()
        ..addAll(thoughts.where((t) => !t.cloudSwiped));
    });

    _isLoading = false;
    notifyListeners();
  }

  /// Turn a typed thought into a drifting cloud and persist it.
  ///
  /// Shows the server's confirmation and adds the saved cloud to the sky.
  Future<void> addThought(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final thought = SkyThoughtModel(
      id: '',
      userId: '',
      thoughtText: trimmed,
      dayNumber: _currentDayNumber,
    );

    await submit<SkyThoughtModel>(
      action: () => _repository.createSkyThought(thought: thought),
      onSuccess: (outcome) {
        final saved = outcome.data;
        if (!saved.cloudSwiped) {
          _clouds
            ..removeWhere((c) => c.id.isNotEmpty && c.id == saved.id)
            ..add(saved);
        }
      },
      fallbackSuccessMessage: 'فکر شما به ابر تبدیل شد',
    );
  }

  /// Swipe a cloud away — remove it from the sky and mark it swiped on the
  /// backend (only if it has a persisted id).
  Future<void> swipeAway(SkyThoughtModel cloud) async {
    _clouds.removeWhere((c) => identical(c, cloud));
    notifyListeners();

    if (cloud.id.isEmpty) return;
    await _repository.updateSkyThought(id: cloud.id, cloudSwiped: true);
  }
}
