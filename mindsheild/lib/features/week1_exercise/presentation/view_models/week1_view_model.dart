import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/presentation/submission_flow.dart';
import '../../data/models/weekly_exercise_model.dart';
import '../../data/models/day_progress_model.dart';
import '../../data/repositories/week1_repositories.dart';

class Week1ViewModel extends ChangeNotifier with SubmissionFlow {
  final Week1ExerciseRepository _exerciseRepo;
  final DayProgressRepository _dayProgressRepo;

  Week1ViewModel(this._exerciseRepo, this._dayProgressRepo);

  // State
  bool _isLoading = false;
  String? _errorMessage;
  int _currentDay = 1;
  int _currentStep = 0;
  List<DayProgressModel> _dayProgressList = [];
  List<WeeklyExerciseModel> _exerciseResponses = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentDay => _currentDay;
  int get currentStep => _currentStep;
  List<DayProgressModel> get dayProgressList => _dayProgressList;
  List<WeeklyExerciseModel> get exerciseResponses => _exerciseResponses;

  bool isDayCompleted(int dayNumber) {
    return _dayProgressList
        .where((d) => d.dayNumber == dayNumber)
        .any((d) => d.isCompleted);
  }

  bool isDayUnlocked(int dayNumber) {
    if (dayNumber == 1) return true;
    return isDayCompleted(dayNumber - 1);
  }

  DayProgressModel? getDayProgress(int dayNumber) {
    final matches = _dayProgressList.where((d) => d.dayNumber == dayNumber);
    return matches.isEmpty ? null : matches.first;
  }

  int get completedDaysCount =>
      _dayProgressList.where((d) => d.isCompleted).length;

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

  Future<void> loadData({int weekNumber = 1}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final progressResult = await _dayProgressRepo.getDayProgressSummary(
      weekNumber: weekNumber,
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
      weekNumber: weekNumber,
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
    final result = await _dayProgressRepo.markDayCompleted(
      weekNumber: weekNumber,
      dayNumber: dayNumber,
    );
    await result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (progress) {
        // Update or add the progress entry
        _dayProgressList.removeWhere((d) => d.dayNumber == dayNumber);
        _dayProgressList.add(progress);
        _dayProgressList.sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
      },
    );
    notifyListeners();
  }

  // Get stored response for a specific exercise type on a specific day
  WeeklyExerciseModel? getExerciseResponse(int dayNumber, String exerciseType) {
    final matches = _exerciseResponses.where(
      (e) => e.dayNumber == dayNumber && e.exerciseType == exerciseType,
    );
    return matches.isEmpty ? null : matches.first;
  }
}
