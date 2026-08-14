import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../../week1_exercise/data/repositories/week1_repositories.dart';
import '../../data/models/weekly_media_model.dart';
import '../../data/repositories/home_repository.dart';
import '../widgets/mindful_timer_sheet.dart';
import '../widgets/weekly_report_sheet.dart';

class ToolItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const ToolItem({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });
}

class HomeViewModel extends ChangeNotifier {
  final HomeRepository _homeRepository;
  final DayProgressRepository _dayProgressRepository;

  HomeViewModel(this._homeRepository, this._dayProgressRepository);

  bool _isLoadingMedia = false;
  String? _errorMessage;
  List<WeeklyMediaModel> _weeklyMedia = [];
  int _currentWeek = 1;
  int _currentDay = 1;
  double _progress = 0.0;
  bool _isTodayExerciseDone = false;

  bool get isLoadingMedia => _isLoadingMedia;
  String? get errorMessage => _errorMessage;
  List<WeeklyMediaModel> get weeklyMedia => _weeklyMedia;
  int get currentWeek => _currentWeek;
  int get currentDay => _currentDay;
  double get progress => _progress;
  bool get isTodayExerciseDone => _isTodayExerciseDone;

  bool get isAllUnlocked => AppConfig.isDebug;

  Future<void> init() async {
    _loadProgress();
    await _loadDayProgress();
    await _loadWeeklyMedia();
  }

  void _loadProgress() {
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    _currentWeek = WeekCalculator.currentWeekNumber(registrationDate);
    _currentDay = WeekCalculator.currentDayNumber(registrationDate);
    _progress = WeekCalculator.progressFraction(registrationDate);
    notifyListeners();
  }

  Future<void> _loadDayProgress() async {
    // Use local data for the completion check — this is the data saved by
    // markDayCompleted and is always up-to-date with the user's actions.
    // (The remote-first readList can overwrite local with stale server data.)
    _isTodayExerciseDone = await _dayProgressRepository.isDayCompletedLocally(
      weekNumber: _currentWeek,
      dayNumber: _currentDay,
    );
    notifyListeners();

    // Still fetch full summary for display needs.
    await _dayProgressRepository.getDayProgressSummary(
      weekNumber: _currentWeek,
    );
  }

  Future<void> _loadWeeklyMedia() async {
    _isLoadingMedia = true;
    _errorMessage = null;
    notifyListeners();

    // Home always shows the content published for the user's current week.
    // (Admin-only "all media" listing is intentionally not used here.)
    final result = await _homeRepository.getMediaByWeek(
      weekNumber: _currentWeek,
    );

    result.fold(
      (failure) {
        _weeklyMedia = [];
      },
      (media) {
        _weeklyMedia = media;
      },
    );

    _isLoadingMedia = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _loadProgress();
    await _loadDayProgress();
    await _loadWeeklyMedia();
  }

  List<ToolItem> getCurrentWeekTools(BuildContext? context) {
    // Show only the current week's daily exercises - no standalone exercises
    switch (_currentWeek) {
      case 1:
        return [
          ToolItem(
            label: 'تمرینات هفته اول',
            icon: Icons.auto_stories,
            color: const Color(0xFF6C63FF),
            onTap: () => Navigator.of(context!).pushNamed('/week1'),
          ),
        ];
      case 2:
        return [
          ToolItem(
            label: 'تمرینات هفته دوم',
            icon: Icons.auto_stories,
            color: const Color(0xFF6C63FF),
            onTap: () => Navigator.of(context!).pushNamed('/week2'),
          ),
        ];
      case 3:
        return [
          ToolItem(
            label: 'تمرینات هفته سوم',
            icon: Icons.auto_stories,
            color: const Color(0xFF6C63FF),
            onTap: () => Navigator.of(context!).pushNamed('/week3'),
          ),
        ];
      case 4:
        return [
          ToolItem(
            label: 'تمرینات هفته چهارم',
            icon: Icons.auto_stories,
            color: const Color(0xFF6C63FF),
            onTap: () => Navigator.of(context!).pushNamed('/week4'),
          ),
        ];
      case 5:
        return [
          ToolItem(
            label: 'تمرینات هفته پنجم',
            icon: Icons.auto_stories,
            color: const Color(0xFF6C63FF),
            onTap: () => Navigator.of(context!).pushNamed('/week5'),
          ),
        ];
      case 6:
        return [
          ToolItem(
            label: 'تمرینات هفته ششم',
            icon: Icons.auto_stories,
            color: const Color(0xFF6C63FF),
            onTap: () => Navigator.of(context!).pushNamed('/week6'),
          ),
        ];
      case 7:
        return [
          ToolItem(
            label: 'تمرینات هفته هفتم',
            icon: Icons.auto_stories,
            color: const Color(0xFF6C63FF),
            onTap: () => Navigator.of(context!).pushNamed('/week7'),
          ),
        ];
      case 8:
        return [
          ToolItem(
            label: 'تمرینات هفته هشتم',
            icon: Icons.auto_stories,
            color: const Color(0xFF6C63FF),
            onTap: () => Navigator.of(context!).pushNamed('/week8'),
          ),
        ];
      default:
        return [];
    }
  }

  List<ToolItem> getPermanentTools([BuildContext? context]) {
    return [
      ToolItem(
        label: 'کتابخانه محتوا',
        icon: Icons.video_library_outlined,
        color: const Color(0xFF6C63FF),
        onTap: () {
          if (context != null) {
            Navigator.of(context).pushNamed('/content-library');
          }
        },
      ),
      ToolItem(
        label: 'تایمر آگاهانه',
        icon: Icons.timer_outlined,
        color: const Color(0xFF00BCD4),
        onTap: () {
          if (context != null) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const MindfulTimerSheet(),
            );
          }
        },
      ),
      ToolItem(
        label: 'گزارش هفتگی',
        icon: Icons.assessment_outlined,
        color: const Color(0xFFFF6584),
        onTap: () {
          if (context != null) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => WeeklyReportSheet(
                currentWeek: _currentWeek,
                currentDay: _currentDay,
                progress: _progress,
              ),
            );
          }
        },
      ),
    ];
  }

  String? getStartExerciseRoute() {
    switch (_currentWeek) {
      case 1:
        return '/week1';
      case 2:
        return '/week2';
      case 3:
        return '/week3';
      case 4:
        return '/week4';
      case 5:
        return '/week5';
      case 6:
        return '/week6';
      case 7:
        return '/week7';
      case 8:
        return '/week8';
      default:
        return null;
    }
  }
}
