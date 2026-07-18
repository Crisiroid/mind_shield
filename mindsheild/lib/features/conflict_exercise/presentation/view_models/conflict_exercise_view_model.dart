import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../data/models/conflict_exercise_model.dart';
import '../../data/repositories/conflict_exercise_repository.dart';

/// A single response option for a conflict scenario.
///
/// [qualityScore] is the performance value (0-100) awarded when this
/// response is chosen — the assertive/respectful option scores highest.
class ConflictResponseOption {
  final String text;
  final int qualityScore;

  const ConflictResponseOption({
    required this.text,
    required this.qualityScore,
  });
}

/// A predefined workplace conflict scenario.
class ConflictScenario {
  final int id;
  final String title;
  final String situation;
  final List<ConflictResponseOption> options;

  const ConflictScenario({
    required this.id,
    required this.title,
    required this.situation,
    required this.options,
  });
}

/// Conflict Exercise ViewModel — manages repeatable conflict-practice
/// scenarios, scoring, and persistence.
///
/// Follows the Single Responsibility Principle: only handles conflict
/// practice logic. Each completed attempt is POSTed as a new record
/// (mirrors the Cognitive Game pattern).
class ConflictExerciseViewModel extends ChangeNotifier {
  final ConflictExerciseRepository _repository;

  ConflictExerciseViewModel(this._repository);

  bool _isSaving = false;
  int _currentScenarioIndex = 0;
  ConflictResponseOption? _selectedOption;
  bool _finished = false;

  bool get isSaving => _isSaving;
  int get currentScenarioIndex => _currentScenarioIndex;
  ConflictResponseOption? get selectedOption => _selectedOption;
  bool get finished => _finished;
  bool get hasAnswered => _selectedOption != null;
  bool get isLastScenario => _currentScenarioIndex >= scenarios.length - 1;

  /// The scenario currently being practiced.
  ConflictScenario get currentScenario => scenarios[_currentScenarioIndex];

  /// Performance score of the selected option (0-100), or 0 if unanswered.
  int get performanceScore => _selectedOption?.qualityScore ?? 0;

  /// Feedback text tailored to the chosen response quality.
  String get feedback {
    final score = performanceScore;
    if (score >= 100) return AppStrings.conflictFeedbackBest;
    if (score >= 50) return AppStrings.conflictFeedbackMedium;
    return AppStrings.conflictFeedbackLow;
  }

  /// Get the current day number from registration date.
  int get _currentDayNumber {
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    return WeekCalculator.currentDayNumber(registrationDate);
  }

  /// The 3 predefined workplace conflict scenarios.
  static final List<ConflictScenario> scenarios = [
    ConflictScenario(
      id: 1,
      title: AppStrings.conflictScenario1Title,
      situation: AppStrings.conflictScenario1Situation,
      options: const [
        ConflictResponseOption(
          text: AppStrings.conflictScenario1Best,
          qualityScore: 100,
        ),
        ConflictResponseOption(
          text: AppStrings.conflictScenario1Option2,
          qualityScore: 0,
        ),
        ConflictResponseOption(
          text: AppStrings.conflictScenario1Option3,
          qualityScore: 50,
        ),
      ],
    ),
    ConflictScenario(
      id: 2,
      title: AppStrings.conflictScenario2Title,
      situation: AppStrings.conflictScenario2Situation,
      options: const [
        ConflictResponseOption(
          text: AppStrings.conflictScenario2Best,
          qualityScore: 100,
        ),
        ConflictResponseOption(
          text: AppStrings.conflictScenario2Option2,
          qualityScore: 0,
        ),
        ConflictResponseOption(
          text: AppStrings.conflictScenario2Option3,
          qualityScore: 50,
        ),
      ],
    ),
    ConflictScenario(
      id: 3,
      title: AppStrings.conflictScenario3Title,
      situation: AppStrings.conflictScenario3Situation,
      options: const [
        ConflictResponseOption(
          text: AppStrings.conflictScenario3Best,
          qualityScore: 100,
        ),
        ConflictResponseOption(
          text: AppStrings.conflictScenario3Option2,
          qualityScore: 50,
        ),
        ConflictResponseOption(
          text: AppStrings.conflictScenario3Option3,
          qualityScore: 0,
        ),
      ],
    ),
  ];

  /// Select a response for the current scenario and persist the attempt.
  void selectOption(ConflictResponseOption option) {
    if (_selectedOption != null) return; // Already answered
    _selectedOption = option;
    notifyListeners();

    _submitAttempt();
  }

  /// Advance to the next scenario, or mark the practice as finished.
  void nextScenario() {
    if (_currentScenarioIndex < scenarios.length - 1) {
      _currentScenarioIndex++;
      _selectedOption = null;
      notifyListeners();
    } else {
      _finished = true;
      notifyListeners();
    }
  }

  /// Reset to practice all scenarios again from the start.
  void resetPractice() {
    _currentScenarioIndex = 0;
    _selectedOption = null;
    _finished = false;
    notifyListeners();
  }

  /// POST the current attempt to the backend (fails silently — the
  /// practice remains usable offline, like the Cognitive Game).
  Future<void> _submitAttempt() async {
    _isSaving = true;
    notifyListeners();

    final exercise = ConflictExerciseModel(
      id: '',
      userId: '',
      scenarioId: currentScenario.id,
      performanceScore: performanceScore,
      dayNumber: _currentDayNumber,
    );

    final result = await _repository.createConflictExercise(exercise: exercise);

    result.fold((failure) {}, (saved) {});

    _isSaving = false;
    notifyListeners();
  }
}
