import 'package:flutter/material.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../data/models/weekly_media_model.dart';
import '../../data/repositories/home_repository.dart';

/// Tool item model for quick access grid.
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

/// Home ViewModel — manages home screen state and data.
///
/// Follows the Single Responsibility Principle: only handles home screen logic.
/// UI observes this provider and reacts to state changes.
/// Uses dependency injection for the repository (DIP).
class HomeViewModel extends ChangeNotifier {
  final HomeRepository _homeRepository;

  HomeViewModel(this._homeRepository);

  bool _isLoadingMedia = false;
  String? _errorMessage;
  List<WeeklyMediaModel> _weeklyMedia = [];
  int _currentWeek = 1;
  int _currentDay = 1;
  double _progress = 0.0;

  bool get isLoadingMedia => _isLoadingMedia;
  String? get errorMessage => _errorMessage;
  List<WeeklyMediaModel> get weeklyMedia => _weeklyMedia;
  int get currentWeek => _currentWeek;
  int get currentDay => _currentDay;
  double get progress => _progress;

  /// Initialize home screen data.
  Future<void> init() async {
    _loadProgress();
    await _loadWeeklyMedia();
  }

  /// Load progress from stored registration date.
  void _loadProgress() {
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    _currentWeek = WeekCalculator.currentWeekNumber(registrationDate);
    _currentDay = WeekCalculator.currentDayNumber(registrationDate);
    _progress = WeekCalculator.progressFraction(registrationDate);
    notifyListeners();
  }

  /// Load weekly media content for current week.
  Future<void> _loadWeeklyMedia() async {
    _isLoadingMedia = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _homeRepository.getMediaByWeek(
      weekNumber: _currentWeek,
    );

    result.fold(
      (failure) {
        // Don't show error for media loading failure (offline-first)
        _weeklyMedia = [];
      },
      (media) {
        _weeklyMedia = media;
      },
    );

    _isLoadingMedia = false;
    notifyListeners();
  }

  /// Refresh all home screen data.
  Future<void> refresh() async {
    _loadProgress();
    await _loadWeeklyMedia();
  }

  /// Get tools for current week based on application flow.
  ///
  /// Accepts a [BuildContext] for navigation to feature screens.
  List<ToolItem> getCurrentWeekTools(BuildContext? context) {
    switch (_currentWeek) {
      case 1:
        return [
          ToolItem(
            label: 'مثلث هیجان',
            icon: Icons.change_history,
            color: const Color(0xFF6C63FF),
            onTap: () => Navigator.of(context!).pushNamed('/emotion-triangle'),
          ),
          ToolItem(
            label: 'نقشه تنش بدنی',
            icon: Icons.accessibility_new,
            color: const Color(0xFFFF6584),
            onTap: () => Navigator.of(context!).pushNamed('/body-tension-map'),
          ),
          ToolItem(
            label: 'ثبت استرس شغلی',
            icon: Icons.work_outline,
            color: const Color(0xFFFFC107),
            onTap: () =>
                Navigator.of(context!).pushNamed('/stress-registration'),
          ),
        ];
      case 2:
        return [
          ToolItem(
            label: 'تنفس آگاهانه',
            icon: Icons.air,
            color: const Color(0xFF4CAF50),
            onTap: () => Navigator.of(context!).pushNamed('/breathing'),
          ),
          ToolItem(
            label: 'انعطاف‌پذیری روانی',
            icon: Icons.nature,
            color: const Color(0xFF8BC34A),
            onTap: () =>
                Navigator.of(context!).pushNamed('/resilience-education'),
          ),
          ToolItem(
            label: 'نقشه تنش بدنی',
            icon: Icons.accessibility_new,
            color: const Color(0xFFFF6584),
            onTap: () => Navigator.of(context!).pushNamed('/body-tension-map'),
          ),
        ];
      case 3:
        return [
          ToolItem(
            label: 'خطاهای شناختی',
            icon: Icons.psychology_outlined,
            color: const Color(0xFF9C27B0),
            onTap: () => Navigator.of(context!).pushNamed('/cognitive-game'),
          ),
          ToolItem(
            label: 'بایدهای ذهنی',
            icon: Icons.backpack_outlined,
            color: const Color(0xFFFF9800),
            onTap: () => Navigator.of(context!).pushNamed('/mental-musts'),
          ),
        ];
      case 4:
        return [
          ToolItem(
            label: 'رادار افکار منفی',
            icon: Icons.radar,
            color: const Color(0xFFE91E63),
            onTap: () =>
                Navigator.of(context!).pushNamed('/negative-thought-radar'),
          ),
          ToolItem(
            label: 'سنجش اثر فکر',
            icon: Icons.trending_down,
            color: const Color(0xFFFF5722),
            onTap: () =>
                Navigator.of(context!).pushNamed('/negative-thought-radar'),
          ),
        ];
      case 5:
        return [
          ToolItem(
            label: 'دادگاه ذهن',
            icon: Icons.gavel,
            color: const Color(0xFF3F51B5),
            onTap: () => Navigator.of(context!).pushNamed('/mind-court'),
          ),
          ToolItem(
            label: 'فکر جایگزین',
            icon: Icons.lightbulb_outline,
            color: const Color(0xFFFFC107),
            onTap: () => Navigator.of(context!).pushNamed('/mind-court'),
          ),
        ];
      case 6:
        return [
          ToolItem(
            label: 'تمرین تعارض',
            icon: Icons.forum,
            color: const Color(0xFF009688),
            onTap: () => Navigator.of(context!).pushNamed('/conflict-exercise'),
          ),
        ];
      case 7:
        return [
          ToolItem(
            label: 'چرخه انزوا',
            icon: Icons.loop,
            color: const Color(0xFF795548),
            onTap: () => Navigator.of(context!).pushNamed('/isolation-cycle'),
          ),
          ToolItem(
            label: 'فعالیت‌های خرد',
            icon: Icons.checklist_outlined,
            color: const Color(0xFF2196F3),
            onTap: () => Navigator.of(context!).pushNamed('/micro-activities'),
          ),
          ToolItem(
            label: 'ردیاب خلق',
            icon: Icons.mood_outlined,
            color: const Color(0xFF4CAF50),
            onTap: () => Navigator.of(context!).pushNamed('/mood-tracker'),
          ),
        ];
      case 8:
        return [
          ToolItem(
            label: 'تعادل نقش‌ها',
            icon: Icons.balance,
            color: const Color(0xFF673AB7),
            onTap: () => Navigator.of(context!).pushNamed('/role-balance'),
          ),
          ToolItem(
            label: 'آسمان افکار',
            icon: Icons.cloud_outlined,
            color: const Color(0xFF03A9F4),
            onTap: () => Navigator.of(context!).pushNamed('/thought-sky'),
          ),
        ];
      default:
        return [];
    }
  }

  /// Get permanent tools available throughout the program.
  List<ToolItem> getPermanentTools() {
    return [
      ToolItem(
        label: 'تایمر آگاهانه',
        icon: Icons.timer_outlined,
        color: const Color(0xFF00BCD4),
      ),
      ToolItem(
        label: 'تقویم ۵۶ روزه',
        icon: Icons.calendar_today_outlined,
        color: const Color(0xFF6C63FF),
      ),
      ToolItem(
        label: 'گزارش هفتگی',
        icon: Icons.assessment_outlined,
        color: const Color(0xFFFF6584),
      ),
    ];
  }
}
