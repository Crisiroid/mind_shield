import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../../home/data/models/weekly_media_model.dart';
import '../../data/models/media_progress_model.dart';
import '../../data/repositories/media_progress_repository.dart';
import '../../data/repositories/weekly_content_repository.dart';

/// Drives the weekly content library: loads all active content, groups it by
/// week, merges per-item watched/progress state, and gates weeks behind the
/// user's current program week.
class WeeklyContentViewModel extends ChangeNotifier {
  final WeeklyContentRepository _contentRepository;
  final MediaProgressRepository _progressRepository;

  WeeklyContentViewModel(this._contentRepository, this._progressRepository);

  static const int totalWeeks = 8;

  bool _isLoading = false;
  String? _errorMessage;
  int _currentWeek = 1;
  final Map<int, List<WeeklyMediaModel>> _contentByWeek = {};
  final Map<String, MediaProgressModel> _progressByMedia = {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentWeek => _currentWeek;

  /// Whether all weeks are unlocked (debug builds bypass week-gating).
  bool get isAllUnlocked => AppConfig.isDebug;

  List<WeeklyMediaModel> contentForWeek(int week) =>
      _contentByWeek[week] ?? const [];

  bool isWeekUnlocked(int week) => AppConfig.isDebug || week <= _currentWeek;

  MediaProgressModel? progressFor(String mediaContentId) =>
      _progressByMedia[mediaContentId];

  bool isWatched(String mediaContentId) =>
      _progressByMedia[mediaContentId]?.isCompleted ?? false;

  /// Number of unlocked items the user has completed.
  int get watchedCount {
    var count = 0;
    for (var week = 1; week <= totalWeeks; week++) {
      if (!isWeekUnlocked(week)) continue;
      for (final media in contentForWeek(week)) {
        if (isWatched(media.id)) count++;
      }
    }
    return count;
  }

  /// Number of unlocked items still to watch.
  int get toWatchCount {
    var count = 0;
    for (var week = 1; week <= totalWeeks; week++) {
      if (!isWeekUnlocked(week)) continue;
      for (final media in contentForWeek(week)) {
        if (!isWatched(media.id)) count++;
      }
    }
    return count;
  }

  Future<void> init() async {
    _loadCurrentWeek();
    await load();
  }

  void _loadCurrentWeek() {
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    _currentWeek = WeekCalculator.currentWeekNumber(registrationDate);
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final contentResult = await _contentRepository.getAllContent();
    contentResult.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (content) {
        _contentByWeek.clear();
        for (final media in content) {
          if (!media.isActive) continue;
          _contentByWeek.putIfAbsent(media.weekNumber, () => []).add(media);
        }
      },
    );

    final progressResult = await _progressRepository.listMyProgress();
    progressResult.fold(
      (_) {
        // Progress is best-effort; the library still renders without it.
      },
      (progressList) {
        _progressByMedia.clear();
        for (final progress in progressList) {
          _progressByMedia[progress.mediaContentId] = progress;
        }
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => load();

  Future<void> markInProgress(WeeklyMediaModel media) async {
    final existing = _progressByMedia[media.id];
    // Never downgrade an already-completed item back to in-progress.
    if (existing != null && existing.isCompleted) return;
    await _saveProgress(media, MediaProgressStatus.inProgress);
  }

  Future<void> markCompleted(WeeklyMediaModel media) async {
    await _saveProgress(media, MediaProgressStatus.completed);
  }

  Future<void> _saveProgress(WeeklyMediaModel media, String status) async {
    final existing = _progressByMedia[media.id];
    final progress = MediaProgressModel(
      id: existing?.id ?? UuidGenerator.generate(),
      mediaContentId: media.id,
      status: status,
      progressSeconds: existing?.progressSeconds ?? 0,
      completedAt: status == MediaProgressStatus.completed
          ? DateTime.now()
          : existing?.completedAt,
      createdAt: existing?.createdAt,
    );

    // Optimistic local update so the UI reflects the change immediately.
    _progressByMedia[media.id] = progress;
    notifyListeners();

    final result = await _progressRepository.upsertProgress(progress);
    result.fold((_) {}, (saved) {
      _progressByMedia[media.id] = saved.data;
    });
    notifyListeners();
  }
}
