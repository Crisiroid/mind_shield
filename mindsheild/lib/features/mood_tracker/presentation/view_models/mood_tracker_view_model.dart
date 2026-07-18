import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../data/models/mood_tracker_model.dart';
import '../../data/repositories/mood_tracker_repository.dart';

/// A predefined micro-activity the user can perform to lift their mood.
class MicroActivity {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const MicroActivity({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}

/// The stage of the before/after mood-tracking flow.
enum MoodPhase { before, doing, after, done }

/// Mood Tracker ViewModel (Week 7) — manages the before/after mood
/// measurement flow around a chosen micro-activity, and persists each
/// completed record to the backend.
///
/// Follows the Single Responsibility Principle: only handles mood-tracking
/// logic. UI observes this provider and reacts to state changes.
class MoodTrackerViewModel extends ChangeNotifier {
  final MoodTrackerRepository _repository;

  MoodTrackerViewModel(this._repository);

  MicroActivity? _selectedActivity;
  MoodPhase _phase = MoodPhase.before;
  int _moodBefore = 5;
  int _moodAfter = 5;
  bool _isSaving = false;
  bool _isLoadingHistory = false;
  List<MoodTrackerModel> _history = [];
  MoodTrackerModel? _lastSaved;

  MicroActivity? get selectedActivity => _selectedActivity;
  MoodPhase get phase => _phase;
  int get moodBefore => _moodBefore;
  int get moodAfter => _moodAfter;
  bool get isSaving => _isSaving;
  bool get isLoadingHistory => _isLoadingHistory;
  List<MoodTrackerModel> get history => _history;
  MoodTrackerModel? get lastSaved => _lastSaved;

  /// The mood delta of the just-completed record (after - before).
  int get moodDelta => _moodAfter - _moodBefore;

  /// Feedback text tailored to whether the activity lifted the mood.
  String get resultMessage {
    if (moodDelta > 0) return AppStrings.moodImprovedMessage;
    if (moodDelta == 0) return AppStrings.moodSameMessage;
    return AppStrings.moodLowerMessage;
  }

  /// The 5 predefined micro-activities from the application flow.
  static const List<MicroActivity> activities = [
    MicroActivity(
      id: 'call_friend',
      name: AppStrings.microActivityCallFriend,
      description: AppStrings.microActivityCallFriendDesc,
      icon: Icons.call_outlined,
      color: Color(0xFF4CAF50),
    ),
    MicroActivity(
      id: 'reading',
      name: AppStrings.microActivityReading,
      description: AppStrings.microActivityReadingDesc,
      icon: Icons.menu_book_outlined,
      color: Color(0xFF3F51B5),
    ),
    MicroActivity(
      id: 'tea',
      name: AppStrings.microActivityTea,
      description: AppStrings.microActivityTeaDesc,
      icon: Icons.emoji_food_beverage_outlined,
      color: Color(0xFFFF9800),
    ),
    MicroActivity(
      id: 'exercise',
      name: AppStrings.microActivityExercise,
      description: AppStrings.microActivityExerciseDesc,
      icon: Icons.directions_walk_outlined,
      color: Color(0xFFE91E63),
    ),
    MicroActivity(
      id: 'music',
      name: AppStrings.microActivityMusic,
      description: AppStrings.microActivityMusicDesc,
      icon: Icons.music_note_outlined,
      color: Color(0xFF9C27B0),
    ),
  ];

  /// Get the current day number from the stored registration date.
  int get _currentDayNumber {
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    return WeekCalculator.currentDayNumber(registrationDate);
  }

  /// Choose a micro-activity and reset the flow to the "before" phase.
  void selectActivity(MicroActivity activity) {
    _selectedActivity = activity;
    _phase = MoodPhase.before;
    _moodBefore = 5;
    _moodAfter = 5;
    _lastSaved = null;
    notifyListeners();
  }

  /// Update the "before" mood value (1-10).
  void setMoodBefore(int value) {
    _moodBefore = value;
    notifyListeners();
  }

  /// Update the "after" mood value (1-10).
  void setMoodAfter(int value) {
    _moodAfter = value;
    notifyListeners();
  }

  /// Confirm the "before" reading and move to performing the activity.
  void startActivity() {
    _phase = MoodPhase.doing;
    notifyListeners();
  }

  /// Move from "doing" to the "after" measurement.
  void finishActivity() {
    _phase = MoodPhase.after;
    notifyListeners();
  }

  /// Reset the whole flow so the user can track a new activity.
  void reset() {
    _selectedActivity = null;
    _phase = MoodPhase.before;
    _moodBefore = 5;
    _moodAfter = 5;
    _lastSaved = null;
    notifyListeners();
  }

  /// Persist the completed before/after record and refresh history.
  ///
  /// Fails silently (offline-first) — the flow still completes locally.
  Future<void> submit() async {
    if (_selectedActivity == null) return;

    _isSaving = true;
    notifyListeners();

    final mood = MoodTrackerModel(
      id: '',
      userId: '',
      activityId: _selectedActivity!.id,
      activityName: _selectedActivity!.name,
      moodBefore: _moodBefore,
      moodAfter: _moodAfter,
      dayNumber: _currentDayNumber,
    );

    final result = await _repository.createMoodTracker(mood: mood);
    result.fold((failure) {}, (saved) => _lastSaved = saved);

    _phase = MoodPhase.done;
    _isSaving = false;
    notifyListeners();

    await loadHistory();
  }

  /// Load recent mood records to show the trend / proof of effect.
  Future<void> loadHistory() async {
    _isLoadingHistory = true;
    notifyListeners();

    final result = await _repository.listMoodTrackers(pageSize: 10);
    result.fold((failure) {}, (records) => _history = records);

    _isLoadingHistory = false;
    notifyListeners();
  }
}
