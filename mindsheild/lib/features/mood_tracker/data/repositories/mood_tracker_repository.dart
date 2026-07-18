import '../../../../core/database/syncable_local_data_source.dart';
import '../../../../core/sync/offline_first_repository.dart';
import '../datasources/mood_tracker_local_datasource.dart';
import '../datasources/mood_tracker_remote_datasource.dart';
import '../models/mood_tracker_model.dart';

/// Mood tracker repository — offline-first bridge between the data sources
/// and the domain layer.
class MoodTrackerRepository extends OfflineFirstRepository<MoodTrackerModel> {
  final MoodTrackerRemoteDataSource _remoteDataSource;
  final MoodTrackerLocalDataSource _localDataSource;

  MoodTrackerRepository(this._remoteDataSource, this._localDataSource);

  @override
  String get featureKey => 'mood_tracker';

  @override
  SyncableLocalDataSource<MoodTrackerModel> get local => _localDataSource;

  @override
  Future<List<MoodTrackerModel>> fetchRemoteList() =>
      _remoteDataSource.listMoodTrackers(page: 1, pageSize: 200);

  @override
  Future<MoodTrackerModel> pushCreate(MoodTrackerModel item) =>
      _remoteDataSource.createMoodTracker(mood: item);

  /// Create a new mood tracker record (offline-first).
  Result<MoodTrackerModel> createMoodTracker({required MoodTrackerModel mood}) {
    return writeCreate(
      mood,
      (i) => _remoteDataSource.createMoodTracker(mood: i),
    );
  }

  /// List mood tracker records (offline-first).
  Result<List<MoodTrackerModel>> listMoodTrackers({
    int page = 1,
    int pageSize = 20,
  }) {
    return readList(
      () => _remoteDataSource.listMoodTrackers(page: page, pageSize: pageSize),
    );
  }
}
