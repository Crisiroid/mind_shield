import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/presentation/submission_flow.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../../week1_exercise/data/models/weekly_exercise_model.dart';
import '../../../week1_exercise/data/models/day_progress_model.dart';
import '../../../week1_exercise/data/repositories/week1_repositories.dart';

class Week8ViewModel extends ChangeNotifier with SubmissionFlow {
  final Week1ExerciseRepository _exerciseRepo;
  final DayProgressRepository _dayProgressRepo;

  Week8ViewModel(this._exerciseRepo, this._dayProgressRepo);

  // State
  bool _isLoading = false;
  bool _isDataLoaded = false;
  String? _errorMessage;
  bool _hasAutoNavigated = false;
  int _currentDay = 50;
  int _currentStep = 0;
  int _currentProgramDay = 50;
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
    if (AppConfig.isDebug) return true;
    // Days unlock based on the calendar (registration date), not completion.
    return dayNumber <= _currentProgramDay;
  }

  DayProgressModel? getDayProgress(int dayNumber) {
    final matches = _dayProgressList.where((d) => d.dayNumber == dayNumber);
    return matches.isEmpty ? null : matches.first;
  }

  int get completedDaysCount =>
      _dayProgressList.where((d) => d.isCompleted).length;

  // --- Week 8 specific getters ---

  /// Top skills from day 50
  List<String> get topSkills {
    final records = _exerciseResponses
        .where((e) => e.exerciseType == 'skill_review')
        .toList();
    if (records.isEmpty) return [];
    try {
      final last = records.last;
      final data = jsonDecode(last.responseData) as Map<String, dynamic>;
      final list = (data['top_skills'] as List?)?.cast<String>() ?? [];
      return list;
    } catch (_) {
      return [];
    }
  }

  /// Main skill contexts from day 50
  List<String> get mainSkillContexts {
    final records = _exerciseResponses
        .where((e) => e.exerciseType == 'skill_review')
        .toList();
    if (records.isEmpty) return [];
    try {
      final last = records.last;
      final data = jsonDecode(last.responseData) as Map<String, dynamic>;
      final list = (data['main_skill_contexts'] as List?)?.cast<String>() ?? [];
      return list;
    } catch (_) {
      return [];
    }
  }

  /// Warning signs from day 51
  Map<String, dynamic>? get warningSigns {
    final records = _exerciseResponses
        .where((e) => e.exerciseType == 'warning_signs')
        .toList();
    if (records.isEmpty) return null;
    try {
      final last = records.last;
      return jsonDecode(last.responseData) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Earliest warning domain from day 51
  String? get earliestWarningDomain {
    final ws = warningSigns;
    return ws?['earliest_warning_domain'] as String?;
  }

  /// Personal toolbox from day 52
  Map<String, dynamic>? get personalToolbox {
    final records = _exerciseResponses
        .where((e) => e.exerciseType == 'personal_toolbox')
        .toList();
    if (records.isEmpty) return null;
    try {
      final last = records.last;
      return jsonDecode(last.responseData) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Maintenance plan from day 53
  Map<String, dynamic>? get maintenancePlan {
    final records = _exerciseResponses
        .where((e) => e.exerciseType == 'maintenance_plan')
        .toList();
    if (records.isEmpty) return null;
    try {
      final last = records.last;
      return jsonDecode(last.responseData) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Return after interruption from day 54
  Map<String, dynamic>? get returnPlan {
    final records = _exerciseResponses
        .where((e) => e.exerciseType == 'return_after_interruption')
        .toList();
    if (records.isEmpty) return null;
    try {
      final last = records.last;
      return jsonDecode(last.responseData) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Support plan from day 55
  Map<String, dynamic>? get supportPlan {
    final records = _exerciseResponses
        .where((e) => e.exerciseType == 'support_plan')
        .toList();
    if (records.isEmpty) return null;
    try {
      final last = records.last;
      return jsonDecode(last.responseData) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Final course quiz score from day 56
  int? get finalCourseQuizScore {
    final records = _exerciseResponses
        .where((e) => e.exerciseType == 'final_course_quiz')
        .toList();
    if (records.isEmpty) return null;
    try {
      final last = records.last;
      final data = jsonDecode(last.responseData) as Map<String, dynamic>;
      return data['final_course_quiz_score'] as int?;
    } catch (_) {
      return null;
    }
  }

  /// App evaluation from day 56
  Map<String, dynamic>? get appEvaluation {
    final records = _exerciseResponses
        .where((e) => e.exerciseType == 'overall_app_evaluation')
        .toList();
    if (records.isEmpty) return null;
    try {
      final last = records.last;
      return jsonDecode(last.responseData) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Whether intervention is completed
  bool get isInterventionCompleted {
    final records = _exerciseResponses
        .where((e) => e.exerciseType == 'final_personal_plan')
        .toList();
    return records.isNotEmpty;
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
      weekNumber: 8,
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
      weekNumber: 8,
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
