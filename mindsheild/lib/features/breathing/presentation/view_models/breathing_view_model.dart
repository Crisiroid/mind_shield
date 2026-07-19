import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/presentation/submission_flow.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../../../core/services/token_service.dart';
import '../../data/models/breathing_session_model.dart';
import '../../data/repositories/breathing_repository.dart';

enum BreathingPhase { inhale, hold, exhale, holdAfter }

class BreathingViewModel extends ChangeNotifier with SubmissionFlow {
  final BreathingRepository _repository;

  BreathingViewModel(this._repository);

  bool _isActive = false;
  BreathingPhase _currentPhase = BreathingPhase.inhale;
  String _selectedPattern = 'box';
  int _elapsedSeconds = 0;
  int _breathCount = 0;
  String? _sessionId;
  Timer? _timer;
  Timer? _phaseTimer;

  static const Map<String, Map<String, int>> _patterns = {
    'box': {'inhale': 4, 'hold': 4, 'exhale': 4, 'holdAfter': 4},
    'deep': {'inhale': 4, 'hold': 7, 'exhale': 8, 'holdAfter': 0},
  };

  bool get isActive => _isActive;

  bool get isSaving => isSubmitting;
  BreathingPhase get currentPhase => _currentPhase;
  String get selectedPattern => _selectedPattern;
  int get elapsedSeconds => _elapsedSeconds;
  int get breathCount => _breathCount;

  int get _currentDayNumber {
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    return WeekCalculator.currentDayNumber(registrationDate);
  }

  Map<String, int> get patternDurations => _patterns[_selectedPattern]!;

  String get currentPhaseLabel {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        return 'دم';
      case BreathingPhase.hold:
        return 'نگه دارید';
      case BreathingPhase.exhale:
        return 'بازدم';
      case BreathingPhase.holdAfter:
        return 'نگه دارید';
    }
  }

  double get phaseProgress {
    final duration = patternDurations[_currentPhase.name] ?? 4;
    return duration > 0 ? 1.0 : 0.0;
  }

  void selectPattern(String pattern) {
    _selectedPattern = pattern;
    notifyListeners();
  }

  Future<void> startSession() async {
    _isActive = true;
    _elapsedSeconds = 0;
    _breathCount = 0;
    _currentPhase = BreathingPhase.inhale;
    notifyListeners();

    final session = BreathingSessionModel(
      id: '',
      userId: '',
      sessionStart: DateTime.now(),
      breathingPattern: _selectedPattern,
      dayNumber: _currentDayNumber,
    );

    final result = await _repository.createSession(session: session);
    result.fold((failure) {}, (saved) {
      _sessionId = saved.data.id;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      notifyListeners();
    });

    _startPhaseCycle();
  }

  void _startPhaseCycle() {
    final durations = patternDurations;
    _runPhase(BreathingPhase.inhale, durations['inhale']!);
  }

  void _runPhase(BreathingPhase phase, int duration) {
    if (!_isActive) return;

    _currentPhase = phase;
    if (phase == BreathingPhase.inhale) {
      _breathCount++;
    }
    notifyListeners();

    _phaseTimer = Timer(Duration(seconds: duration), () {
      if (!_isActive) return;

      switch (phase) {
        case BreathingPhase.inhale:
          if (patternDurations['hold']! > 0) {
            _runPhase(BreathingPhase.hold, patternDurations['hold']!);
          } else {
            _runPhase(BreathingPhase.exhale, patternDurations['exhale']!);
          }
          break;
        case BreathingPhase.hold:
          _runPhase(BreathingPhase.exhale, patternDurations['exhale']!);
          break;
        case BreathingPhase.exhale:
          if (patternDurations['holdAfter']! > 0) {
            _runPhase(BreathingPhase.holdAfter, patternDurations['holdAfter']!);
          } else {
            _runPhase(BreathingPhase.inhale, patternDurations['inhale']!);
          }
          break;
        case BreathingPhase.holdAfter:
          _runPhase(BreathingPhase.inhale, patternDurations['inhale']!);
          break;
      }
    });
  }

  Future<void> stopSession() async {
    _isActive = false;
    _timer?.cancel();
    _phaseTimer?.cancel();
    _timer = null;
    _phaseTimer = null;

    if (_sessionId != null) {
      final updateData = {
        'session_end': DateTime.now().toIso8601String(),
        'duration_seconds': _elapsedSeconds,
        'is_completed': true,
        'calendar_ticked': _elapsedSeconds >= 60,
      };

      await submit<BreathingSessionModel>(
        action: () =>
            _repository.updateSession(id: _sessionId!, data: updateData),
        onSuccess: (_) {},
        fallbackSuccessMessage: 'جلسه تنفس ثبت شد',
      );
    }

    _sessionId = null;
    _currentPhase = BreathingPhase.inhale;
    notifyListeners();
  }

  String get formattedElapsed {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phaseTimer?.cancel();
    super.dispose();
  }
}
