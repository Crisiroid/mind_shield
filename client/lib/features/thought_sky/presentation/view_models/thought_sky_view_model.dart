import 'package:flutter/material.dart';
import '../../../../core/presentation/submission_flow.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../data/models/sky_thought_model.dart';
import '../../data/repositories/sky_thought_repository.dart';

class ThoughtSkyViewModel extends ChangeNotifier with SubmissionFlow {
  final SkyThoughtRepository _repository;

  ThoughtSkyViewModel(this._repository);

  final List<SkyThoughtModel> _clouds = [];
  bool _isLoading = false;

  List<SkyThoughtModel> get clouds => List.unmodifiable(_clouds);
  bool get isLoading => _isLoading;

  bool get isSaving => isSubmitting;

  int get _currentDayNumber {
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    return WeekCalculator.currentDayNumber(registrationDate);
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    await _fetchActiveClouds();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _reloadSilently() async {
    await _fetchActiveClouds();
    notifyListeners();
  }

  Future<void> _fetchActiveClouds() async {
    final result = await _repository.listSkyThoughts(pageSize: 50);
    result.fold((failure) {}, (thoughts) {
      _clouds
        ..clear()
        ..addAll(thoughts.where((t) => !t.cloudSwiped));
    });
  }

  Future<void> addThought(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final thought = SkyThoughtModel(
      id: '',
      userId: '',
      thoughtText: trimmed,
      dayNumber: _currentDayNumber,
    );

    final saved = await submit<SkyThoughtModel>(
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

    if (saved) await _reloadSilently();
  }

  Future<void> swipeAway(SkyThoughtModel cloud) async {
    _clouds.removeWhere((c) => identical(c, cloud));
    notifyListeners();

    if (cloud.id.isEmpty) return;
    await _repository.updateSkyThought(id: cloud.id, cloudSwiped: true);
  }
}
