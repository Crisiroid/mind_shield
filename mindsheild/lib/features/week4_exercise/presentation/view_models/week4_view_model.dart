import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/presentation/submission_flow.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../../week1_exercise/data/models/weekly_exercise_model.dart';
import '../../../week1_exercise/data/models/day_progress_model.dart';
import '../../../week1_exercise/data/repositories/week1_repositories.dart';

class Week4ViewModel extends ChangeNotifier with SubmissionFlow {
  final Week1ExerciseRepository _exerciseRepo;
  final DayProgressRepository _dayProgressRepo;

  Week4ViewModel(this._exerciseRepo, this._dayProgressRepo);

  // State
  bool _isLoading = false;
  bool _isDataLoaded = false;
  String? _errorMessage;
  bool _hasAutoNavigated = false;
  int _currentDay = 22;
  int _currentStep = 0;
  int _currentProgramDay = 22;
  List<DayProgressModel> _dayProgressList = [];
  List<WeeklyExerciseModel> _exerciseResponses = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isDataLoaded => _isDataLoaded;
  String? get errorMessage => _errorMessage;
  bool get hasAutoNavigated => _hasAutoNavigated;
  void markAutoNavigated() {
    _hasAutoNavigated = true;
  }

  int get currentDay => _currentDay;
  int get currentStep => _currentStep;
  int get currentProgramDay => _currentProgramDay;
  List<DayProgressModel> get dayProgressList => _dayProgressList;
  List<WeeklyExerciseModel> get exerciseResponses => _exerciseResponses;

  bool isDayCompleted(int dayNumber) {
    return _dayProgressList
        .where((d) => d.dayNumber == dayNumber)
        .any((d) => d.isCompleted);
  }

  bool isDayUnlocked(int dayNumber) {
    // Days unlock based on the calendar (registration date), not completion.
    return dayNumber <= _currentProgramDay;
  }

  DayProgressModel? getDayProgress(int dayNumber) {
    final matches = _dayProgressList.where((d) => d.dayNumber == dayNumber);
    return matches.isEmpty ? null : matches.first;
  }

  int get completedDaysCount =>
      _dayProgressList.where((d) => d.isCompleted).length;

  // --- Week 4 specific getters ---

