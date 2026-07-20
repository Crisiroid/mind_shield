import '../../../../core/database/syncable_local_data_source.dart';
import '../../../../core/sync/offline_first_repository.dart';
import '../../../../core/sync/write_result.dart';
import '../datasources/media_progress_local_datasource.dart';
import '../datasources/media_progress_remote_datasource.dart';
import '../models/media_progress_model.dart';

/// Offline-first repository for per-user media progress. Progress is written
/// optimistically to SQLite and pushed to the backend via the idempotent
/// `PUT /media/progress/:media_id` upsert; [SyncManager] pulls/pushes it
/// through the [featureKey] registration.
class MediaProgressRepository
    extends OfflineFirstRepository<MediaProgressModel> {
  final MediaProgressRemoteDataSource _remoteDataSource;
  final MediaProgressLocalDataSource _localDataSource;

  MediaProgressRepository(this._remoteDataSource, this._localDataSource);

  @override
  String get featureKey => 'media_progress';

  @override
  SyncableLocalDataSource<MediaProgressModel> get local => _localDataSource;

  @override
  Future<List<MediaProgressModel>> fetchRemoteList() =>
      _remoteDataSource.getMyProgress();

  @override
  Future<MediaProgressModel> pushCreate(MediaProgressModel item) async =>
      (await _remoteDataSource.upsertProgress(item)).data;

  @override
  Future<MediaProgressModel> pushUpdate(MediaProgressModel item) async =>
      (await _remoteDataSource.upsertProgress(item)).data;

  Result<List<MediaProgressModel>> listMyProgress() {
    return readList(() => _remoteDataSource.getMyProgress());
  }

  /// Upserts progress for a media item. Uses the create path so the optimistic
  /// local row is swapped for the server row (id reconciliation) on success,
  /// which keeps a single row per media item.
  Result<WriteResult<MediaProgressModel>> upsertProgress(
    MediaProgressModel progress,
  ) {
    return writeCreate(progress, (i) => _remoteDataSource.upsertProgress(i));
  }

  /// Returns the locally-cached progress row for [mediaContentId], if any, so
  /// callers can reuse its id and avoid creating duplicate rows.
  Future<MediaProgressModel?> getLocalByMedia(String mediaContentId) async {
    final all = await _localDataSource.getAll();
    for (final progress in all) {
      if (progress.mediaContentId == mediaContentId) return progress;
    }
    return null;
  }
}
