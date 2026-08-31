import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/presentation/submission_flow.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../data/models/mood_tracker_model.dart';
import '../../data/repositories/mood_tracker_repository.dart';

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

enum MoodPhase { before, doing, after, done }

class MoodTrackerViewModel extends ChangeNotifier with SubmissionFlow {
  final MoodTrackerRepository _repository;

  MoodTrackerViewModel(this._repository);

  MicroActivity? _selectedActivity;
  MoodPhase _phase = MoodPhase.before;
  int _moodBefore = 5;
  int _moodAfter = 5;
  bool _isLoadingHistory = false;
  List<MoodTrackerModel> _history = [];
  MoodTrackerModel? _lastSaved;

  MicroActivity? get selectedActivity => _selectedActivity;
  MoodPhase get phase => _phase;
  int get moodBefore => _moodBefore;
  int get moodAfter => _moodAfter;

  bool get isSaving => isSubmitting;
  bool get isLoadingHistory => _isLoadingHistory;
  List<MoodTrackerModel> get history => _history;
  MoodTrackerModel? get lastSaved => _lastSaved;

  int get moodDelta => _moodAfter - _moodBefore;

  String get resultMessage {
    if (moodDelta > 0) return AppStrings.moodImprovedMessage;
    if (moodDelta == 0) return AppStrings.moodSameMessage;
    return AppStrings.moodLowerMessage;
  }

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

  int get _currentDayNumber {
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    return WeekCalculator.currentDayNumber(registrationDate);
  }

  void selectActivity(MicroActivity activity) {
    _selectedActivity = activity;
    _phase = MoodPhase.before;
    _moodBefore = 5;
    _moodAfter = 5;
    _lastSaved = null;
    notifyListeners();
  }

  void setMoodBefore(int value) {
    _moodBefore = value;
    notifyListeners();
  }

  void setMoodAfter(int value) {
    _moodAfter = value;
    notifyListeners();
  }

  void startActivity() {
    _phase = MoodPhase.doing;
    notifyListeners();
  }

  void finishActivity() {
    _phase = MoodPhase.after;
    notifyListeners();
  }

  void reset() {
    _selectedActivity = null;
    _phase = MoodPhase.before;
    _moodBefore = 5;
    _moodAfter = 5;
    _lastSaved = null;
    notifyListeners();
  }

  Future<bool> submitMood() async {
    if (_selectedActivity == null) return false;

    final mood = MoodTrackerModel(
      id: '',
      userId: '',
      activityId: _selectedActivity!.id,
      activityName: _selectedActivity!.name,
      moodBefore: _moodBefore,
      moodAfter: _moodAfter,
      dayNumber: _currentDayNumber,
    );

    return submit<MoodTrackerModel>(
      action: () => _repository.createMoodTracker(mood: mood),
      onSuccess: (outcome) {
        final saved = outcome.data;
        _lastSaved = saved;
        _history = [saved, ..._history.where((e) => e.id != saved.id)];
        _phase = MoodPhase.done;
      },
      fallbackSuccessMessage: 'حال شما ثبت شد',
    );
  }

  Future<void> loadHistory() async {
    _isLoadingHistory = true;
    notifyListeners();

    final result = await _repository.listMoodTrackers(pageSize: 10);
    result.fold((failure) {}, (records) => _history = records);

    _isLoadingHistory = false;
    notifyListeners();
  }
}