  /// Last selected thought from day 22
  String? get lastSelectedThought {
    final records = _exerciseResponses
        .where(
          (e) => e.exerciseType == 'cognitive_restructuring_thought_selection',
        )
        .toList();
    if (records.isEmpty) return null;
    try {
      final last = records.last;
      final data = jsonDecode(last.responseData) as Map<String, dynamic>;
      return data['selected_thought'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Supporting evidence from day 23
  List<String> get supportingEvidence {
    final records = _exerciseResponses
        .where((e) => e.exerciseType == 'supporting_evidence')
        .toList();
    if (records.isEmpty) return [];
    try {
      final last = records.last;
      final data = jsonDecode(last.responseData) as Map<String, dynamic>;
      final list = <String>[];
      if (data['evidence_1'] != null &&
          (data['evidence_1'] as String).isNotEmpty) {
        list.add(data['evidence_1'] as String);
      }
      if (data['evidence_2'] != null &&
          (data['evidence_2'] as String).isNotEmpty) {
        list.add(data['evidence_2'] as String);
      }
      return list;
    } catch (_) {
      return [];
    }
  }

  /// Counter evidence from day 24
  List<String> get counterEvidence {
    final records = _exerciseResponses
        .where((e) => e.exerciseType == 'counter_evidence')
        .toList();
    if (records.isEmpty) return [];
    try {
      final last = records.last;
      final data = jsonDecode(last.responseData) as Map<String, dynamic>;
      final list = <String>[];
      if (data['contrary_evidence'] != null &&
          (data['contrary_evidence'] as String).isNotEmpty) {
        list.add(data['contrary_evidence'] as String);
      }
      if (data['exception_evidence'] != null &&
          (data['exception_evidence'] as String).isNotEmpty) {
        list.add(data['exception_evidence'] as String);
      }
      if (data['alternative_explanation'] != null &&
          (data['alternative_explanation'] as String).isNotEmpty) {
        list.add(data['alternative_explanation'] as String);
      }
      return list;
    } catch (_) {
      return [];
    }
  }

  /// Balanced thought from day 25
  String? get lastBalancedThought {
    final records = _exerciseResponses
        .where((e) => e.exerciseType == 'balanced_thought')
        .toList();
    if (records.isEmpty) return null;
    try {
      final last = records.last;
      final data = jsonDecode(last.responseData) as Map<String, dynamic>;
      return data['balanced_thought'] as String?;
    } catch (_) {
      return null;
    }
  }

  int? get lastBeliefInitial {
    final records = _exerciseResponses
        .where(
          (e) =>
              e.exerciseType == 'cognitive_restructuring_thought_selection' ||
              e.exerciseType == 'balanced_thought' ||
              e.exerciseType == 'complete_restructuring_record',
        )
        .toList();
    if (records.isEmpty) return null;
    try {
      final last = records.last;
      final data = jsonDecode(last.responseData) as Map<String, dynamic>;
      return (data['thought_belief_initial'] as num?)?.toInt() ??
          (data['belief_initial'] as num?)?.toInt();
    } catch (_) {
      return null;
    }
  }

  int? get lastBeliefAfter {
    final records = _exerciseResponses
        .where(
          (e) =>
              e.exerciseType == 'balanced_thought' ||
              e.exerciseType == 'complete_restructuring_record',
        )
        .toList();
    if (records.isEmpty) return null;
    try {
      final last = records.last;
      final data = jsonDecode(last.responseData) as Map<String, dynamic>;
      return (data['initial_thought_belief_current'] as num?)?.toInt() ??
          (data['belief_after'] as num?)?.toInt();
    } catch (_) {
      return null;
    }
  }

  int get balancedThoughtsCount {
    return _exerciseResponses
        .where(
          (e) =>
              e.exerciseType == 'balanced_thought' ||
              e.exerciseType == 'complete_restructuring_record',
        )
        .length;
  }

  int get thoughtExercisesCount {
    return _exerciseResponses
        .where(
          (e) =>
              e.exerciseType == 'cognitive_restructuring_thought_selection' ||
              e.exerciseType == 'supporting_evidence' ||
              e.exerciseType == 'counter_evidence' ||
              e.exerciseType == 'balanced_thought' ||
              e.exerciseType == 'complete_restructuring_record',
        )
        .length;
  }

  double? get averageStressScore {
    final stressEntries = _exerciseResponses
        .where((e) => e.exerciseType == 'daily_stress')
        .toList();
    if (stressEntries.length < 3) return null;

    double total = 0;
    for (final entry in stressEntries) {
      try {
        final data = jsonDecode(entry.responseData) as Map<String, dynamic>;
        total += (data['stress_score'] as num?)?.toDouble() ?? 0;
      } catch (_) {}
    }
    return total / stressEntries.length;
  }

  int get exerciseCount => _exerciseResponses.length;

  Future<void> loadData() async {
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    _currentProgramDay = WeekCalculator.currentDayNumber(registrationDate);

    _isLoading = true;
    _isDataLoaded = false;
    _errorMessage = null;
    _hasAutoNavigated = false;
    notifyListeners();

    final progressResult = await _dayProgressRepo.getDayProgressSummary(
      weekNumber: 4,
    );
    await progressResult.fold(
      (failure) {
        _dayProgressList = [];
      },
      (data) {
        _dayProgressList = data;
      },
    );

    final exerciseResult = await _exerciseRepo.getExercisesByWeek(
      weekNumber: 4,
    );
    await exerciseResult.fold(
      (failure) {
        _exerciseResponses = [];
      },
      (data) {
        _exerciseResponses = data;
      },
    );

    _isLoading = false;
    _isDataLoaded = true;
    notifyListeners();
  }

  void setCurrentDay(int day) {
    _currentDay = day;
    _currentStep = 0;
    notifyListeners();
  }

  void setCurrentStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void nextStep() {
    _currentStep++;
    notifyListeners();
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  Future<void> openDay(int dayNumber) async {
    _currentDay = dayNumber;
    _currentStep = 0;
    notifyListeners();
  }

  Future<void> submitExerciseResponse({
    required int weekNumber,
    required int dayNumber,
    required String exerciseType,
    required Map<String, dynamic> data,
  }) async {
    final jsonString = jsonEncode(data);

    final model = WeeklyExerciseModel(
      id: DateTime.now().toIso8601String(),
      userId: '',
      weekNumber: weekNumber,
      dayNumber: dayNumber,
      exerciseType: exerciseType,
      responseData: jsonString,
    );

    final result = await _exerciseRepo.createExerciseResponse(entry: model);
    await result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (response) {
        _exerciseResponses.add(response.data);
      },
    );
    notifyListeners();
  }

  Future<void> completeDay({
    required int weekNumber,
    required int dayNumber,
  }) async {
    // Optimistic update: mark day complete locally BEFORE the server call
    // so that the UI is consistent when the screen pops.
    final progress = DayProgressModel(
      id: 'week${weekNumber}_day$dayNumber',
      userId: '',
      weekNumber: weekNumber,
      dayNumber: dayNumber,
      isCompleted: true,
      completedAt: DateTime.now(),
    );
    _dayProgressList.removeWhere((d) => d.dayNumber == dayNumber);
    _dayProgressList.add(progress);
    _dayProgressList.sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
    notifyListeners();

    final result = await _dayProgressRepo.markDayCompleted(
      weekNumber: weekNumber,
      dayNumber: dayNumber,
    );
    await result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (serverProgress) {
        _dayProgressList.removeWhere((d) => d.dayNumber == dayNumber);
        _dayProgressList.add(serverProgress);
        _dayProgressList.sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
      },
    );
    notifyListeners();
  }

  WeeklyExerciseModel? getExerciseResponse(int dayNumber, String exerciseType) {
    final matches = _exerciseResponses.where(
      (e) => e.dayNumber == dayNumber && e.exerciseType == exerciseType,
    );
    return matches.isEmpty ? null : matches.first;
  }
}
