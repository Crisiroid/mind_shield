import 'package:flutter/material.dart';
import '../../../../core/presentation/submission_flow.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../../../core/services/token_service.dart';
import '../../data/models/emotion_interaction_model.dart';
import '../../data/repositories/emotion_triangle_repository.dart';

/// Emotion Triangle ViewModel — manages emotion triangle screen state.
///
/// Follows the Single Responsibility Principle: only handles emotion
/// triangle logic. UI observes this provider and reacts to state changes.
class EmotionTriangleViewModel extends ChangeNotifier with SubmissionFlow {
  final EmotionTriangleRepository _repository;

  EmotionTriangleViewModel(this._repository);

  bool _isLoading = false;
  String? _errorMessage;
  String? _lastClickedSide;
  List<EmotionInteractionModel> _interactions = [];

  bool get isLoading => _isLoading;

  /// Backwards-compatible alias so screens can keep binding to `isSaving`.
  bool get isSaving => isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get lastClickedSide => _lastClickedSide;
  List<EmotionInteractionModel> get interactions => _interactions;

  /// Get the current day number from registration date.
  int get _currentDayNumber {
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    return WeekCalculator.currentDayNumber(registrationDate);
  }

  /// Initialize by loading interaction history.
  Future<void> init() async {
    await loadInteractions();
  }

  /// Load interaction history from API.
  Future<void> loadInteractions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.listInteractions();

    result.fold(
      (failure) {
        // Keep any previously loaded interactions on a failed refresh.
        _errorMessage = failure.message;
      },
      (data) {
        _interactions = data;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Record an interaction when user taps a triangle side.
  ///
  /// [side] is one of: 'thought', 'body', 'behavior'.
  /// Returns the side clicked for navigation decisions.
  Future<String?> recordInteraction(String side) async {
    _lastClickedSide = side;
    notifyListeners();

    final interaction = EmotionInteractionModel(
      id: '',
      userId: '',
      interactionDate: DateTime.now(),
      sideClicked: side,
      vibrationTriggered: side == 'body',
      dayNumber: _currentDayNumber,
    );

    await submit<EmotionInteractionModel>(
      action: () => _repository.createInteraction(interaction: interaction),
      onSuccess: (outcome) {
        final saved = outcome.data;
        // Show the confirmed record immediately (dedupe by id).
        _interactions = [
          saved,
          ..._interactions.where((e) => e.id != saved.id),
        ];
      },
      fallbackSuccessMessage: 'تعامل هیجانی ثبت شد',
    );
    return side;
  }
}
